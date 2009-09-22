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
#import "TimedConnection.h"

@interface CollaboratorsController : UITableViewController <ABPeoplePickerNavigationControllerDelegate, UIAlertViewDelegate, TimedConnection> {
	NSMutableArray *collaborators;
	NSString *inviteeEmail;
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

- (void) renderSuccessJSONResponse: (id)parsedJsonObject;
- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode;

@property (nonatomic, retain) NSMutableArray *collaborators;
@property (nonatomic, retain) NSString *inviteeEmail;
@property (nonatomic, retain) ItemList *itemList;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) StatusDisplay *statusDisplay;

@end
