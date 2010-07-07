//
//  AddListController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimedConnection.h"
#import "StatusDisplay.h"

@interface AddListController : UIViewController <UITextFieldDelegate, TimedConnection> {
	IBOutlet UIButton *doneButton;
	IBOutlet UITextField *listNameTextField;	
	
	StatusDisplay *statusDisplay;
}

- (IBAction) doneButtonPressed: (id)sender;
- (IBAction) dismissKeyboard: (id)sender;

- (void) renderSuccessJSONResponse: (id)parsedJsonObject;
- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode;

@property (nonatomic, retain) IBOutlet UITextField *listNameTextField;
@property (nonatomic, retain) StatusDisplay *statusDisplay;

@end

