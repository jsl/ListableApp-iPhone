//
//  SharedListAppDelegate.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SharedListAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    UIWindow *window;
    UITabBarController *tabBarController;
	
	BOOL isTokenValid;
}

- (NSString *)accessToken;
- (void)configureTabBarWithLoggedInState:(BOOL)isLoggedIn;
- (BOOL)ableToConnect;
- (BOOL)ableToConnectToHostWithAlert;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic) BOOL isTokenValid;

@end
