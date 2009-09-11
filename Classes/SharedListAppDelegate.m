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

@implementation SharedListAppDelegate

@synthesize window;
@synthesize tabBarController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    // Add the tab bar controller's current view as a subview of the window
    [window addSubview:tabBarController.view];
	
	
	ListsController *listsController = [[[ListsController alloc] initWithNibName:nil bundle:nil] autorelease];
	listsController.accessToken = [self accessToken];
	
	UINavigationController *rootNavigationController = [[UINavigationController alloc] initWithRootViewController:listsController];
	rootNavigationController.tabBarItem.title = @"Browse All";
	
	AccountSettingsController *settingsController = [[[AccountSettingsController alloc] initWithNibName:nil bundle:nil] autorelease];
	settingsController.tabBarItem.title = @"Settings";	
	
	tabBarController.viewControllers = [NSArray arrayWithObjects:rootNavigationController, settingsController, nil];
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

