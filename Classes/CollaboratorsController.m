//
//  CollaboratorsController.m
//  Listable
//
//  Created by Justin Leitgeb on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CollaboratorsController.h"
#import "EmailSelectionController.h"
#import "ItemList.h"
#import "Collaborator.h"

#import "StatusToolbarGenerator.h"

#import "JSON.h"

#import "URLEncode.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@implementation CollaboratorsController

@synthesize collaborators, inviteeEmail, receivedData, toolbar, accessToken, itemList, statusCode;

- (IBAction)addButtonAction:(id)sender {
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
	
    [self presentModalViewController:picker animated:YES];
    [picker release];
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
		
	} else {
		EmailSelectionController *nextController = [[EmailSelectionController alloc] initWithStyle:UITableViewStylePlain];
		
		[ nextController setEmails:emailAddresses ];
		
		nextController.collaboratorsController = self;
		
		[[self navigationController] pushViewController:nextController animated:YES];
		[nextController release];		
	}
	
	[emailAddresses release];
	
    [self dismissModalViewControllerAnimated:YES];
	
    return NO;
}

- (IBAction)refreshButtonAction:(id)sender {
	[ self loadItems ];
}

- (void) alertEmailWillBeSent {
	NSString *msg = [NSString stringWithFormat:@"An email will be sent to %@ inviting them to this list.  OK?", [self inviteeEmail]];
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Confirm invitation" 
													 message:msg 
													delegate:self
										   cancelButtonTitle:@"Cancel" 
										   otherButtonTitles:@"OK", nil ];
	
	[alert show];
	[alert release];
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
	NSString *format = @"%@/lists/%@/collaborators.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId];
	
	currentRetrievalType = Create;
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
	self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Sending invitation..."];
	
	[self.parentViewController.view addSubview:self.toolbar];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"];
    		
	NSData *httpBody = [ [ NSString stringWithFormat:@"collaborator[email]=%@&user_credentials=%@", 
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

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response respondsToSelector:@selector(statusCode)])
		self.statusCode = [ NSNumber numberWithInt:[((NSHTTPURLResponse *)response) statusCode] ];
			
	[self.receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [connection release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
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
	
	if ([ statusCode intValue ] >= 400) {
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
														 message:jsonData
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		self.toolbar.hidden = YES;

	 	[alert show];
		[alert release];
	} else {

		// Try getting collaborators from response if the body isn't empty and the code is 200
		if ([ statusCode intValue ] == 200) {
			if ( [ jsonData length] > 0) {
				NSMutableArray *collabs = [ self processGetResponse:jsonData ];

				self.collaborators = [ collabs retain ];
				self.toolbar.hidden = YES;
				[self.tableView reloadData];
				
				[collabs release];
				
			} else if ([ jsonData length] == 0) {
				// Must have been a POST or a DELETE, no body parseable to an Array
				self.toolbar.hidden = YES;
				
				// Get new result set.
				[self loadItems];
			}
		} else {
			NSLog(@"Unusual - response code of %i and body len == %i", [statusCode intValue], [jsonData length]);
		}
	}

	
	[jsonData release];
    [connection release];	
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSString *)jsonData {
	
	NSMutableArray *cArray = [jsonData JSONValue];
	NSMutableArray *tmpCollaborators =  [ [ NSMutableArray alloc ] init ];
	
	for (id setObject in cArray) {
		Collaborator *c = [[Collaborator alloc] init];
		
		[c setEmail: [setObject objectForKey:@"email"] ];
		[c setRemoteId:[setObject objectForKey:@"id"] ];
		
		[tmpCollaborators addObject:c];
	}

	return tmpCollaborators;
}

- (void) loadItems {
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/collaborators.json?user_credentials=%@", API_SERVER, [itemList remoteId], [self accessToken] ];
		
	NSURL *myURL = [NSURL URLWithString:urlString];
		
	self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Loading editor list..."];
	[self.parentViewController.view addSubview:self.toolbar];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
			
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }
}


/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

- (void)viewDidLoad {
	
	self.collaborators = [ NSMutableArray new ];
	
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 90, 45)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	// create a standard "add" button
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	[bi release];
		
	// create a standard "refresh" button
	bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	[bi release];
	
	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	[buttons release];
	
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
	[tools release];	
	
    [super viewDidLoad];

    self.title = @"List Editors";
}

- (void)viewWillAppear:(BOOL)animated {
	// If we're loaded with an inviteeEmail present, assume we need to deliver it.
	if (inviteeEmail != nil)
		[self alertEmailWillBeSent];
	
	[self loadItems];
    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
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
	return [collaborators count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	cell.textLabel.text = [ [collaborators objectAtIndex:[indexPath row] ] email ];
	
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
	Collaborator *collaborator = [collaborators objectAtIndex:indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {		
		currentRetrievalType = Delete;
		
		NSString *format = @"%@/lists/%@/collaborators/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, collaborator.remoteId, [accessToken URLEncodeString]];
		
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];

		self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Deleting collaborator..."];		
		[self.parentViewController.view addSubview:self.toolbar];
		
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
	[collaborators release];
	[inviteeEmail release];
	[accessToken release];
	[ItemList release];
	[receivedData release];
	[toolbar release];
	
    [super dealloc];
}


@end

