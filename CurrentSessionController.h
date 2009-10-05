//
//  CurrentSessionController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/20/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedListAppDelegate.h"
#import "StatusDisplay.h"

@interface CurrentSessionController : UIViewController {
	IBOutlet UIButton *logoutButton;	
	IBOutlet UIButton *changePlanButton;	

	IBOutlet UILabel *emailLabel;
	StatusDisplay *statusDisplay;
}

- (IBAction) logoutButtonPressed:(id)sender;
- (IBAction) changePlanButtonPressed:(id)sender;

@property (nonatomic, retain) UIButton *logoutButton;
@property (nonatomic, retain) UIButton *changePlanButton;
@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic, retain) UILabel *emailLabel;

@end
