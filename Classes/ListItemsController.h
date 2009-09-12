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


#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface ListItemsController : UITableViewController <ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate> {
	NSString *accessToken;
	ItemList *itemList;
	NSMutableData *receivedData;
	NSMutableArray *listItems;
	
	NSString *inviteeEmail;
	UIToolbar *toolbar;
	
	enum RetrievalTypes currentRetrievalType;
}

- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)shareButtonAction:(id)sender;

- (void)processDeleteResponse:(NSString *)jsonData;
- (void)processGetResponse:(NSString *)jsonData;
- (void)loadItems;
- (void)sendInvitationToEmail;

@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSMutableArray *listItems;

@end
