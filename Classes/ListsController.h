//
//  ListsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "StatusDisplay.h"
#import "ShakeableTableView.h"
#import "SharedListAppDelegate.h"

@interface ListsController : UITableViewController {
	NSString *accessToken;
	NSMutableData *receivedData;
	NSMutableArray *lists;
	NSNumber *statusCode;

	SharedListAppDelegate *appDelegate;
	StatusDisplay *statusDisplay;
}

- (void) loadLists;
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray;
- (void)processDeleteResponse:(NSString *)jsonData;
- (void) shakeHappened: (ShakeableTableView *)view;

@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *lists;
@property (nonatomic, retain) SharedListAppDelegate *appDelegate;

@end
