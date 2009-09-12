//
//  ListItemsController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ListItemsController.h"
#import "ItemList.h"
#import "Item.h"
#import "JSON.h"
#import "AddListItemController.h"
#import "URLEncode.h"
#import "Constants.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@implementation ListItemsController

@synthesize itemList;
@synthesize accessToken;
@synthesize receivedData;
@synthesize listItems;
@synthesize toolbar;
@synthesize inviteeEmail;

/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
    [super viewDidLoad];

	
	self.title = itemList.name;
	
    // Create a header view. Wrap it in a container to allow us to position
    // it better.
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
	UILabel *headerLabel  = [[[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 40)] autorelease];
	
    headerLabel.text = [ NSString stringWithFormat:@"Items in \"%@\"", itemList.name];
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.shadowColor = [UIColor grayColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:22];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    self.tableView.tableHeaderView = containerView;	
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonAction:)];
	[self.navigationItem setRightBarButtonItem:addButton];
}

- (IBAction)refreshButtonAction:(id)sender {
	[ self loadItems ];
}

- (IBAction)shareButtonAction:(id)sender {
    ABPeoplePickerNavigationController *picker =
	[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (IBAction)addButtonAction:(id)sender {
	AddListItemController *nextController = [[AddListItemController alloc] initWithNibName:@"AddListItem" bundle:nil];
	
	[ nextController setAccessToken:self.accessToken ];
	[ nextController setItemList:self.itemList ];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}


- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker {
    [self dismissModalViewControllerAnimated:YES];
}


- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
	ABMultiValueRef emailProperty = ABRecordCopyValue(person, kABPersonEmailProperty);
	NSArray* emailAddresses = (NSArray*)ABMultiValueCopyArrayOfAllValues(emailProperty);
	CFRelease(emailProperty);	
	
	if ([emailAddresses count] == 0) {
		NSString *msg = @"Cannot send list to contact with no emails.  Please add an email for desired contact in iPhone contact manager and try again.";
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"No emails found for contact" 
														 message:msg 
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
	 	[alert show];
		[alert release];
		
	} else if ([emailAddresses count] == 1) {
		[self setInviteeEmail:[emailAddresses objectAtIndex:0]];
		NSString *msg = [NSString stringWithFormat:@"An email will be sent to %@ inviting them to this list.  OK?", [emailAddresses objectAtIndex:0]];
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Confirm invitation" 
														 message:msg 
														delegate:self
											   cancelButtonTitle:@"Cancel" 
											   otherButtonTitles:@"OK", nil ];
		
	 	[alert show];
		[alert release];		
	} else {
		NSLog(@"Too many addresses, go to disambiguator");
	}
	
	[emailAddresses release];
	
    [self dismissModalViewControllerAnimated:YES];
	
    return NO;
}

// This is received when an OK is received, currently only to confirm that we should invite the email address found.
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 0) {
		NSLog(@"Cancel Received");
	} else {
		[ self sendInvitationToEmail ];
		NSLog(@"OK Received");
	}
}

// Creates an invitation record for the email in ivar for inviteeEmail.
- (void)sendInvitationToEmail {
	NSString *format = @"%@/lists/%@/invitations.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"];
    
	NSData *httpBody = [ [ NSString stringWithFormat:@"invitation[email]=%@&user_credentials=%@", 
						  [ self.inviteeEmail URLEncodeString ],
						  [accessToken URLEncodeString] ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setHTTPBody: httpBody];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }	
}

// Just returns after picking person, I think.
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

- (void) loadItems {
	
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/items.json?user_credentials=%@", API_SERVER, [itemList remoteId], [self accessToken] ];
		
	NSURL *myURL = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
	currentRetrievalType = Get;
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }		
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[self.receivedData setLength:0];
}

- (void)connectionDidFail:(NSURLConnection *)connection {
	[connection release];
	[receivedData release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {	
	NSString *jsonData = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	self.listItems = [NSMutableArray new];

	switch (currentRetrievalType) {
		case Get:
			[ self processGetResponse:jsonData ];
			break;
		case Delete:
			[ self processDeleteResponse:jsonData ];
			[ self loadItems ];
		default:
			break;
	}
	
	[jsonData release];
    [connection release];
	
	[self.tableView reloadData];
}

// Iterate through response data and set table items appropriately.
- (void)processGetResponse:(NSString *)jsonData {
	NSMutableArray *listItemArray = [jsonData JSONValue];

	for (id setObject in listItemArray) {
		Item *it = [[Item alloc] init];
		
		[it setName: [setObject objectForKey:@"name"] ];
		[it setRemoteId:[setObject objectForKey:@"id"] ];
		
		[self.listItems addObject:it];
	}
}

- (void)processDeleteResponse:(NSString *)jsonData {
	currentRetrievalType = Get;
	[self loadItems];
}

- (void)viewWillAppear:(BOOL)animated {
	
	UIImage *backgroundImage = [UIImage imageNamed:@"gradientBackground.png"];
	UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
	self.tableView.backgroundColor = backgroundColor;
	[backgroundColor release];

	
	/// Make floating toolbar footer
	self.toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
	
	//Set the frame
	CGFloat toolbarHeight = [toolbar frame].size.height;
	CGRect mainViewBounds = self.parentViewController.view.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds), CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - toolbarHeight, CGRectGetWidth(mainViewBounds),toolbarHeight)];
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithTitle:@"Refresh" style:UIBarButtonItemStyleBordered target:self action:@selector(refreshButtonAction:)];
	
	UIBarButtonItem *flexibleSpaceLeft = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	
	UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:@"Share" style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonAction:)];
	
	[toolbar setItems:[NSArray arrayWithObjects:refreshButton, flexibleSpaceLeft, shareButton, nil]];	
	
	[self.parentViewController.view addSubview:toolbar];
	

	// Have to load items
	[self loadItems];

    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	/// XXX remove toolbar subview like:
	[toolbar removeFromSuperview];

	[super viewWillDisappear:animated];
}

/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ [self listItems] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.textLabel.text = [ [ [self listItems] objectAtIndex:indexPath.row] name];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Item *item = [listItems objectAtIndex:indexPath.row];

	if (editingStyle == UITableViewCellEditingStyleDelete) {		
		currentRetrievalType = Delete;
		
		NSString *format = @"%@/lists/%@/items/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, item.remoteId, [accessToken URLEncodeString]];
				
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		
		[request setHTTPMethod:@"DELETE"];
		
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
		
		NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
		
		if (connection) { 
			receivedData = [[NSMutableData data] retain]; 
		}
	}
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
	[toolbar release];
	[accessToken release];
	[itemList release];
	[receivedData release];
	[listItems release];
	
    [super dealloc];
}


@end

