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
	
	NSMutableData *receivedData;
	NSNumber *statusCode;
}

- (IBAction) doneButtonPressed: (id)sender;
- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) IBOutlet UITextField *listNameTextField;
@property (nonatomic, retain) NSNumber *statusCode;

@end

