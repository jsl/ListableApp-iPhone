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
#import "AddListItemController.h"
#import "URLEncode.h"
#import "Constants.h"
#import "CollaboratorsController.h"
#import "ListItemCustomCell.h"
#import "ItemDetailController.h"
#import "ShakeableTableView.h"
#import "EditListController.h"
#import "SharedListAppDelegate.h"
#import "UserSettings.h"
#import "TimedURLConnection.h"

#import "StringHelper.h"

#import "StatusDisplay.h"
#import "CustomButton.h"

@implementation ListItemsController

@synthesize itemList, listItems, inviteeEmail, loadingWithUpdate, statusDisplay, activePredicate, completedPredicate;

- (void)viewDidLoad {	
	self.tableView = [ [ShakeableTableView alloc] init];
	[ (ShakeableTableView *)self.tableView setViewDelegate:self ];
	
	// allows other controllers to tell us not to load data immediately if we're called after an update
	// on an item in our list.
	loadingWithUpdate = NO;
	
	// create a standard "add" button
	UIBarButtonItem *bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;
	self.navigationItem.rightBarButtonItem = bi;
	[bi release];
	
	// Set toolbar title
	self.title = @"Items";

	// Set up predicates used for filtering results based on completed status.
	NSExpression *lhs = [NSExpression expressionForKeyPath:@"completed"];
	NSExpression *rhs = [NSExpression expressionForConstantValue:[NSNumber numberWithInt:1]];
	
	self.completedPredicate = [ NSComparisonPredicate
									predicateWithLeftExpression:lhs
									rightExpression:rhs
									modifier:NSDirectPredicateModifier
									type:NSEqualToPredicateOperatorType
									options:0 ];
	
	self.activePredicate = [ NSComparisonPredicate
								predicateWithLeftExpression:lhs
								rightExpression:rhs
								modifier:NSDirectPredicateModifier
								type:NSNotEqualToPredicateOperatorType
								options:0 ];
	
	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.parentViewController.view ];
	
	// Add the titleView navigation bar items...
	UIView *tv = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 140, 45)];
	
	// Add the share button
	UIImage *users = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource :@"Users" ofType:@"png"]];	
	
	UIButton *btn = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	
	btn.frame = CGRectMake(0, 7, 80, 30);
	
	UIImage *backgroundImage = [[UIImage imageNamed: @"DarkerButtonBackgroundRed.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:15];
	
	[ btn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	[ btn setImage:users forState:UIControlStateNormal];
	[ btn addTarget:self action:@selector(shareButtonAction:)forControlEvents:UIControlEventTouchUpInside];
	
	[tv addSubview:btn];
	
	// Add edit button
	
	UIImage *pencil = [ UIImage imageNamed:@"PencilDark.png"];
	
	int newX = btn.frame.origin.x + btn.frame.size.width ;
	int newY = btn.frame.origin.y ;
	
	btn = [UIButton buttonWithType: UIButtonTypeRoundedRect];
	
	[btn setBackgroundImage:backgroundImage forState:UIControlStateNormal];
	[btn setImage:pencil forState:UIControlStateNormal];
	
	btn.frame = CGRectMake(newX, newY, 80, 30);
	
	[ btn addTarget:self action:@selector(editListButtonAction:)forControlEvents:UIControlEventTouchUpInside];
	
	[tv addSubview:btn];
	
	[ self.navigationItem setTitleView:tv ];
	[tv release];
	
	[super viewDidLoad];
}

// Makes POST request to add list item with the given name.
- (void) addListItemWithName:(NSString *) name {

	NSString *format = @"%@/lists/%@/items.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"];
    
	NSData *httpBody = [ [ NSString stringWithFormat:@"item[name]=%@&user_credentials=%@", 
						  [name URLEncodeString],
						  [[UserSettings sharedUserSettings].authToken URLEncodeString] ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setHTTPBody: httpBody];
		
	[ [TimedURLConnection alloc] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																				   delegate:self 
																			  statusDisplay:self.statusDisplay 
																			  statusMessage:@"Updating item..." ];
}

- (void) editListButtonAction:(id)sender {
	[self setEditing:!self.editing];
}

// Activate on touch of list heading.
- (void) editListTitleAction:(id)sender {
	EditListController *nextController = [[EditListController alloc] initWithNibName:@"EditListController" bundle:nil];
	
	nextController.list = self.itemList;
	nextController.listItemsController = self;
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];
}

- (void) shareButtonAction:(id)sender {
	CollaboratorsController *nextController = [[CollaboratorsController alloc] initWithStyle:UITableViewStylePlain];
	
	[ nextController setItemList:self.itemList ];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];
	
}

-(void) shakeHappened:(ShakeableTableView *)view {
	[ self loadItems ];
}

- (IBAction)addButtonAction:(id)sender {
	AddListItemController *nextController = [[AddListItemController alloc] initWithNibName:@"AddListItem" bundle:nil];
	
	[ nextController setListItemsController:self ];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

- (void) loadItems {
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/items.json?user_credentials=%@", API_SERVER, 
						   [ itemList remoteId ], 
						   [ [UserSettings sharedUserSettings].authToken URLEncodeString ] ];

	NSURL *myURL = [NSURL URLWithString:urlString];
		
	[ [TimedURLConnection alloc] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																			   delegate:self 
																		  statusDisplay:self.statusDisplay 
																		  statusMessage:@"Loading items..."];
	[ myURL release ];
}

- (void) renderSuccessJSONResponse: (id)parsedJsonObject {	
	
	if ( [ parsedJsonObject isKindOfClass:[ NSArray class ]] == YES ) {

		self.listItems = [ self processGetResponse:parsedJsonObject ];
		[ self.tableView reloadData ];

	} else if ( [ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES ) {
		// If it's an item detail view, load detail view controller.  Otherwise, load new result set since this is
		// the followup to a modification request.
		
		if ([ [ parsedJsonObject valueForKey:@"type" ] isEqual:@"Item" ]) {
			ItemDetailController *nextController = [[ItemDetailController alloc] initWithNibName:@"ItemDetail" bundle:nil];
			
			Item *itm = [ [Item alloc] init];
			itm.name = [ parsedJsonObject valueForKey:@"name" ];
			
			itm.createdAt = [ parsedJsonObject valueForKey:@"created_at" ];
			itm.creatorEmail = [ parsedJsonObject valueForKey:@"creator_email" ];
			itm.remoteId = [ parsedJsonObject valueForKey:@"id" ];
			
			nextController.item = itm;
			nextController.listItemsController = self;
						
			[[self navigationController] pushViewController:nextController animated:YES];
			[nextController release];				
		} else {
			// Got a success response on an update, check for latest list on server.
			[ self loadItems ];
		}
	}
}

- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode {
	NSString *msg = @"Undefined error occurred while processing response";
	
	if ( [ parsedJsonObject respondsToSelector:@selector( objectForKey: )] == YES )
		msg = [ parsedJsonObject objectForKey:@"message" ];
	
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
													 message:msg
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	
	[alert show];
	[alert release];
}

// Don't allow moving cells across sections.
- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {	
	return ( sourceIndexPath.section != proposedDestinationIndexPath.section ) ? sourceIndexPath : proposedDestinationIndexPath;
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {
		
	NSMutableArray *tmpItems = [ [[NSMutableArray alloc] init] autorelease];
	
	for (id setObject in jsonArray) {
		Item *it = [[Item alloc] init];
		
		[it setName: [setObject objectForKey:@"name"] ];
		[it setCompleted:[setObject objectForKey:@"completed"] ];

		[it setRemoteId:[setObject objectForKey:@"id"] ];
		
		[tmpItems addObject:it];
		
		[it release];
	}

	return tmpItems;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {	
	Item *item = [ self itemAtIndexPath:indexPath ];
	CGFloat height = [item.name RAD_textHeightForSystemFontOfSize:kTextViewFontSize] + 20.0;
	
    return height;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView becomeFirstResponder];
	
	// Create a header view. Wrap it in a container to allow us to position
    // it better.
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 45)] autorelease];
	UIButton *headerButton = [[UIButton alloc] initWithFrame:containerView.frame];

	headerButton.frame = containerView.frame;
		
	UILabel *label = [ [UILabel alloc] initWithFrame:CGRectMake(10, 5, 290, 35)];
	label.text = itemList.name;
	label.font = [UIFont boldSystemFontOfSize:18];
	label.textColor = [UIColor blackColor];
		
	[ headerButton addSubview:label];
	
	headerButton.backgroundColor = [UIColor whiteColor];
	
    [containerView addSubview:headerButton];
	
    self.tableView.tableHeaderView = containerView;	
	
	[headerButton addTarget:self action:@selector(editListTitleAction:) forControlEvents:UIControlEventTouchUpInside];
	[headerButton release];

	// If we're loading with an update from another controller, let that finished request load
	// items and unset the flag.  Otherwise, load items as normal.
	if (loadingWithUpdate)
		self.loadingWithUpdate = NO;
	else
		[ self loadItems ];
	
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
    return 2;
}

- (NSArray *)itemArrayInSection:(NSInteger)section {	
	return (section == 0) ? [self.listItems filteredArrayUsingPredicate:activePredicate] : [self.listItems filteredArrayUsingPredicate:completedPredicate];
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [ [ self itemArrayInSection:section ] count ];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Item *itm = [self itemAtIndexPath:indexPath];
	
    static NSString *CellIdentifier = @"ListViewCell";

	ListItemCustomCell *cell = (ListItemCustomCell *)[self.tableView dequeueReusableCellWithIdentifier:@"ListViewCell"];

	if ( cell == nil )
		cell = [[[ListItemCustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	
	cell.item				 = itm;
	cell.listItemsController = self;
	
	[ cell layoutSubviews ];
    return cell;
}

- (void)toggleCompletedStateForItem:(Item *)item {
	int toggledState = ( [ [item completed] intValue] == 0 ? 1 : 0);
	
	// Rather than making the user wait while we get back the new item list from the server, we 
	// guess at what the new order will be based on the assumption (usually correct) that this
	// toggle operation will succeed and reload the table accordingly.  If there is a discrepancy
	// with server data (rare cases), there will be a "jump" when the response is received.
	for ( Item *itm in self.listItems ) {
		if ( itm.remoteId == item.remoteId ) {
			[ self.listItems removeObject:itm ];
			
			item.completed = [NSNumber numberWithInt:toggledState];

			// By inserting at pos 0, we account for the fact that the server inserts items
			// at the top of the list when their scope is changed.
			[ self.listItems insertObject:item atIndex:0];

			[ self.tableView reloadData ];
			
			break;
		}
	}
	
	NSString *newStringBoolValue = ( toggledState == 0 ? @"false" : @"true");
	NSString *updateMessageTerm = ( toggledState == 0 ? @"active" : @"completed");
	
	NSString *updatingMessage = [NSString stringWithFormat:@"Marking item as %@", updateMessageTerm];
	[ self updateAttributeOnItem:item attribute:@"completed" newValue:newStringBoolValue displayMessage:updatingMessage ];
}

// Updates ItemList name.  Displays appropriate status message in toolbar.
- (void)updateListName: (ItemList *)list name:(NSString *)name {
	
	NSString *format = @"%@/lists/%@.json?list[name]=%@&user_credentials=%@";
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER,
						  itemList.remoteId, 
						  [name URLEncodeString],
						  [ [UserSettings sharedUserSettings].authToken URLEncodeString] ];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [ request setHTTPMethod:@"PUT" ];
    
	[ [ TimedURLConnection alloc ] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																					 delegate:self 
																				statusDisplay:self.statusDisplay 
																				statusMessage:@"Updating list name..." ];
}

// Updates a remote attribute using PUT.  Displays appropriate status message in toolbar.
- (void)updateAttributeOnItem: (Item *)item attribute:(NSString *)attribute newValue:(NSString *)newValue displayMessage:(NSString *)displayMessage {

	NSString *format = @"%@/lists/%@/items/%@.json?item[%@]=%@&user_credentials=%@";
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER, 
						  itemList.remoteId, 
						  item.remoteId,
						  [attribute URLEncodeString],
						  [newValue URLEncodeString],
						  [[UserSettings sharedUserSettings].authToken URLEncodeString] ];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [ request setHTTPMethod:@"PUT" ];
	
	[ [ TimedURLConnection alloc] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																					delegate:self 
																			   statusDisplay:self.statusDisplay 
																			   statusMessage:displayMessage ];	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath { 
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	Item *itm = [self itemAtIndexPath:indexPath];
	
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/items/%@.json?user_credentials=%@", 
						   API_SERVER, 
						   [itemList remoteId], 
						   [itm remoteId], 
						   [ [UserSettings sharedUserSettings].authToken URLEncodeString ]
						   ];
	
	NSURL *myURL = [NSURL URLWithString:urlString];
	
	[ [TimedURLConnection alloc] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																			   delegate:self 
																		  statusDisplay:self.statusDisplay
																		  statusMessage:@"Loading item details..." ];	
	[myURL release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {	
	return (section == 0) ? @"Active Items" : @"Completed Items";
}

- (Item *)itemAtIndexPath:(NSIndexPath *)indexPath {
	NSPredicate *thisPredicate = (indexPath.section == 0) ? self.activePredicate : self.completedPredicate;
	return [[self.listItems filteredArrayUsingPredicate:thisPredicate] objectAtIndex:indexPath.row];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
	Item *item = [self itemAtIndexPath:indexPath];

	if (editingStyle == UITableViewCellEditingStyleDelete) {
		[ listItems removeObjectAtIndex:indexPath.row ];

		NSString *format = @"%@/lists/%@/items/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, item.remoteId, [[UserSettings sharedUserSettings].authToken URLEncodeString]];
				
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		
		[ request setHTTPMethod:@"DELETE" ];
		
		[[ TimedURLConnection alloc] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request delegate:self statusDisplay:self.statusDisplay statusMessage:@"Deleting list item..."];		
	}	
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
	// Don't do anything if source is same as target.
	if ( ! (fromIndexPath.row == toIndexPath.row && fromIndexPath.section == toIndexPath.section) ) {
		Item *item = [ self itemAtIndexPath:fromIndexPath ];
		
		[self.listItems removeObjectAtIndex:fromIndexPath.row];
		
		[ self.listItems insertObject:item atIndex:toIndexPath.row ];

		NSString *updatingMessage = @"Moving item...";

		// Have to add 1 to IndexPath.row because that's what the server expects.
		int newPos = toIndexPath.row + 1;
		[ self updateAttributeOnItem:item attribute:@"position" newValue:[[NSNumber numberWithInt:newPos] stringValue] displayMessage:updatingMessage ];				
	}
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	// only allow reordering of active items.
	return (indexPath.section == 0);
}

- (void)dealloc {
	[itemList release];
	[listItems release];
	[statusDisplay release];
	
	[activePredicate release];
	[completedPredicate release];
	
    [super dealloc];
}


@end

