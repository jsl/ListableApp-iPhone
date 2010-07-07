//
//  AccountSettingsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedListAppDelegate.h"

@interface AccountSettingsController : UIViewController <UITextFieldDelegate> {
	IBOutlet UIButton *checkAccountButton;
	IBOutlet UIButton *createAccountButton;
	IBOutlet UIButton *resetPasswordButton;
	
	IBOutlet UITextField *loginTextField;
	IBOutlet UITextField *passwordTextField;
	
	NSMutableData *receivedData;
	NSDictionary *authResponse;
	NSURLConnection *connection;
		
	NSNumber *statusCode;
}

- (IBAction) checkAccountButtonPressed:(id)sender;
- (IBAction) createAccountButtonPressed:(id)sender;
- (IBAction) resetPasswordButtonPressed:(id)sender;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDictionary *authResponse;

@property (nonatomic, retain) IBOutlet UITextField *loginTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) NSURLConnection *connection;

@property (nonatomic, retain) IBOutlet UIButton *checkAccountButton;
@property (nonatomic, retain) IBOutlet UIButton *createAccountButton;
@property (nonatomic, retain) IBOutlet UIButton *resetPasswordButton;

@property (nonatomic, retain) NSNumber *statusCode;

@end
