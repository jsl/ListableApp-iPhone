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

@implementation ListsController

@synthesize accessToken;
@synthesize receivedData;
@synthesize lists;


- (void)viewDidLoad {	
	
	//
    // Create a header view. Wrap it in a container to allow us to position
    // it better.
    //
    UIView *containerView =
	[[[UIView alloc]
	  initWithFrame:CGRectMake(0, 0, 300, 60)]
	 autorelease];
    UILabel *headerLabel =
	[[[UILabel alloc]
	  initWithFrame:CGRectMake(10, 20, 300, 40)]
	 autorelease];
    headerLabel.text = NSLocalizedString(@"Your Lists", @"");
    headerLabel.textColor = [UIColor blackColor];
    headerLabel.shadowColor = [UIColor grayColor];
    headerLabel.shadowOffset = CGSizeMake(0, 1);
    headerLabel.font = [UIFont boldSystemFontOfSize:22];
    headerLabel.backgroundColor = [UIColor clearColor];
    [containerView addSubview:headerLabel];
    self.tableView.tableHeaderView = containerView;	
	
	// End crazy header
	
    [super viewDidLoad];

	UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addButtonAction:)];
	
	self.title = @"Lists";
	
	[self.navigationItem setRightBarButtonItem:addButton];
		
	if ([self accessToken] == nil) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome!" 
													message:@"Since this is the first time you've run Shared List, you must configure your account under \"Settings\"."
													delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
	}
}

- (IBAction)addButtonAction:(id)sender {
	AddListController *nextController = [[AddListController alloc] initWithNibName:@"AddList" bundle:nil];
	
	[ nextController setAccessToken:self.accessToken];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

- (void) loadLists {
	currentRetrievalType = Get;
	
	NSString *format = @"%@/lists.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, [self accessToken]];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 	
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
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
	
	[connection release];
	
	switch (currentRetrievalType) {
		case Get:
			[ self processGetResponse:jsonData ];
			break;
		case Delete:
			[ self processDeleteResponse:jsonData ];
			break;
		default:
			break;
	}	
	
	[jsonData release];
	
	[self.tableView reloadData];
}


// Iterate through response data and set table items appropriately.
- (void)processGetResponse:(NSString *)jsonData {
	self.lists = [NSMutableArray new];

	NSMutableArray *listNames = [jsonData JSONValue];

	for (id setObject in listNames) {
		ItemList *l = [ [ItemList alloc] init];
		[l setName:[setObject objectForKey:@"name"]];
		[l setRemoteId:[setObject objectForKey:@"id"]];
		
		[self.lists addObject:l];
	}	
}

- (void)processDeleteResponse:(NSString *)jsonData {
	NSLog(@"Proc del resp, data is %@", jsonData);
	[self loadLists];
}

- (void)viewWillAppear:(BOOL)animated {
	
	UIImage *backgroundImage = [UIImage imageNamed:@"gradientBackground.png"];
	UIColor *backgroundColor = [[UIColor alloc] initWithPatternImage:backgroundImage];
	self.tableView.backgroundColor = backgroundColor;
	[backgroundColor release];
	
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


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
	ItemList *l = [lists objectAtIndex:indexPath.row];
	
	if (editingStyle == UITableViewCellEditingStyleDelete) {		
		NSString *format = @"%@/lists/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, l.remoteId, [accessToken URLEncodeString]];
		
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
	[accessToken release];
	[receivedData release];
	[lists release];
	
    [super dealloc];
}


@end

