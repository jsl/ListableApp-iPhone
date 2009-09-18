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

#import "StatusToolbarGenerator.h"

@implementation ListItemsController

@synthesize itemList;
@synthesize accessToken;
@synthesize receivedData;
@synthesize listItems;
@synthesize toolbar;
@synthesize inviteeEmail;
@synthesize statusCode;
@synthesize completedItems;
@synthesize activeItems;

- (void)viewDidLoad {
    [super viewDidLoad];
		
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 155, 45)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:3];
	
	// create a standard "add" button
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;
	[buttons addObject:bi];
	[bi release];
	
	// Add the share button
	bi = [[UIBarButtonItem alloc] initWithTitle:@"Editors" style:UIBarButtonItemStyleBordered target:self action:@selector(shareButtonAction:)];
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
	
	// Set toolbar title
	self.navigationItem.title = @"Items";
	
	// and put the toolbar in the nav bar
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tools];
	[tools release];
	
	
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
}

- (void) shareButtonAction:(id)sender {
	CollaboratorsController *nextController = [[CollaboratorsController alloc] initWithStyle:UITableViewStylePlain];
	
	[ nextController setItemList:self.itemList ];
	[ nextController setAccessToken:self.accessToken];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];
	
}

- (IBAction)refreshButtonAction:(id)sender {
	[ self loadItems ];
}


- (IBAction)addButtonAction:(id)sender {
	AddListItemController *nextController = [[AddListItemController alloc] initWithNibName:@"AddListItem" bundle:nil];
	
	[ nextController setAccessToken:self.accessToken ];
	[ nextController setItemList:self.itemList ];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

- (void) loadItems {
	NSString *urlString = [ NSString stringWithFormat:@"%@/lists/%@/items.json?user_credentials=%@", API_SERVER, [itemList remoteId], [self accessToken] ];

	NSURL *myURL = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
	self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Loading items..."];

	[self.parentViewController.view addSubview:self.toolbar];
	self.toolbar.hidden = NO;
	
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
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
		
	id parsedJsonObject = [jsonData JSONValue];
	
	if ([ statusCode intValue ] >= 400) {
		NSString *msg = @"Undefined error occurred while processing response";
		if ( [ parsedJsonObject respondsToSelector:@selector( objectForKey: )] == YES ) {
			msg = [ parsedJsonObject objectForKey:@"message" ];
		}
		
		msg = (NSString *)[ [jsonData JSONValue] objectForKey:@"message"];
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
														 message:msg
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		self.toolbar.hidden = YES;
		
	 	[alert show];
		[alert release];
	} else {

		// Action is based on JSON response type.  An NSDictionary means a basic message, sent in
		// response to a delete request.  An NSArray is an index request.
		if ([ statusCode intValue ] == 200) {
			if ( [ parsedJsonObject isKindOfClass:[ NSArray class ]] == YES ) {
				NSMutableArray *itms = [ self processGetResponse:parsedJsonObject ];

				self.listItems = [ itms retain ];
								
				NSLog(@"he got: %@", [ [self.listItems objectAtIndex:0] completed]);

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
				self.activeItems = [self.listItems filteredArrayUsingPredicate:activePredicate];
				
				self.toolbar.hidden = YES;
				[self.tableView reloadData];	
				
				[itms release];
				
			} else if ( [ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES ) {
				// Must have been a POST or a DELETE, no body parseable to an Array
				self.toolbar.hidden = YES;
				
				// Get new result set.
				[self loadItems];
			}
		} else {
			NSLog(@"Unusual - response code of %i and body len == %i", [statusCode intValue], [jsonData length]);
		}
	}
	
	self.toolbar.hidden = YES;
	
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

- (void)processDeleteResponse:(NSString *)jsonData {
	currentRetrievalType = Get;
	[self loadItems];
}

- (void)viewWillAppear:(BOOL)animated {
		
	/// Make floating toolbar footer
	self.toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
		
	[self loadItems];

    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
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
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
	NSArray *tmpItems = (indexPath.section == 0) ? self.activeItems : self.completedItems;
	
    // Set up the cell...
	cell.textLabel.text = [ [ tmpItems objectAtIndex:indexPath.row] name];
	
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	NSLog(@"WRITEME!!!");
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
    
	Item *item = [listItems objectAtIndex:indexPath.row];

	if (editingStyle == UITableViewCellEditingStyleDelete) {				
		NSString *format = @"%@/lists/%@/items/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId, item.remoteId, [accessToken URLEncodeString]];
				
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		
		self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Deleting list item..."];
		
		[ self.parentViewController.view addSubview:self.toolbar ];
		
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
	[statusCode release];
	
    [super dealloc];
}


@end

