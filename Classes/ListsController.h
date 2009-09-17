//
//  ListsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface ListsController : UITableViewController {
	NSString *accessToken;
	NSMutableData *receivedData;
	NSMutableArray *lists;
	NSNumber *statusCode;
	
	UIToolbar *toolbar;
	
	enum RetrievalTypes currentRetrievalType;
}

- (void) loadLists;
- (NSMutableArray *)processGetResponse:(NSString *)jsonData;
- (void)processDeleteResponse:(NSString *)jsonData;
- (IBAction)refreshButtonAction:(id)sender;

@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *lists;

@end
