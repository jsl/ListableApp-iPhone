//
//  ListsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "StatusDisplay.h"
#import "ShakeableTableView.h"
#import "SharedListAppDelegate.h"
#import "TimedConnection.h"
#import "ShakeDelegate.h"

@interface FeedController : UITableViewController <TimedConnection, ShakeDelegate> {
	NSMutableArray *blips;
	
	StatusDisplay *statusDisplay;
}

- (void) loadBlips;
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray;
- (void) shakeHappened: (ShakeableTableView *)view;
- (void) renderSuccessJSONResponse: (id)parsedJsonObject;
- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode;

@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) NSMutableArray *blips;

@end
