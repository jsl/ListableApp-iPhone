//
//  CurrentSessionController.m
//  Listable
//
//  Created by Justin Leitgeb on 9/20/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "CurrentSessionController.h"
#import "SharedListAppDelegate.h"

@implementation CurrentSessionController

@synthesize logoutButton, emailLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	SharedListAppDelegate *sad = (SharedListAppDelegate *)[ [UIApplication sharedApplication] delegate];
	NSLog(@"logged in? %i", sad.isTokenValid);
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	emailLabel.text = [prefs objectForKey:@"userEmail"];
}

- (IBAction) logoutButtonPressed:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:nil forKey:@"accessToken"];
	[prefs setObject:nil forKey:@"userEmail"];
	[prefs synchronize];
	
	SharedListAppDelegate *sad = (SharedListAppDelegate *)[ [UIApplication sharedApplication] delegate];
	[sad configureTabBarWithLoggedInState:NO];	
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[logoutButton release];
	[emailLabel release];
	
    [super dealloc];
}


@end
