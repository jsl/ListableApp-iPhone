//
//  CurrentSessionController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/20/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SharedListAppDelegate.h"

@interface CurrentSessionController : UIViewController {
	IBOutlet UIButton *logoutButton;	
	IBOutlet UILabel *emailLabel;
}

- (IBAction) logoutButtonPressed:(id)sender;

@property (nonatomic, retain) UIButton *logoutButton;
@property (nonatomic, retain) UILabel *emailLabel;

@end
