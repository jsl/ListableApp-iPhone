//
//  ListItemsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ItemList.h"

@interface ListItemsController : UITableViewController {
	NSString *accessToken;
	ItemList *itemList;
	NSMutableData *receivedData;
	NSMutableArray *listItems;
}

- (void) loadItems;

@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *listItems;

@end
