//
//  AddListController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddListController.h"
#import "URLEncode.h"
#import "JSON.h"
#import "Constants.h"
#import "UserSettings.h"
#import "JSON.h"
#import "ItemList.h"
#import "ListItemsController.h"

@implementation AddListController

@synthesize receivedData;
@synthesize listNameTextField;
@synthesize statusCode;

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
	NSString *urlString = [NSString stringWithFormat:@"%@/lists.json", API_SERVER];
	
	NSURL *myURL = [NSURL URLWithString:urlString];
	
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:myURL];
	
    [request setHTTPMethod:@"POST"]; 
    
	NSData *httpBody = [ [ NSString stringWithFormat:@"list[name]=%@&user_credentials=%@", 
						  [listNameTextField.text URLEncodeString],
						  [[UserSettings sharedUserSettings].authToken URLEncodeString] ] dataUsingEncoding:NSUTF8StringEncoding];
	
	[request setHTTPBody: httpBody];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 
	
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 
	
    if (connection) { 
        receivedData = [[NSMutableData data] retain]; 
    }
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
	NSString *jsonData = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NSDictionary *jsonResponse = [jsonData JSONValue];
	
	if ( [ self.statusCode intValue ] == 200 ) {
		ItemList *l = [ [ItemList alloc] init];
		[l setName:[jsonResponse objectForKey:@"name"]];
		[l setRemoteId:[jsonResponse objectForKey:@"id"]];
		
		NSArray *ct = [ self.navigationController viewControllers];
		ListItemsController *nextController = [[ListItemsController alloc] initWithStyle:UITableViewStylePlain];
		[ nextController setItemList:l ];
		
		NSArray *ct2 = [NSArray arrayWithObjects:[ct objectAtIndex:0], nextController, nil];
		
		[nextController release];		
		
		// If "animated" is added to this call, for some reason the back button becomes active but invisible...
		// is there another method that can be used?  right now it just jumps back :(
		[ self.navigationController setViewControllers:ct2];
	} else {
		NSString *msg = @"Undefined error occurred while processing response";
		
		if ( [ jsonResponse respondsToSelector:@selector( objectForKey: )] == YES )
			msg = [ jsonResponse objectForKey:@"message" ];
		
		UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to perform action" 
														 message:msg
														delegate:self
											   cancelButtonTitle:@"OK" 
											   otherButtonTitles:nil ];
		
		
		[alert show];
		[alert release];		
	}
}

// Gets rid of the keyboard no matter what the responder is
- (void)dropKickResponder {
	[listNameTextField resignFirstResponder];
}

-(IBAction)dismissKeyboard: (id)sender {
	[self dropKickResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	[self dropKickResponder];	
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[self dropKickResponder];
	
	return YES;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
		
	[ listNameTextField becomeFirstResponder ];
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
	[receivedData release];
	[statusCode release];
	[listNameTextField release];
	
    [super dealloc];
}


@end
