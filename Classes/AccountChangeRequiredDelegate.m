//
//  AccountChangeRequiredDelegate.m
//  Listable
//
//  Created by Justin Leitgeb on 10/16/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "AccountChangeRequiredDelegate.h"
#import "Constants.h"
#import "URLEncode.h"
#import "UserSettings.h"
#import "JSON.h"

@implementation AccountChangeRequiredDelegate

@synthesize data, connection, token, ticks, timer;

- (void)fetchToken {
	NSString *format = @"%@/perishable_token.json?user_credentials=%@";
	NSString *myUrlStr = [NSString stringWithFormat:format, API_SERVER, 
						  [ [UserSettings sharedUserSettings].authToken URLEncodeString ]];
	
	NSURL *myURL = [NSURL URLWithString:myUrlStr];

	NSMutableURLRequest *request = [ NSMutableURLRequest requestWithURL:myURL ];

	self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; 

	if (self.connection)
        self.data = [[NSMutableData data] retain]; 		

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {		
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [ self.connection release ];	
    [ self.data release ];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData {
    [self.data appendData:inData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSString *responseData = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	id parsedJsonObject = [responseData JSONValue];
	[responseData release];
	self.token = [parsedJsonObject objectForKey:@"token"];
}

// Only alert in this controller is to upgrade account with button index 1
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		[self loadAccountInBrowser];
	}
	
	[ self release ];
}

// Loads account in browser if token has finished loading, otherwise start timer
// and check again until timeout.
- (void)loadAccountInBrowser {
	
	if (self.token == NULL) {
		[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

		// start timer
		if (self.timer == NULL) {
			self.ticks = 0;
			self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(loadAccountInBrowser) userInfo:nil repeats:YES];
		} else {
			self.ticks++;
			
			if (self.ticks > 150) {
				[self.connection cancel];
				
				[connection release];			
				[data release];
				
				[self.timer invalidate];
				
				[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
				
				[ self displayConnectivityProblemMessage ];
			}			
		}

	} else {
		// load page
		NSString *format = @"%@/subscription_redirect?key=%@";
		
		NSString *myUrlStr = [ NSString stringWithFormat:format, 
							  ACCOUNT_SERVER, 
							  [ self.token URLEncodeString] ];
		
		NSURL *myUrl = [NSURL URLWithString:myUrlStr];	
		
		[[UIApplication sharedApplication] openURL:myUrl];				
	}	
}

// To be displayed on timeouts and when we get a connection failure.
- (void)displayConnectivityProblemMessage {
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to connect to server"
													 message:@"Sorry, we encountered a problem on our end and were unable to load your account.  Please try again, log in to listableapp.com directly, or contact support@listableapp.com if problems continue."
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	[alert show];
	[alert release];
}


- (void)dealloc {
	[token release];
	[data release];
	[connection release];
	[timer release ];

	[super dealloc];
}

@end
