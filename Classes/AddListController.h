//
//  AddListController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AddListController : UIViewController <UITextFieldDelegate> {
	IBOutlet UIButton *doneButton;
	IBOutlet UITextField *listNameTextField;
	
	NSString *accessToken;
	NSMutableData *receivedData;
}

- (IBAction) doneButtonPressed: (id)sender;
- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSMutableData *receivedData;

@property (nonatomic, retain) IBOutlet UITextField *listNameTextField;

@end

