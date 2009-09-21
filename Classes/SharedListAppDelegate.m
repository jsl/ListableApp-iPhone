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

#import <SystemConfiguration/SCNetworkReachability.h>

@implementation SharedListAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize isTokenValid;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSString *authtoken = [self accessToken];
	
	if (! (authtoken == nil ) ) {
		[self configureTabBarWithLoggedInState:YES];

		// Add the tab bar controller's current view as a subview of the window
		[window addSubview:tabBarController.view];

	} else {
		[self configureTabBarWithLoggedInState:NO];

		self.tabBarController.selectedIndex = 1;

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

// If unable to connect display a standard notice.  Returns bool indicating whether
// or not the connection was available so that the caller can take appropriate action.
- (BOOL)ableToConnectToHostWithAlert {
	BOOL serverReachable = [self ableToConnect];
		
	if (! serverReachable ) {
		NSString *msg = @"Listable is unable to connect to the server.  Please make sure that your device is able to access the internet and try again.  If problems persist, please contact support@listableapp.com for help.";
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to connect to ListableApp.com"
														 message:msg
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		[alert show];
		[alert release];		
	}
	
	return serverReachable;
}

-(BOOL)ableToConnect {
	BOOL connected;
	const char *host = [API_SERVER UTF8String];
	SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, host);
	SCNetworkReachabilityFlags flags;
	connected = SCNetworkReachabilityGetFlags(reachability, &flags);
	BOOL isConnected = connected &&	(flags & kSCNetworkFlagsReachable) && !(flags & kSCNetworkFlagsConnectionRequired);
	CFRelease(reachability);
	
	return isConnected;
}

- (void)configureTabBarWithLoggedInState:(BOOL)isLoggedIn {
	ListsController *listsController = [[[ListsController alloc] initWithNibName:nil bundle:nil] autorelease];
	
	UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:listsController];
	rootNavigationController.tabBarItem.title = @"Lists";
	rootNavigationController.tabBarItem.image = [UIImage imageNamed:@"tabbar_checkmark.png"];

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
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:rootNavigationController, accountController, nil];	
}

// Load settings from persistent storage.
-(NSString *)accessToken {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	return [prefs objectForKey:@"accessToken"];
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

