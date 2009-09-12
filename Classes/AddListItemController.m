//
//  AddListItemController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddListItemController.h"

#import "URLEncode.h"
#import "JSON.h"
#import "Constants.h"

@implementation AddListItemController

@synthesize accessToken;
@synthesize receivedData;
@synthesize listItemNameTextField;
@synthesize itemList;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (IBAction) doneButtonPressed:(id)sender {
	NSString *format = @"%@/lists/%@/items.json";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, itemList.remoteId];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"];
    
	NSData *httpBody = [ [ NSString stringWithFormat:@"item[name]=%@&user_credentials=%@", 
						  [listItemNameTextField.text URLEncodeString],
						  [accessToken URLEncodeString] ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setHTTPBody: httpBody];
	
	NSLog(@"This is what were doin: %@", httpBody);
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
    if (connection) { 
		NSLog(@"Got conncetion");
        receivedData = [[NSMutableData data] retain]; 
		NSLog(@"set up receiveddata, it is %@", [receivedData class]);
    }
	
	NSLog(@"Done setting up con, for real");
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Got conncetion 2");
	
	[self.receivedData setLength:0];
}

- (void)connectionDidFail:(NSURLConnection *)connection {
	NSLog(@"Got conncetion FAIL 3");
	
	[connection release];
	[receivedData release];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSLog(@"Got conncetion 4");
	
    [self.receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Got conncetion FINISH");
	
	NSString *jsonData = [[NSString alloc] initWithBytes:[self.receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NSMutableDictionary *createResponse = [jsonData JSONValue];
	
	NSLog(@"Decoded json obj: %@", createResponse);
	
	[jsonData release];
    [connection release];
	
	// DO something with response here!!  XXX
	//	if ( [ [ authResponse objectForKey:@"code" ] isEqual:@"Success" ] ) {
	//		NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	//		[prefs setObject:[ authResponse objectForKey:@"key" ] forKey:@"accessToken"];
	//		[prefs synchronize];
	//	} else {
	//		NSLog(@"Failed to retrieve access token, probably used invalid credentials");
	//	}
}

// Gets rid of the keyboard no matter what the responder is
- (void)dropKickResponder {
	NSLog(@"Got dropKickResponder");
	
	[listItemNameTextField resignFirstResponder];
}

-(IBAction)dismissKeyboard: (id)sender {
	NSLog(@"Got dismissKeyboard");
	[self dropKickResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	NSLog(@"Got textFieldDidEndEditing");
	[self dropKickResponder];	
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	NSLog(@"Got textFieldShouldReturn");
	[self dropKickResponder];
	
	return YES;
}


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
	[receivedData release];
	[accessToken release];
	
    [super dealloc];
}


@end
