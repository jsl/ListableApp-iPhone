//
//  SharedListAppDelegate.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "SharedListAppDelegate.h"
#import "ListsController.h"
#import "AccountSettingsController.h"
#import <AddressBook/AddressBook.h>
#import "AuthenticationChecker.h"
#import "ShakeableTableView.h"
#import "CurrentSessionController.h"
#import "UserSettings.h"
#import "TimedURLConnection.h"
#import "FeedController.h"

#import "Constants.h"
#import "URLEncode.h"

#import <SystemConfiguration/SCNetworkReachability.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>

@implementation SharedListAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize isTokenValid;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[UserSettings sharedUserSettings].authToken = [ [NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
		
	if ( [UserSettings sharedUserSettings].authToken != nil ) {
		[self configureTabBarWithLoggedInState:YES];

		// Add the tab bar controller's current view as a subview of the window
		[window addSubview:tabBarController.view];

		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert)];
		
		
		application.applicationIconBadgeNumber = 0;
		
	} else {
		[self configureTabBarWithLoggedInState:NO];

		self.tabBarController.selectedIndex = 2;

		// Add the tab bar controller's current view as a subview of the window
		[window addSubview:tabBarController.view];

		// First time user has loaded app, provide nice message and direct to login page
		NSString *msg = @"Thanks for installing Listable!  Before making lists, we have to set you up with a valid account.  While this should be a short process for most users, if you have any trouble, contact us at support@listableapp.com and we'll help you along.  Thanks!";
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Welcome to Listable!" 
														 message:msg
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		[alert show];
		[alert release];
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];

	if (!apsInfo.count)
		return;
	
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Update"
													 message:[apsInfo objectForKey:@"alert"]
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	[alert show];
	[alert release];			
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)devToken {
	NSString *format = @"%@/device_token.json?device_token=%@&user_credentials=%@";
	
	if ( [UserSettings sharedUserSettings].authToken != nil ) {
		NSString *deviceToken = [[devToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
		deviceToken = [deviceToken stringByReplacingOccurrencesOfString:@" " withString:@""];

		NSString *myUrlStr = [ NSString stringWithFormat:format, 
							  API_SERVER,
							  [ deviceToken URLEncodeString ], 
							  [ [UserSettings sharedUserSettings].authToken URLEncodeString] ];
		
		NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
		NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
		
		[ request setHTTPMethod:@"PUT" ];
		
		[[ [ TimedURLConnection alloc ] initWithRequest:request ] autorelease ];		
	}
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
	// XXX do something here???
}

- (void) renderSuccessJSONResponse: (id)parsedJsonObject {	
}

- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode {
}

- (void)configureTabBarWithLoggedInState:(BOOL)isLoggedIn {
	ListsController *listsController = [[[ListsController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:listsController];
	rootNavigationController.tabBarItem.title = @"Lists";
	rootNavigationController.tabBarItem.image = [UIImage imageNamed:@"tabbar_checkmark.png"];

	
	FeedController *feedController = [[[FeedController alloc] initWithNibName:nil bundle:nil] autorelease];
	UINavigationController *feedNavigationController = [[UINavigationController alloc] initWithRootViewController:feedController];
	feedNavigationController.tabBarItem.title = @"Feed";
	feedNavigationController.tabBarItem.image = [UIImage imageNamed:@"TabBarFeeds.png"];
	
	UIViewController *accountController;
	
	if (isLoggedIn) {
		accountController = [ [ [ CurrentSessionController alloc] initWithNibName:nil bundle:nil ] autorelease ];
		self.tabBarController.selectedIndex = 0;
	} else {
		accountController = [ [ [AccountSettingsController alloc] initWithNibName:nil bundle:nil] autorelease];
		self.tabBarController.selectedIndex = 1;
	}
	
	accountController.tabBarItem.title = @"Account";
	accountController.tabBarItem.image = [UIImage imageNamed:@"tabbar_key.png"];
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:rootNavigationController, feedNavigationController, accountController, nil];	
	[ feedNavigationController release ];
	[ rootNavigationController release ];
}

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
	
    [super dealloc];
}

@end

