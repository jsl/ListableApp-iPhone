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
#import "UserSettings.h"
#import "TimedURLConnection.h"

#import "StatusDisplay.h"

#import "JSON.h"

#import "URLEncode.h"

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@implementation CollaboratorsController

@synthesize collaborators, inviteeEmail, statusDisplay, itemList;

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
	
	NSString *format = @"%@/lists/%@/collaborators.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId];

	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"];
    		
	NSData *httpBody = [ [ NSString stringWithFormat:@"collaborator[email]=%@&user_credentials=%@", 
						  [ self.inviteeEmail URLEncodeString ],
						  [ [UserSettings sharedUserSettings].authToken URLEncodeString] ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setHTTPBody: httpBody];
	
	[[[ TimedURLConnection alloc] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																				   delegate:self 
																			  statusDisplay:self.statusDisplay 
																			  statusMessage:@"Sending invitation..." ] autorelease];	
}

- (void) renderSuccessJSONResponse: (id)parsedJsonObject {
	if ( [ parsedJsonObject isKindOfClass:[ NSArray class ]] == YES )
		self.collaborators = [ self processGetResponse:parsedJsonObject ];
	else
		[ self loadItems ];
	
	[ self.tableView reloadData ];
}

- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode {
	if ([ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES) {
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
														 message:[ parsedJsonObject valueForKey:@"message"]
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		[alert show];
		[alert release];
	}
}

// Just returns after picking person
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {
	NSMutableArray *tmpCollaborators =  [ [ NSMutableArray alloc ] init ];
	
	for (id setObject in jsonArray) {
		Collaborator *c = [[Collaborator alloc] init];
		
		[c setEmail: [setObject objectForKey:@"email"] ];
		[c setRemoteId:[setObject objectForKey:@"id"] ];
		[c setIsCreator:[setObject objectForKey:@"is_creator"] ];
		
		[tmpCollaborators addObject:c];
		[c release];
	}

	return [ tmpCollaborators autorelease ];
}

- (void) loadItems {
	
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/collaborators.json?user_credentials=%@", 
						   API_SERVER, 
						   [ itemList remoteId ], 
						   [ [UserSettings sharedUserSettings].authToken URLEncodeString ]
						   ];
		
	NSURL *myURL = [NSURL URLWithString:urlString];
	
	[[ [ TimedURLConnection alloc ] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																				 delegate:self 
																			statusDisplay:self.statusDisplay 
																			statusMessage:@"Loading editor list..." ] autorelease];	
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
	
	self.collaborators = [ NSMutableArray new ];
	
	// create a standard "add" button
	UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;
	self.navigationItem.rightBarButtonItem = bi;
	[bi release];
		
	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.parentViewController.view ];
	
    self.title = @"List Editors";
	
	[super viewDidLoad];
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
 
	Collaborator *c = [collaborators objectAtIndex:[indexPath row]];	
	NSString *lblText = ([c isCreator] == [NSNumber numberWithBool:YES]) ? [NSString stringWithFormat:@"%@ (%@)", c.email, @"Creator"] : c.email;

 	cell.textLabel.text = lblText;
	
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
		if (!UIAppDelegate.ableToConnectToHostWithAlert)
			return;

		NSString *format = @"%@/lists/%@/collaborators/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, collaborator.remoteId, [[UserSettings sharedUserSettings].authToken URLEncodeString]];
		
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];

		[request setHTTPMethod:@"DELETE"];

		[[ [ TimedURLConnection alloc ] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																						 delegate:self 
																					statusDisplay:self.statusDisplay 
																					statusMessage:@"Deleting editor..." ] autorelease];
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
	[ItemList release];
	[statusDisplay release];
	
    [super dealloc];
}


@end

