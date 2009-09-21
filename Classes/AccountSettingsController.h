//
//  AccountSettingsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedListAppDelegate.h"

@interface AccountSettingsController : UIViewController <UITextFieldDelegate> {
	IBOutlet UIButton *checkAccountButton;
	IBOutlet UIButton *createAccountButton;
	
	IBOutlet UITextField *emailTextField;
	IBOutlet UITextField *passwordTextField;
	
	NSMutableData *receivedData;
	NSDictionary *authResponse;
	
	SharedListAppDelegate *appDelegate;
	
	NSNumber *statusCode;
}

- (IBAction) checkAccountButtonPressed:(id)sender;
- (IBAction) createAccountButtonPressed:(id)sender;

- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDictionary *authResponse;

@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@property (nonatomic, retain) SharedListAppDelegate *appDelegate;

@property (nonatomic, retain) IBOutlet UIButton *checkAccountButton;
@property (nonatomic, retain) IBOutlet UIButton *createAccountButton;

@property (nonatomic, retain) NSNumber *statusCode;

@end
