//
//  ListsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ListsController : UITableViewController {
	NSString *accessToken;
	NSMutableData *receivedData;
	NSMutableArray *lists;
}

- (void) loadLists;

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *lists;

@end
