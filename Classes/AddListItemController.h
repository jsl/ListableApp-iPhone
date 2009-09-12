//
//  AddListItemController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemList.h"

@interface AddListItemController : UIViewController {
	IBOutlet UIButton *doneButton;
	IBOutlet UITextField *listItemNameTextField;
	
	NSString *accessToken;
	NSMutableData *receivedData;	
	
	ItemList *itemList;
}

- (IBAction) doneButtonPressed: (id)sender;
- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) ItemList *itemList;

@property (nonatomic, retain) IBOutlet UITextField *listItemNameTextField;

@end


