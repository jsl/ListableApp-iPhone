//
//  AccountSettingsController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AccountSettingsController.h"
#import "URLEncode.h"

#import "JSON.h"

@implementation AccountSettingsController

@synthesize receivedData;
@synthesize authResponse;
@synthesize emailTextField;
@synthesize passwordTextField;

- (IBAction) checkAccountButtonPressed:(id)sender {
	NSURL *myURL = [NSURL URLWithString:@"http://localhost:3000/user_session.json"];
	
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
	
	// Do something with view HERE ?????
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
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
	
	NSString *jsonData = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	self.authResponse = [jsonData JSONValue];

	
	NSLog(@"Decoded json obj: %@", self.authResponse);

	[jsonData release];

    [connection release];
}

-(void)onTextChange:(id)sender {
    // dummy func must exist for textFieldShouldReturn event to be called
}


- (void)dropKickResponder {
	NSLog(@"Got dropKickResponder");
	
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];	
}

-(IBAction)dismissKeyboard: (id)sender {
	NSLog(@"Got dismissKeyboard");
	[self dropKickResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	NSLog(@"Got textFieldDidEndEditing");
	[self dropKickResponder];
	
	[emailTextField resignFirstResponder];
	[passwordTextField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	NSLog(@"Got textFieldShouldReturn");
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
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
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
	
    [super dealloc];
}


@end
