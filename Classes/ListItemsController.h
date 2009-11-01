//
//  ListItemsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemList.h"
#import "Constants.h"
#import "Item.h"
#import "StatusDisplay.h"
#import "ShakeableTableView.h"
#import "TimedConnection.h"
#import "ShakeDelegate.h"

@interface ListItemsController : UITableViewController <UIAlertViewDelegate, TimedConnection, ShakeDelegate> {
	ItemList *itemList;
	
	NSMutableArray *listItems;

	NSString *inviteeEmail;
	StatusDisplay *statusDisplay;
	
	NSPredicate *completedPredicate;
	NSPredicate *activePredicate;
	BOOL recentlyAddedItem;
}

- (IBAction)shareButtonAction:(id)sender;
- (IBAction)editListButtonAction:(id)sender;

- (NSArray *)itemArrayInSection:(NSInteger)section;
- (Item *)itemAtIndexPath:(NSIndexPath *)indexPath;

- (NSMutableArray *) processGetResponse:(NSArray *)jsonArray;
- (void) loadItems;
- (void) toggleCompletedStateForItem:(Item *)item;
- (void) updateListName: (ItemList *)list name:(NSString *)name;
- (void) updateAttributeOnItem: (Item *)item attribute:(NSString *)attribute newValue:(NSString *)newValue displayMessage:(NSString *)displayMessage;
- (void) addListItemWithName:(NSString *) name;
- (void) shakeHappened:(ShakeableTableView *)view;
- (void) editListTitleAction:(id)sender;

@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) NSMutableArray *listItems;
@property (nonatomic, retain) NSPredicate *activePredicate;
@property (nonatomic, retain) NSPredicate *completedPredicate;

@end
