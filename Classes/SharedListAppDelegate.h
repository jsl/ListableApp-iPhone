//
//  SharedListAppDelegate.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright Stack Builders Inc. 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TimedConnection.h"

#define UIAppDelegate ((SharedListAppDelegate *)[UIApplication sharedApplication].delegate)

@interface SharedListAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate, TimedConnection> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	BOOL isTokenValid;
}

- (void)configureTabBarWithLoggedInState:(BOOL)isLoggedIn;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) BOOL isTokenValid;

@end
