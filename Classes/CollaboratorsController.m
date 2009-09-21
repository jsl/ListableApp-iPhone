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
#import "ShakeableTableView.h"
#import "SharedListAppDelegate.h"

#import "StatusDisplay.h"

#import "JSON.h"

#import "URLEncode.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@implementation CollaboratorsController

@synthesize collaborators, inviteeEmail, receivedData, statusDisplay, accessToken, itemList, statusCode, appDelegate;

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

-(void) shakeHappened:(ShakeableTableView *)view {
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
	if (buttonIndex == 1)
		[ self sendInvitationToEmail ];
}

// Creates an invitation record for the email in ivar for inviteeEmail.
- (void)sendInvitationToEmail {
	if (!appDelegate.ableToConnectToHostWithAlert)
		return;
	
	NSString *format = @"%@/lists/%@/collaborators.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId];

	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
	[ self.statusDisplay startWithTitle:@"Sending invitation..." ];
	
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
    [ connection release ];
	[ receivedData release ];
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
	
	id parsedJsonObject = [jsonData JSONValue];
	
	// Try getting items from response if the body isn't empty and the code is 200
	if ([ statusCode intValue ] == 200) {
		if ( [ parsedJsonObject isKindOfClass:[ NSArray class ]] == YES )
			self.collaborators = [ self processGetResponse:parsedJsonObject ];
		else
			[ self loadItems ];
		
	} else {
		
		if ([ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES) {
			UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
															 message:[ [jsonData JSONValue] valueForKey:@"message"]
															delegate:self
												   cancelButtonTitle:@"OK" 
												   otherButtonTitles:nil ];
			
			[alert show];
			[alert release];
			
		} else {
			NSLog(@"Unusual - response code of %i and body len == %i", [statusCode intValue], [jsonData length]);
		}
	}
	
	[ self.tableView reloadData ];
	
	[ self.statusDisplay stop ];
	
	[jsonData release];
    [connection release];	
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {
	NSMutableArray *tmpCollaborators =  [ [ NSMutableArray alloc ] init ];
	
	for (id setObject in jsonArray) {
		Collaborator *c = [[Collaborator alloc] init];
		
		[c setEmail: [setObject objectForKey:@"email"] ];
		[c setRemoteId:[setObject objectForKey:@"id"] ];
		
		[tmpCollaborators addObject:c];
	}

	return tmpCollaborators;
}

- (void) loadItems {
	if (!appDelegate.ableToConnectToHostWithAlert)
		return;
	
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/collaborators.json?user_credentials=%@", API_SERVER, [itemList remoteId], [self accessToken] ];
		
	NSURL *myURL = [NSURL URLWithString:urlString];
	
	[ self.statusDisplay startWithTitle:@"Loading editor list..." ];
	
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
	self.tableView = [ [ShakeableTableView alloc] init];
	[ (ShakeableTableView *)self.tableView setViewDelegate:self ];

	self.appDelegate = (SharedListAppDelegate *)[ [UIApplication sharedApplication] delegate];
	
	self.collaborators = [ NSMutableArray new ];
	
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 40, 45)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	// create a standard "add" button
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
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

	self.statusDisplay = [ statusDisplay initWithView:self.parentViewController.view ];
	
    self.title = @"List Editors";
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView becomeFirstResponder];

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

- (void)viewWillDisappear:(BOOL)animated {
	[self.tableView resignFirstResponder];

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
		if (!appDelegate.ableToConnectToHostWithAlert)
			return;

		NSString *format = @"%@/lists/%@/collaborators/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, collaborator.remoteId, [accessToken URLEncodeString]];
		
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];

		[ self.statusDisplay startWithTitle:@"Deleting collaborator..." ];

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
	[statusDisplay release];
	[appDelegate release];
	
    [super dealloc];
}


@end

