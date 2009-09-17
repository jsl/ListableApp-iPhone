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


@interface CollaboratorsController : UITableViewController <ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate> {
	NSMutableArray *collaborators;
	NSString *inviteeEmail;
	NSString *accessToken;
	ItemList *itemList;
	NSMutableData *receivedData;
	UIToolbar *toolbar;

	NSNumber *statusCode;
	
	enum RetrievalTypes currentRetrievalType;
}

- (void)sendInvitationToEmail;
- (void) alertEmailWillBeSent;
- (NSMutableArray *)processGetResponse:(NSString *)jsonData;
- (void) loadItems;
- (IBAction)refreshButtonAction:(id)sender;
- (IBAction)addButtonAction:(id)sender;

@property (nonatomic, retain) NSMutableArray *collaborators;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) NSNumber *statusCode;

@end
