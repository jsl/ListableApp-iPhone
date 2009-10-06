//
//  CurrentSessionController.m
//  Listable
//
//  Created by Justin Leitgeb on 9/20/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "CurrentSessionController.h"
#import "SharedListAppDelegate.h"
#import "UserSettings.h"
#import "Constants.h"
#import "StatusDisplay.h"
#import "URLEncode.h"
#import "TimedURLConnection.h"

@implementation CurrentSessionController

@synthesize logoutButton, changePlanButton, emailLabel, statusDisplay;

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
		
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	emailLabel.text = [prefs objectForKey:@"userEmail"];
	
	self.statusDisplay = [ [StatusDisplay alloc] initWithView:self.view ];
	
}

- (IBAction) changePlanButtonPressed:(id)sender {
	// Get perishable token synchronously.
	
	NSString *format = @"%@/perishable_token.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, 
						  [ [UserSettings sharedUserSettings].authToken URLEncodeString ]];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
		
	[ [TimedURLConnection alloc] initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:myURL 
																			   delegate:self 
																		  statusDisplay:self.statusDisplay 
																		  statusMessage:@"Loading account details..."];
	
}

// When the TimedURLConnection delegate receives a 200 response, it calls this method to figure
// out the specifics of how the parsed JSON object should be translated into something to render
// in the UITableView.
- (void) renderSuccessJSONResponse: (id)parsedJsonObject {	
	NSString *authtok = [ parsedJsonObject objectForKey:@"token" ];
	
	NSString *format = @"%@/subscription_redirect?key=%@";
	
	NSString *myUrlStr = [ NSString stringWithFormat:format, 
						  API_SERVER, 
						  [ authtok URLEncodeString] ];
	
	NSURL *url = [NSURL URLWithString:myUrlStr];	

	[[UIApplication sharedApplication] openURL:url];
}

- (IBAction) logoutButtonPressed:(id)sender {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	[prefs setObject:nil forKey:@"accessToken"];
	[prefs setObject:nil forKey:@"userEmail"];
	[prefs synchronize];
	
	[UserSettings sharedUserSettings].authToken = nil;
	
	[UIAppDelegate configureTabBarWithLoggedInState:NO];	
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
	[changePlanButton release];
	[statusDisplay release];
    [super dealloc];
}


@end
