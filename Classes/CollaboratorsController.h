//
//  CollaboratorsController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

#import "ItemList.h"
#import "Constants.h"
#import "Collaborator.h"
#import "StatusDisplay.h"
#import "ShakeableTableView.h"

@interface CollaboratorsController : UITableViewController <ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate> {
	NSMutableArray *collaborators;
	NSString *inviteeEmail;
	NSString *accessToken;
	ItemList *itemList;
	NSMutableData *receivedData;

	NSNumber *statusCode;
	
	StatusDisplay *statusDisplay;
}

- (void)sendInvitationToEmail;
- (void) alertEmailWillBeSent;
- (NSMutableArray *)processGetResponse:(NSArray *)jsonArray;
- (void) loadItems;
- (IBAction)addButtonAction:(id)sender;
- (void) shakeHappened:(ShakeableTableView *)view;

@property (nonatomic, retain) NSMutableArray *collaborators;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) StatusDisplay *statusDisplay;

@end
