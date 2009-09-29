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

@interface ListItemsController : UITableViewController <UIAlertViewDelegate, TimedConnection> {
	ItemList *itemList;
	
	NSMutableArray *listItems;
	NSMutableArray *completedItems;
	NSMutableArray *activeItems;	
		
	NSString *inviteeEmail;
	StatusDisplay *statusDisplay;
	
	BOOL loadingWithUpdate;
}

- (IBAction)shareButtonAction:(id)sender;
- (IBAction)editListButtonAction:(id)sender;

- (NSMutableArray *) processGetResponse:(NSArray *)jsonArray;
- (void) loadItems;
- (void)toggleCompletedStateForItem:(Item *)item;
- (void)updateListName: (ItemList *)list name:(NSString *)name;
- (void)updateAttributeOnItem: (Item *)item attribute:(NSString *)attribute newValue:(NSString *)newValue displayMessage:(NSString *)displayMessage;
- (void) addListItemWithName:(NSString *) name;
- (void) shakeHappened:(ShakeableTableView *)view;
- (void) editListTitleAction:(id)sender;
- (Item *)itemAtIndexPath:(NSIndexPath *)indexPath;
- (void) populateCompletedAndActiveItems;

@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) NSMutableArray *listItems;
@property (nonatomic, retain) NSMutableArray *completedItems;
@property (nonatomic, retain) NSMutableArray *activeItems;
@property (nonatomic) BOOL loadingWithUpdate;

@end
