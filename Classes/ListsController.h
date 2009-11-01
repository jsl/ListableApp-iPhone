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
#import "ItemList.h"
#import "ShakeDelegate.h"

@interface ListsController : UITableViewController <TimedConnection, ShakeDelegate> {
	NSMutableArray *lists;

	StatusDisplay *statusDisplay;
}

- (void) loadLists;
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray;
- (void) shakeHappened: (ShakeableTableView *)view;
- (void)alertOnHTTPFailure;
- (void) renderSuccessJSONResponse: (id)parsedJsonObject;
- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode;
- (void) editListButtonAction:(id)sender;
- (void) moveLink: (ItemList *)list toPosition:(NSNumber *)position;

@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) NSMutableArray *lists;

@end
