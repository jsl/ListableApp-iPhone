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

@interface ListItemsController : UITableViewController <UIAlertViewDelegate> {
	NSString *accessToken;
	ItemList *itemList;
	NSMutableData *receivedData;
	NSMutableArray *listItems;
	NSNumber *statusCode;
	
	NSString *inviteeEmail;
	UIToolbar *toolbar;
	
	enum RetrievalTypes currentRetrievalType;
}

- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;

- (void) processDeleteResponse:(NSString *)jsonData;
- (NSMutableArray *) processGetResponse:(NSString *)jsonData;
- (void) loadItems;

@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *listItems;

@end
