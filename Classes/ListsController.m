//
//  ListsController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
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

#import "ShakeableTableView.h"

@implementation ListsController

@synthesize lists;
@synthesize statusDisplay;

- (void)viewDidLoad {

	self.tableView = [ [ShakeableTableView alloc] init];
	[ (ShakeableTableView *)self.tableView setViewDelegate:self ];
	
	// create a standard "add" button
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addButtonAction:)];
	bi.style = UIBarButtonItemStyleBordered;		
	self.navigationItem.rightBarButtonItem = bi;
	[bi release];

	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.parentViewController.view ];
	
	self.title = @"Lists";
	
	[super viewDidLoad];	
}

- (IBAction)addButtonAction:(id)sender {
	AddListController *nextController = [[AddListController alloc] initWithNibName:@"AddList" bundle:nil];
		
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

-(void) shakeHappened:(ShakeableTableView *)view {
	[ self loadLists ];
}

- (void) loadLists {
	
	NSString *format = @"%@/lists.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, [ [UserSettings sharedUserSettings].authToken URLEncodeString ]];

	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
	[ [TimedURLConnection alloc] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																			   delegate:self 
																		  statusDisplay:self.statusDisplay 
																		  statusMessage:@"Loading lists..."];
}

- (void)alertOnHTTPFailure {
	NSString *msg = @"HTTP Failure";
	
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"HTTP Failure, whoops!"
													 message:msg
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	[alert show];
	[alert release];		
	
}

- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)theStatusCode {

	if (theStatusCode == 403) {
		self.lists = [ [ NSMutableArray alloc ] init ];
		[ self.tableView reloadData ];
	}
	
	if ([ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES) {
		NSString *msg = (NSString *)[parsedJsonObject objectForKey:@"message"];
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
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
		// Must have been a POST or a DELETE, no body parseable to an Array.  Just get new result set.
		[self loadLists];
	}
	
	[ self.tableView reloadData ];
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {	
	NSMutableArray *tmpItems = [ [[NSMutableArray alloc] init] autorelease ];

	for (id setObject in jsonArray) {
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
	[self.tableView becomeFirstResponder];
	
	[ self loadLists ];

    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/

- (void)viewWillDisappear:(BOOL)animated {
	[self resignFirstResponder];

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

/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

/*
- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}
*/

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
		if (!UIAppDelegate.ableToConnectToHostWithAlert)
			return;

		NSString *format = @"%@/lists/%@.json?user_credentials=%@";
		NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, 
							  l.remoteId, [[UserSettings sharedUserSettings].authToken URLEncodeString]];
				
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
				
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		[ request setHTTPMethod:@"DELETE" ];
		
		[ [ TimedURLConnection alloc ] initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request 
																						 delegate:self 
																					statusDisplay:self.statusDisplay 
																					statusMessage:@"Deleting list..." ];
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
	[lists release];
	[statusDisplay release];
	
    [super dealloc];
}


@end

