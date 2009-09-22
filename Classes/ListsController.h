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
#import "TimedConnection.h"

@interface ListsController : UITableViewController <TimedConnection> {
	NSMutableData *receivedData;
	NSMutableArray *lists;
	NSNumber *statusCode;

	StatusDisplay *statusDisplay;
}

- (void) loadLists;
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray;
- (void)processDeleteResponse:(NSString *)jsonData;
- (void) shakeHappened: (ShakeableTableView *)view;
- (void)alertOnHTTPFailure;
- (void) renderSuccessJSONResponse: (id)parsedJsonObject;
- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode;

@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *lists;

@end
