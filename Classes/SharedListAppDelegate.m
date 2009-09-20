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

@implementation SharedListAppDelegate

@synthesize window;
@synthesize tabBarController;
@synthesize isTokenValid;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	NSString *authtoken = [self accessToken];
	
	if (! (authtoken == nil )) {
		// We have an auth token, check it and direct to appropriate page based on whether the token is valid or not.
		isTokenValid = [ [ [ AuthenticationChecker alloc ] init ] isTokenValid:authtoken ];
		[self configureTabBarWithLoggedInState:isTokenValid];

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

