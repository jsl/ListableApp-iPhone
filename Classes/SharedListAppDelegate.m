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
@synthesize authToken;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[UserSettings sharedUserSettings].authToken = [ [NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
	
	self.authToken =  [ [NSUserDefaults standardUserDefaults] objectForKey:@"accessToken"];
	
	if (! (self.authToken == nil ) ) {
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
	return YES;
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
	[authToken release];
    [tabBarController release];
    [window release];
	
    [super dealloc];
}

@end

