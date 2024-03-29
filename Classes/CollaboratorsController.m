//
//  CollaboratorsController.m
//  Listable
//
//  Created by Justin Leitgeb on 9/15/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import "CollaboratorsController.h"
#import "EmailSelectionController.h"
#import "ItemList.h"
#import "Collaborator.h"
#import "ShakeableTableView.h"
#import "SharedListAppDelegate.h"
#import "UserSettings.h"
#import "TimedURLConnection.h"
#import "StringHelper.h"
#import "AsyncImageView.h"

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
				
		[c setLogin: [setObject objectForKey:@"login"] ];
		[c setUserId: [setObject objectForKey:@"user_id"]];
		[c setRemoteId:[setObject objectForKey:@"id"] ];
		[c setIsCreator:[setObject objectForKey:@"is_creator"] ];
		[c setUserImage:[setObject objectForKey:@"user_image"] ];
				
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

- (void)viewWillDisappear:(BOOL)animated {
	[self.tableView resignFirstResponder];

	[super viewWillDisappear:animated];
}

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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Collaborator *c = [self.collaborators objectAtIndex:indexPath.row];
	NSString *lblText = ([c isCreator] == [NSNumber numberWithBool:YES]) ? [NSString stringWithFormat:@"%@ (%@)", c.login, @"Creator"] : c.login;

	return [lblText RAD_textHeightForSystemFontOfSize:kTextViewFontSize] + 20;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [collaborators count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	Collaborator *c = [self.collaborators objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"CollaboratorCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if ( cell == nil ) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
		
	} else {
		UIView *vw;
		vw = [cell viewWithTag:1];
		[vw removeFromSuperview];
				
		vw = [cell viewWithTag:999];
		[vw removeFromSuperview];
	}
	
	cell.accessoryType = UITableViewCellAccessoryNone;
	
	NSString *format = @"http://www.gravatar.com/avatar/%@?s=35";
	NSString *myUrlStr = [NSString stringWithFormat:format, c.userImage];
	
	NSURL *url = [NSURL URLWithString:myUrlStr ];

	NSString *lblText = ([c isCreator] == [NSNumber numberWithBool:YES]) ? [NSString stringWithFormat:@"%@ (%@)", c.login, @"Creator"] : c.login;

	UILabel *msgLabel = [ lblText RAD_newSizedCellLabelWithSystemFontOfSize:kTextViewFontSize x_pos:55.0f y_pos:10.0f];
	
	CGRect ImageFrame = CGRectMake(10, ( msgLabel.frame.size.height / 2 ) - 7, 35, 35);
	
	AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame:ImageFrame] autorelease];
	
	asyncImage.tag = 999;
	
	[asyncImage loadImageFromURL:url];
	
	msgLabel.numberOfLines = 0;
	msgLabel.lineBreakMode = UILineBreakModeWordWrap;
	msgLabel.tag = 1;
	
	[cell addSubview:msgLabel];

	msgLabel.text = lblText;
	
	[msgLabel release];

	[cell.contentView addSubview:asyncImage];
	
	[ cell layoutSubviews ];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {	
		Collaborator *collaborator = [collaborators objectAtIndex:indexPath.row];
		
		// Make a request to delete this user.
		
		NSString *format = @"%@/lists/%@/collaborators/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, collaborator.remoteId, [[UserSettings sharedUserSettings].authToken URLEncodeString]];
		
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		
		[request setHTTPMethod:@"DELETE"];
		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		
		if ( [ [ prefs objectForKey:@"userId" ] integerValue ] == [ collaborator.userId integerValue ] ) {
			
			[[[TimedURLConnection alloc] initWithRequest:request ] autorelease];
			UIViewController* controller = [self.navigationController.viewControllers objectAtIndex:0];
			[self.navigationController popToViewController:controller animated:NO];
			
		} else {
			
			[[ [ TimedURLConnection alloc ] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																							  delegate:self 
																						 statusDisplay:self.statusDisplay 
																						 statusMessage:@"Deleting editor..." ] autorelease];
			
		}			
	}
}

- (void)dealloc {
	[collaborators release];
	[inviteeEmail release];
	[itemList release];
	[statusDisplay release];
	
    [super dealloc];
}


@end

