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

	NSMutableData *receivedData;
	NSDictionary *authResponse;
}

- (IBAction) checkAccountButtonPressed:(id)sender;
- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) NSDictionary *authResponse;
@property (nonatomic, retain) IBOutlet UITextField *emailTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@end
