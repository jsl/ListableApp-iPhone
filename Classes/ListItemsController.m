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
#import "CollaboratorsController.h"
#import "ListItemCustomCell.h"
#import "ItemDetailController.h"
#import "ShakeableTableView.h"
#import "EditListController.h"

#import "StringHelper.h"

#import "StatusDisplay.h"

@implementation ListItemsController

@synthesize itemList;
@synthesize accessToken;
@synthesize receivedData;
@synthesize listItems;
@synthesize inviteeEmail;
@synthesize statusCode;
@synthesize completedItems;
@synthesize activeItems;
@synthesize loadingWithUpdate;
@synthesize statusDisplay;

#define kTextViewFontSize        18.0

- (void)viewDidLoad {	
	self.tableView = [ [ShakeableTableView alloc] init];
	[ (ShakeableTableView *)self.tableView setViewDelegate:self ];
	
	// allows other controllers to tell us not to load data immediately if we're called after an update
	// on an item in our list.
	loadingWithUpdate = NO;
	
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 140, 45)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];

	// Add edit button for list name
	UIImage *img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource :@"Pencil" ofType:@"png"]];
	
	UIBarButtonItem *bi = [ [UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleBordered target:self action:@selector(editListButtonAction:)];
	[buttons addObject:bi];
	[bi release];	
	
	// Add the share button
	img = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource :@"Users" ofType:@"png"]];	
	bi = [ [UIBarButtonItem alloc] initWithImage:img style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonAction:)];
	[buttons addObject:bi];
	[bi release];
	
	// create a standard "add" button
	bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	[bi release];
			
	// stick the buttons in the toolbar
	[tools setItems:buttons animated:NO];
	
	[buttons release];
	
	// Set toolbar title
	self.navigationItem.title = @"Items";
	
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
	[tools release];
	
	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.parentViewController.view ];
	
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
						  [accessToken URLEncodeString] ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setHTTPBody: httpBody];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }	
}

- (void) editListButtonAction:(id)sender {
	EditListController *nextController = [[EditListController alloc] initWithNibName:@"EditListController" bundle:nil];
	
	nextController.list = self.itemList;
	nextController.listItemsController = self;
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];
}

- (void) shareButtonAction:(id)sender {
	CollaboratorsController *nextController = [[CollaboratorsController alloc] initWithStyle:UITableViewStylePlain];
	
	[ nextController setItemList:self.itemList ];
	[ nextController setAccessToken:self.accessToken];
	
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
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/items.json?user_credentials=%@", API_SERVER, [itemList remoteId], [self accessToken] ];

	NSURL *myURL = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
	[self.statusDisplay startWithTitle:@"Loading items..."];
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response respondsToSelector:@selector(statusCode)])
		self.statusCode = [ NSNumber numberWithInt:[((NSHTTPURLResponse *)response) statusCode] ];
	
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
		
	[self.statusDisplay stop];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	id parsedJsonObject = [jsonData JSONValue];
	
	// Action is based on JSON response type.  An NSDictionary means a basic message, sent in
	// response to a delete request.  An NSArray is an index request.
	if ([ statusCode intValue ] == 200) {
		if ( [ parsedJsonObject isKindOfClass:[ NSArray class ]] == YES ) {
			NSMutableArray *itms = [ self processGetResponse:parsedJsonObject ];
			
			self.listItems = [ itms retain ];
			
			NSExpression *lhs = [NSExpression expressionForKeyPath:@"completed"];
			NSExpression *rhs = [NSExpression expressionForConstantValue:[NSNumber numberWithInt:1]];
			
			NSPredicate  *completedPredicate = [ NSComparisonPredicate
												predicateWithLeftExpression:lhs
												rightExpression:rhs
												modifier:NSDirectPredicateModifier
												type:NSEqualToPredicateOperatorType
												options:0 ];
			
			NSPredicate  *activePredicate = [ NSComparisonPredicate
											 predicateWithLeftExpression:lhs
											 rightExpression:rhs
											 modifier:NSDirectPredicateModifier
											 type:NSNotEqualToPredicateOperatorType
											 options:0 ];
			
			self.completedItems = [self.listItems filteredArrayUsingPredicate:completedPredicate];
			self.activeItems	= [self.listItems filteredArrayUsingPredicate:activePredicate];
			
			[itms release];
			
		} else if ( [ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES ) {
			// Get new result set.
			[self loadItems];
		}
		
	} else if ([ statusCode intValue ] >= 400) {
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
 	} else {
		NSLog(@"Unusual - response code of %i and body len == %i", [statusCode intValue], [jsonData length]);
	}

	[self.tableView reloadData];
	
	[jsonData release];
    [connection release];	
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {
	
	NSMutableArray *tmpItems = [[NSMutableArray alloc] init];
	
	for (id setObject in jsonArray) {
		Item *it = [[Item alloc] init];
		
		[it setName: [setObject objectForKey:@"name"] ];
		[it setCompleted:[setObject objectForKey:@"completed"] ];

		[it setRemoteId:[setObject objectForKey:@"id"] ];
		
		[tmpItems addObject:it];
	}
	
	return tmpItems;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *tmpItems = (indexPath.section == 0) ? self.activeItems : self.completedItems;
	Item *item = [tmpItems objectAtIndex:indexPath.row];

	CGFloat height = [item.name RAD_textHeightForSystemFontOfSize:kTextViewFontSize] + 20.0;
    return height;
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView becomeFirstResponder];
	
	// Create a header view. Wrap it in a container to allow us to position
    // it better.
    UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 60)] autorelease];
	UILabel *headerLabel  = [[[UILabel alloc] initWithFrame:CGRectMake(10, 20, 300, 40)] autorelease];
	
    headerLabel.text = itemList.name;
    headerLabel.textColor = [UIColor blackColor];
	
	//    headerLabel.shadowColor = [UIColor grayColor];
	//    headerLabel.shadowOffset = CGSizeMake(0, 1);
    
	headerLabel.font = [UIFont boldSystemFontOfSize:26];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    self.tableView.tableHeaderView = containerView;	
	

	// If we're loading with an update from another controller, let that finished request load
	// items and unset the flag.  Otherwise, load items as normal.
	if (loadingWithUpdate) {
		self.loadingWithUpdate = NO;
	} else {
		[self loadItems];	
	}

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
    return 2;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return [[self activeItems] count];
	} else {
		return [ [self completedItems] count];		
	}
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSArray *tmpItems = (indexPath.section == 0) ? self.activeItems : self.completedItems;
	Item *itm = [ tmpItems objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"ListViewCell";
    
	ListItemCustomCell *cell = (ListItemCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ListItemCustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
	
    if ([[cell.contentView subviews] count] > 1) {
        UIView *labelToClear = [[cell.contentView subviews] objectAtIndex:1];
        [labelToClear removeFromSuperview];
    }
	
    UILabel *cellLabel = [itm.name RAD_newSizedCellLabelWithSystemFontOfSize:kTextViewFontSize];
	
    [cell.contentView addSubview:cellLabel];
    [cellLabel release];
    	
	cell.checked = ( [ itm.completed intValue ] == 1 ? YES : NO );
	cell.item = itm;
	cell.listItemsController = self;
	
	[ cell setImageOnCheckedState ];
	
    return cell;
}

- (void)toggleCompletedStateForItem:(Item *)item {	
	int toggledState = ( [ [item completed] intValue] == 0 ? 1 : 0);
	
	item.completed = [NSNumber numberWithInt:toggledState];
	
	NSString *newStringBoolValue = ( toggledState == 0 ? @"false" : @"true");
	NSString *updateMessageTerm = ( toggledState == 0 ? @"active" : @"completed");
	
	NSString *updatingMessage = [NSString stringWithFormat:@"Marking item as %@", updateMessageTerm];
	[ self updateAttributeOnItem:item attribute:@"completed" newValue:newStringBoolValue displayMessage:updatingMessage ];
}

// Updates ItemList name.  Displays appropriate status message in toolbar.
- (void)updateListName: (ItemList *)list name:(NSString *)name {
	[ self.statusDisplay startWithTitle:@"Updating list name..." ];
	
	NSString *format = @"%@/lists/%@.json?list[name]=%@&user_credentials=%@";
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER,
						  itemList.remoteId, 
						  [name URLEncodeString],
						  [accessToken URLEncodeString] ];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [ request setHTTPMethod:@"PUT" ];
    
    [ [UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES ]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }	
}

// Updates a remote attribute using PUT.  Displays appropriate status message in toolbar.
- (void)updateAttributeOnItem: (Item *)item attribute:(NSString *)attribute newValue:(NSString *)newValue displayMessage:(NSString *)displayMessage {
	[ self.statusDisplay startWithTitle:displayMessage ];
	
	NSString *format = @"%@/lists/%@/items/%@.json?item[%@]=%@&user_credentials=%@";
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER, 
						  itemList.remoteId, 
						  item.remoteId,
						  [attribute URLEncodeString],
						  [newValue URLEncodeString],
						  [accessToken URLEncodeString] ];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [ request setHTTPMethod:@"PUT" ];
    
    [ [UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES ]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }	
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {	
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	ItemDetailController *nextController = [[ItemDetailController alloc] initWithNibName:@"ItemDetail" bundle:nil];

	NSArray *tmpItems = (indexPath.section == 0) ? self.activeItems : self.completedItems;
	Item *item = [tmpItems objectAtIndex:indexPath.row];

	nextController.item = item;
	nextController.listItemsController = self;
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	NSArray *tmpItems = (indexPath.section == 0) ? self.activeItems : self.completedItems;
	Item *item = [tmpItems objectAtIndex:indexPath.row];

	if (editingStyle == UITableViewCellEditingStyleDelete) {				
		NSString *format = @"%@/lists/%@/items/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, item.remoteId, [accessToken URLEncodeString]];
				
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		
		[ self.statusDisplay startWithTitle:@"Deleting list item..."];
				
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
	[statusDisplay release];
	[accessToken release];
	[itemList release];
	[receivedData release];
	[listItems release];
	[statusCode release];
	
    [super dealloc];
}


@end

