//
//  AccountSettingsController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AccountSettingsController : UIViewController <UITextFieldDelegate> {
	IBOutlet UIButton *checkAccountButton;
	
	IBOutlet UITextField *emailTextField;
	IBOutlet UITextField *passwordTextField;
	IBOutlet UIView *statusView;
	
	NSMutableData *receivedData;
	NSDictionary *authResponse;
	
	NSNumber *statusCode;
}

- (IBAction) checkAccountButtonPressed:(id)sender;
- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDictionary *authResponse;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;
@property (nonatomic, retain) IBOutlet UIView *statusView;

@property (nonatomic, retain) NSNumber *statusCode;

@end
