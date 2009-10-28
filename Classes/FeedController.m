//
//  FeedController.m
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "FeedController.h"

#import "URLEncode.h"
#import "Constants.h"
#import "StatusDisplay.h"
#import "SharedListAppDelegate.h"
#import "UserSettings.h"
#import "TimedURLConnection.h"
#import "Blip.h"
#import "StringHelper.h"
#import "AsyncImageView.h"
#import "ItemList.h"
#import "ListItemsController.h"

#import "ShakeableTableView.h"

@implementation FeedController

@synthesize blips;
@synthesize statusDisplay;

- (void)viewDidLoad {
	
	self.tableView = [ [ShakeableTableView alloc] init];
	[ (ShakeableTableView *)self.tableView setViewDelegate:self ];
	
	UINavigationBar *bar = [self.navigationController navigationBar]; 
	UIColor *clr = [[UIColor alloc ] initWithRed:0.518 green:0.09 blue:0.09 alpha:1];
	[bar setTintColor:	clr]; 
	[clr release];
	
	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.parentViewController.view ];
	
	self.title = @"Activity Feed";
	
	[super viewDidLoad];	
}

- (void) shakeHappened:(ShakeableTableView *)view {
	[ self loadBlips ];
}

- (void) loadBlips {
	
	NSString *format = @"%@/feed.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, [ [UserSettings sharedUserSettings].authToken URLEncodeString ]];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
	[[ [TimedURLConnection alloc] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																				delegate:self 
																		   statusDisplay:self.statusDisplay 
																		   statusMessage:@"Loading feed..."] autorelease];
}

- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)theStatusCode {
	
	if (theStatusCode == 403) {
		self.blips = [ [ NSMutableArray alloc ] init ];
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
		self.blips = [ self processGetResponse:parsedJsonObject ];
		
	} else if ([ parsedJsonObject isKindOfClass:[ NSDictionary class ]] == YES) {
		// Must have been a POST or a DELETE, no body parseable to an Array.  Just get new result set.
		[self loadBlips];
	}
	
	[ self.tableView reloadData ];
}

// Iterate through response data and set table items appropriately.
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray {	
	
	NSLog(@"resp was %@", jsonArray);
	NSMutableArray *tmpItems = [ [[NSMutableArray alloc] init] autorelease ];
	
	for (id setObject in jsonArray) {
		Blip *b = [ [Blip alloc] init];
		[b setOriginatingUsername:[setObject objectForKey:@"originating_username"]];
		[b setUserImage:[setObject objectForKey:@"user_image"]];
		[b setMessage:[setObject objectForKey:@"message"]];

		[b setTimeAgo:[NSString stringWithFormat:@"%@ ago", [setObject objectForKey:@"time_ago"]]];
		
		ItemList *il = [[ItemList alloc] init];
		[il setName: [ [ setObject objectForKey:@"list" ] objectForKey:@"name"] ];
		[il setRemoteId: [ [ setObject objectForKey:@"list" ] objectForKey:@"id"] ];
		
		[b setItemList:il ];
		
		[il release];
		
		[tmpItems addObject:b];
		
		[ b release ];
	}
	
	return tmpItems;
}

- (void)processDeleteResponse:(NSString *)jsonData {
	[self loadBlips];
}

- (void)viewWillAppear:(BOOL)animated {
	[self.tableView becomeFirstResponder];
	
	[ self loadBlips ];
	
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
    return [ [self blips] count];
}

- (UITableViewCell *) getCellContentView:(NSString *)cellIdentifier {
	
	CGRect CellFrame = CGRectMake(0, 0, 300, 60);
	
	
	CGRect lblFrame1 = CGRectMake(60, 10, 240, 25);
	UILabel *lblTemp;
	
	UITableViewCell *cell = [[[UITableViewCell alloc] initWithFrame:CellFrame reuseIdentifier:cellIdentifier] autorelease];
	
	//Initialize Label with tag 1.
	lblTemp = [[UILabel alloc] initWithFrame:lblFrame1];
	lblTemp.tag = 1;
	
	[cell.contentView addSubview:lblTemp];
	[lblTemp release];
	
	//Initialize Label with tag 2.
	
	return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	Blip *b = [self.blips objectAtIndex:indexPath.row];
	return [b.message RAD_textHeightForSystemFontOfSize:kTextViewFontSize] + 30;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Blip *b = [self.blips objectAtIndex:indexPath.row];
	
	static NSString *CellIdentifier = @"FeedElementCell";
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

	if ( cell == nil ) {
		NSLog(@"Cell was nil");
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	
	} else {
		UIView *vw;
		vw = [cell viewWithTag:1];
		[vw removeFromSuperview];
		
		vw = [cell viewWithTag:2];
		[vw removeFromSuperview];
		
		vw = [cell viewWithTag:999];
		[vw removeFromSuperview];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	NSString *format = @"http://www.gravatar.com/avatar/%@?s=30";
	NSString *myUrlStr = [NSString stringWithFormat:format, b.userImage];
	
	NSURL *url = [NSURL URLWithString:myUrlStr ];

	CGRect ImageFrame = CGRectMake(10, 10, 30, 30);

	AsyncImageView* asyncImage = [[[AsyncImageView alloc] initWithFrame:ImageFrame] autorelease];
	
	asyncImage.tag = 999;
	
	[asyncImage loadImageFromURL:url];
	
	UILabel *msgLabel = [b.message RAD_newSizedCellLabelWithSystemFontOfSize:kTextViewFontSize x_pos:60.0f y_pos:10.0f];
	
	msgLabel.numberOfLines = 0;
	msgLabel.lineBreakMode = UILineBreakModeWordWrap;
	msgLabel.tag = 1;
	
	[cell addSubview:msgLabel];
	
	msgLabel.text = b.message;

	UILabel *lblTemp2 = [[UILabel alloc] initWithFrame:CGRectMake(60, msgLabel.frame.size.height + 5, 240, 25)];
	lblTemp2.tag = 2;
	lblTemp2.font = [UIFont boldSystemFontOfSize:12];
	lblTemp2.textColor = [UIColor lightGrayColor];
	[cell.contentView addSubview:lblTemp2];
	[lblTemp2 release];
	
	lblTemp2.text = b.timeAgo;
	
	[cell.contentView addSubview:asyncImage];

	[ cell layoutSubviews ];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	Blip *b = [self.blips objectAtIndex:indexPath.row];

	[tableView deselectRowAtIndexPath:indexPath animated:NO];
		
	ListItemsController *nextController = [[ListItemsController alloc] initWithStyle:UITableViewStylePlain];
	
	[ nextController setItemList:b.itemList ];
	
	[[self navigationController] pushViewController:nextController animated:YES];
	[nextController release];	
}

- (void)dealloc {
	[blips release];
	[statusDisplay release];
	
    [super dealloc];
}


@end

