//
//  ListsController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ListsController.h"
#import "ListItemsController.h"

#import "JSON.h"
#import "ItemList.h"
#import "AddListController.h"
#import "URLEncode.h"
#import "Constants.h"
#import "StatusToolbarGenerator.h"

@implementation ListsController

@synthesize accessToken;
@synthesize receivedData;
@synthesize lists;
@synthesize statusCode;
@synthesize toolbar;

- (void)viewDidLoad {
	// create a toolbar to have two buttons in the right
	UIToolbar* tools = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 80, 45)];
	
	// create the array to hold the buttons, which then gets added to the toolbar
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
	
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
	
	self.title = @"Lists";
		
	if ([self accessToken] == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" 
														message:@"Since this is the first time you've run Shared List, you must configure your account under \"Settings\"."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
	
	[super viewDidLoad];	
}

- (IBAction)addButtonAction:(id)sender {
	AddListController *nextController = [[AddListController alloc] initWithNibName:@"AddList" bundle:nil];
	
	[ nextController setAccessToken:self.accessToken];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

- (IBAction)refreshButtonAction:(id)sender {
	[ self loadLists ];
}

- (void) loadLists {
	currentRetrievalType = Get;
	
	NSString *format = @"%@/lists.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, [self accessToken]];
	
	self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Loading items..."];
	
	[self.parentViewController.view addSubview:self.toolbar];
	self.toolbar.hidden = NO;	
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 	
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
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
	
	if ([ statusCode intValue ] >= 400) {
		
		// If we get a 
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
														 message:jsonData
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		self.toolbar.hidden = YES;
		
	 	[alert show];
		[alert release];
	} else {
		
		// Try getting items from response if the body isn't empty and the code is 200
		if ([ statusCode intValue ] == 200) {
			if ( [ jsonData length] > 0) {
				self.lists = [ self processGetResponse:jsonData ];
				
				self.toolbar.hidden = YES;
				[self.tableView reloadData];				
				
			} else if ([ jsonData length] == 0) {
				// Must have been a POST or a DELETE, no body parseable to an Array
				self.toolbar.hidden = YES;
				
				// Get new result set.
				[self loadLists];
			}
		} else {
			NSLog(@"Unusual - response code of %i and body len == %i", [statusCode intValue], [jsonData length]);
		}
	}
	
	self.toolbar.hidden = YES;
	
	[self.tableView reloadData];
	
	[jsonData release];
    [connection release];	
	
	[self.tableView reloadData];
}


// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSString *)jsonData {	
	NSMutableArray *tmpItems = [[NSMutableArray alloc] init];
	NSMutableArray *listNames = [jsonData JSONValue];

	for (id setObject in listNames) {
		ItemList *l = [ [ItemList alloc] init];
		[l setName:[setObject objectForKey:@"name"]];
		[l setRemoteId:[setObject objectForKey:@"id"]];
		
		[tmpItems addObject:l];
	}
		
	return tmpItems;
}

- (void)processDeleteResponse:(NSString *)jsonData {
	[self loadLists];
}

- (void)viewWillAppear:(BOOL)animated {
	
	if ([self accessToken] != nil)	
		[self loadLists];

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
    [super didReceiveMemoryWarning];
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
    return [ [self lists] count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	cell.textLabel.text = [ [ [self lists] objectAtIndex:indexPath.row] name];
	
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	
	ItemList *l = [lists objectAtIndex:indexPath.row];
		
	ListItemsController *nextController = [[ListItemsController alloc] initWithStyle:UITableViewStylePlain];
	
	[ nextController setItemList:l ];
	[ nextController setAccessToken:self.accessToken];
	
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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	ItemList *l = [lists objectAtIndex:indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {		
		NSString *format = @"%@/lists/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, l.remoteId, [accessToken URLEncodeString]];
		
		self.toolbar = [ [ [StatusToolbarGenerator alloc] initWithView:self.parentViewController.view] toolbarWithTitle:@"Deleting list..."];
		[ self.parentViewController.view addSubview:self.toolbar ];

		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		currentRetrievalType = Delete;
		
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
	[statusCode release];
	[accessToken release];
	[receivedData release];
	[lists release];
	[toolbar release];
	
    [super dealloc];
}


@end

