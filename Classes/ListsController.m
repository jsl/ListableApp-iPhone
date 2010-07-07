//
//  ListsController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import "ListsController.h"
#import "ListItemsController.h"

#import "ItemList.h"
#import "AddListController.h"
#import "URLEncode.h"
#import "Constants.h"
#import "StatusDisplay.h"
#import "SharedListAppDelegate.h"
#import "UserSettings.h"
#import "TimedURLConnection.h"
#import "StringHelper.h"

#import "ShakeableTableView.h"

@implementation ListsController

@synthesize lists, statusDisplay, ownedLists;

- (void)viewDidLoad {

	self.tableView = [ [ShakeableTableView alloc] init];
	[ (ShakeableTableView *)self.tableView setViewDelegate:self ];

	self.ownedLists = 0;
	
	// Custom left button
	UIBarButtonItem* lbi = [[UIBarButtonItem alloc] initWithImage:[ UIImage imageNamed:@"PencilDark.png" ] style:UIBarButtonItemStyleBordered target:self action:@selector(editListButtonAction:)];
	lbi.style = UIBarButtonItemStyleBordered;		
	self.navigationItem.leftBarButtonItem = lbi;
	[lbi release];
	

	UINavigationBar *bar = [self.navigationController navigationBar]; 
	UIColor *clr = [[UIColor alloc ] initWithRed:0.518 green:0.09 blue:0.09 alpha:1];
	[bar setTintColor:	clr]; 
	[clr release];
	
	// create a standard "add" button
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;		
	self.navigationItem.rightBarButtonItem = bi;
	[bi release];

	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.parentViewController.view ];
	
	self.title = @"Lists";
	
	[super viewDidLoad];	
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *lblText = [[self.lists objectAtIndex:indexPath.row] name];
	
	return [lblText RAD_textHeightForSystemFontOfSize:kTextViewFontSize] + 20;
}

- (void) editListButtonAction:(id)sender {
	[self setEditing:!self.editing];
	[self.tableView reloadData];
}

- (IBAction)addButtonAction:(id)sender {
	
	AddListController *nextController = [[AddListController alloc] initWithNibName:@"AddList" bundle:nil];
		
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

- (void) shakeHappened:(ShakeableTableView *)view {
	[ self loadLists ];
}

- (void) loadLists {
	
	NSString *format = @"%@/lists.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, [ [UserSettings sharedUserSettings].authToken URLEncodeString ]];

	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
	[[ [TimedURLConnection alloc] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																			   delegate:self 
																		  statusDisplay:self.statusDisplay 
																		  statusMessage:@"Loading lists..."] autorelease];
}

- (void)alertOnHTTPFailure {
	NSString *msg = @"HTTP Failure";
	
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"HTTP Failure!"
													 message:msg
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	[alert show];
	[alert release];		
	
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	NSString *format = @"%@/device_token/%@.json?device_token=%@&user_credentials=%@";
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER,
						  devToken, 
						  [ [UserSettings sharedUserSettings].authToken URLEncodeString] ];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [ request setHTTPMethod:@"PUT" ];
	
	[[ [ TimedURLConnection alloc ] initWithRequest:request ] autorelease ];
	
}

- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)theStatusCode {

	if (theStatusCode == 403) {
		self.lists = [ [ NSMutableArray alloc ] init ];
		[ self.tableView reloadData ];
	}
	
	if ([ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES) {
		NSString *msg = (NSString *)[parsedJsonObject objectForKey:@"message"];
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action, reload list and try again"
														 message:msg
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		[alert show];
		[alert release];
	} else {
		NSLog(@"Unusual - response code of %i and object == %@", theStatusCode, parsedJsonObject);			
	}	
}

// When the TimedURLConnection delegate receives a 200 response, it calls this method to figure
// out the specifics of how the parsed JSON object should be translated into something to render
// in the UITableView.
- (void) renderSuccessJSONResponse: (id)parsedJsonObject {	
	if ( [ parsedJsonObject isKindOfClass:[ NSArray class ]] == YES ) {
		self.lists = [ self processGetResponse:parsedJsonObject ];
		
	} else if ([ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES) {
		// Must have been a POST or a DELETE, no body parseable to an Array.  No action req'd.
	}
	
	[ self.tableView reloadData ];
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {	
	NSMutableArray *tmpItems = [ [[NSMutableArray alloc] init] autorelease ];

	self.ownedLists = 0;
	
	for (id setObject in jsonArray) {
		ItemList *l = [ [ItemList alloc] init];
		[l setName:[setObject objectForKey:@"name"]];
		[l setRemoteId:[setObject objectForKey:@"id"]];
		[l setLinkId:[setObject objectForKey:@"link_id"]];
		[l setCurrentUserIsCreator: [setObject objectForKey:@"current_user_is_creator"]];
		
		if ([ l.currentUserIsCreator boolValue ])
			self.ownedLists++;
		
		[l setMaxItems: [setObject objectForKey:@"max_items"]];
		
		[tmpItems addObject:l];
		[ l release ];
	}
		
	return tmpItems;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView becomeFirstResponder];
	
	[ self loadLists ];

    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self resignFirstResponder];

	[super viewWillDisappear:animated];
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [ [self lists] count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSString *lblText = [[self.lists objectAtIndex:indexPath.row] name];
	
	static NSString *CellIdentifier = @"ListCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	
	if ( cell == nil ) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	} else {
		
		UIView *vw;
		vw = [cell viewWithTag:1];
		[vw removeFromSuperview];		
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	float cellLeft = self.editing ? 40.0f : 10.0f;

	UILabel *msgLabel = [ lblText RAD_newSizedCellLabelWithSystemFontOfSize:kTextViewFontSize x_pos:cellLeft y_pos:10.0f];		

	msgLabel.numberOfLines = 0;
	msgLabel.lineBreakMode = UILineBreakModeWordWrap;
	msgLabel.tag = 1;
	
	[cell addSubview:msgLabel];
	
	msgLabel.text = lblText;
	
	[msgLabel release];
	
	[ cell layoutSubviews ];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	ItemList *l = [lists objectAtIndex:indexPath.row];

	ListItemsController *nextController = [[ListItemsController alloc] initWithStyle:UITableViewStylePlain];
	
	[ nextController setItemList:l ];

	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	ItemList *l = [lists objectAtIndex:indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {

		// If the current user is not the list creator, she is unable to delete the list.
		// Notify them of this fact and return.
		
		if (![ l.currentUserIsCreator boolValue]) {
			NSString *msg = @"Sorry, you are only able to delete lists which you've created and this list is not yours.  If you don't want to see this list anymore, remove yourself from the list collaborators.";
			
			UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to delete list"
															 message:msg
															delegate:self
												   cancelButtonTitle:@"OK" 
												   otherButtonTitles:nil ];
			
			[alert show];
			[alert release];		

			return;
		}
		
		self.ownedLists--;
		
		NSString *format = @"%@/lists/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, 
							  l.remoteId, [[UserSettings sharedUserSettings].authToken URLEncodeString]];
		
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		[ request setHTTPMethod:@"DELETE" ];
				
		[ self.tableView beginUpdates ];
		[ self.lists removeObjectAtIndex:indexPath.row ];
		[ self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationRight];
		[ self.tableView endUpdates ];
		
		[ self.tableView reloadData ];		
		
		[[ [ TimedURLConnection alloc ] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																						 delegate:self 
																					statusDisplay:self.statusDisplay 
																					statusMessage:@"Deleting list..." ] autorelease];
	} 
}

// Submits a PUT request to move list to link position specified by position.
- (void)moveLink: (ItemList *)list toPosition:(NSNumber *)position {	
	NSString *format = @"%@/user_list_links/%@.json?user_list_link[position]=%@&user_credentials=%@";
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER, 
						  list.linkId, 
						  [[position stringValue] URLEncodeString],
						  [[UserSettings sharedUserSettings].authToken URLEncodeString] ];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [ request setHTTPMethod:@"PUT" ];
	
	[[ [ TimedURLConnection alloc] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																					delegate:self 
																			   statusDisplay:self.statusDisplay 
																			   statusMessage:@"Moving list..." ] autorelease];
	
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	// Don't do anything if source is same as target.
	if ( ! (fromIndexPath.row == toIndexPath.row && fromIndexPath.section == toIndexPath.section) ) {
		ItemList *l = [ [lists objectAtIndex:fromIndexPath.row] retain];
		
		[lists removeObject:l];
		[lists insertObject:l atIndex:toIndexPath.row];
		
		// Have to add 1 to IndexPath.row because that's what the server expects.
		int newPos = toIndexPath.row + 1;
		[ self moveLink:l toPosition:[ NSNumber numberWithInt: newPos ]];

		[ l release ];

	}	
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)dealloc {
	[lists release];
	[statusDisplay release];
	
    [super dealloc];
}


@end

