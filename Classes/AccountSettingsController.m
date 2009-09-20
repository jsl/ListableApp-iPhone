//
//  AccountSettingsController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AccountSettingsController.h"
#import "URLEncode.h"
#import "Constants.h"
#import "JSON.h"
#import "SharedListAppDelegate.h"

@implementation AccountSettingsController

@synthesize receivedData;
@synthesize authResponse;
@synthesize emailTextField;
@synthesize passwordTextField;

@synthesize checkAccountButton;
@synthesize createAccountButton;

@synthesize statusCode;

- (IBAction) checkAccountButtonPressed:(id)sender {
	NSString *format = @"%@/user_session.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER];

	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"]; 
    
	[request setHTTPBody:[[NSString stringWithFormat:@"user_session[email]=%@&user_session[password]=%@&device_id=%@", 
                           [emailTextField.text URLEncodeString], 
						   [passwordTextField.text URLEncodeString],
                           [[UIDevice currentDevice] uniqueIdentifier]] dataUsingEncoding:NSUTF8StringEncoding]]; 
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
		
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }
}

- (IBAction) createAccountButtonPressed:(id)sender {
	NSURL *url = [ [ NSURL alloc ] initWithString: @"http://listableapp.com/account/new" ];
	[[UIApplication sharedApplication] openURL:url];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	if ([response respondsToSelector:@selector(statusCode)])
		self.statusCode = [ NSNumber numberWithInt:[((NSHTTPURLResponse *)response) statusCode] ];

	[self.receivedData setLength:0];
}

- (void)connectionDidFail:(NSURLConnection *)connection {
	[connection release];
	[receivedData release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	NSString *responseBody = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	NSMutableDictionary *jsonResponse = [ responseBody JSONValue ];

	if ([statusCode intValue ] == 200) {		
		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
		[prefs setObject:[jsonResponse valueForKey:@"token"] forKey:@"accessToken"];
		[prefs setObject:emailTextField.text forKey:@"userEmail"];
		[prefs synchronize];
		
		SharedListAppDelegate *sad = (SharedListAppDelegate *)[ [UIApplication sharedApplication] delegate];
		[sad configureTabBarWithLoggedInState:YES];
		
		self.tabBarController.selectedIndex = 0;
		
	} else if ([statusCode intValue ] == 404) {
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Login failed" 
														 message:@"Sorry, we couldn't log you in with the credentials provided.  Please try again or contact us at support@listableapp.com if problems continue." 
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
	 	[alert show];
		[alert release];
		
	} else if ([statusCode intValue ] > 400) {
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
														 message:[jsonResponse valueForKey:@"message"]
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
	 	[alert show];
		[alert release];
	}

	[responseBody release];
    [connection release];
}

- (void)dropKickResponder {
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];	
}

-(IBAction)dismissKeyboard: (id)sender {
	[self dropKickResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	[self dropKickResponder];
	
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[self dropKickResponder];

	return YES;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
- (void)viewDidLoad {	
	[super viewDidLoad];
}
*/

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
	[authResponse release];
	[receivedData release];
	[statusCode release];
	
    [super dealloc];
}


@end
