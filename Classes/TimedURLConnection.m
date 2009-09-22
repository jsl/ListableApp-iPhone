//
//  TimedUrlConnection.m
//  Listable
//
//  Created by Justin Leitgeb on 9/22/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "TimedURLConnection.h"
#import "JSON.h"

@implementation TimedURLConnection

@synthesize url, data, connection, statusCode, delegate, timer, didReceiveResponse, ticks, statusDisplay;


- (id)initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:(NSMutableURLRequest *)inRequest delegate:(UIViewController *)inDelegate statusDisplay:(StatusDisplay *)inStatusDisplay statusMessage:(NSString *)inStatusMessage {
	NSLog(@"Doing TimedURLConnection init, inRequest is %@", inRequest);
	
	if (self = [super init]) {
		self.delegate = [ inDelegate retain ];
		self.didReceiveResponse = NO;
		self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(checkIfResponseReceived:) userInfo:nil repeats:YES];
		self.ticks = 0;
		self.statusDisplay = inStatusDisplay;
    }
	
	if (! ( self.statusDisplay == nil  ) )
		[ self.statusDisplay startWithTitle:inStatusMessage];
	
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 	
	
    self.connection = [[NSURLConnection alloc] initWithRequest:inRequest delegate:self]; 
	
    if (self.connection) { 
		NSLog(@"Got data");
        self.data = [[NSMutableData data] retain]; 
		
    } else {
		NSLog(@"Got failure!");
		[ self alertOnHTTPFailure ];
	}
	
	return self;	
}

- (id)initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:(NSURL *)inUrl delegate:(UIViewController *)inDelegate statusDisplay:(StatusDisplay *)inStatusDisplay statusMessage:(NSString *)inStatusMessage {
	NSMutableURLRequest *request = [ NSMutableURLRequest requestWithURL:inUrl ];
	
	return [self initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request delegate:inDelegate statusDisplay:nil statusMessage:nil ];
}

- (id)initWithUrlAndDelegate: (NSURL *)inUrl delegate:(UIViewController *)inDelegate {
	NSLog(@"Gonna make a daddy object!");

	return [self initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:inUrl delegate:inDelegate statusDisplay:nil statusMessage:nil ];
}

- (id)init {
    return [self initWithUrlAndDelegate:nil delegate:nil ];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Got response, setting status code");
	
	self.didReceiveResponse = YES;
	
	if ([response respondsToSelector:@selector(statusCode)])
		self.statusCode = [ NSNumber numberWithInt:[((NSHTTPURLResponse *)response) statusCode] ];
	
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // release the connection, and the data object
    [self.connection release];
	
    // receivedData is declared as a method instance elsewhere
    [self.data release];
	
	if (! ( self.statusDisplay == nil ) )
		[ self.statusDisplay stop ];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData {
	NSLog(@"Did receive some data");
    [self.data appendData:inData];
}

- (void)checkIfResponseReceived: (NSTimer *)theTimer {	
	if (self.didReceiveResponse) {
		NSLog(@"Eggs are cooked, needed %i ticks", self.ticks);
		[self.timer invalidate];
		
	} else {
		// If we've gone too long, show an alert.
		self.ticks++;
		
		// 3 seconds max
		if (self.ticks > 50) {
			UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to connect to server"
															 message:@"Unable to connect to ListableApp.com.  Please try again, or contact support@listableapp.com if problems persist."
															delegate:self
												   cancelButtonTitle:@"OK" 
												   otherButtonTitles:nil ];
			
			[alert show];
			[alert release];
			
			// Make connection an Ivar?
			// [connection release];			
			[data release];
			
			[self.timer invalidate];
			
			// Now we just have to get rid of the status display... should we take care of that?
			// Perhaps it should be a singleton?
		} else {
			NSLog(@"We'll try again later, ticks == %i", self.ticks);
		}
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSLog(@"Connection did finish loading");
	
	if (! ( self.statusDisplay == nil ) )
		[ self.statusDisplay stop ];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	NSString *responseData = [[NSString alloc] initWithBytes:[data bytes] length:[data length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	id parsedJsonObject = [responseData JSONValue];
		
	// Try getting items from response if the body isn't empty and the code is 200
	if ([ statusCode intValue ] == 200) {
		if ([ delegate respondsToSelector:@selector(renderSuccessJSONResponse:) ])
			[delegate renderSuccessJSONResponse:parsedJsonObject];
	} else {
		if ([ delegate respondsToSelector:@selector(renderFailureJSONResponse:) ])
			[delegate renderFailureJSONResponse:parsedJsonObject withStatusCode:[ self.statusCode intValue ] ];
	}
	
	[responseData release];
    [self.connection release];
}


- (void)alertOnHTTPFailure {
	NSString *msg = @"HTTP Failure";
	
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"HTTP Failure, whoops!"
													 message:msg
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	[alert show];
	[alert release];
}

// This class is going to pile up unless we release them somewhere!
- (void)dealloc {
	NSLog(@"Got dealloc");
	
	[ url release ];
	[ data release ];
	[ connection release ];
	[ delegate release ];
	[ statusCode release ];
	[ timer release ];
	
	if (! ( statusDisplay == nil ) )
		[ statusDisplay release ];
	
    [super dealloc];
}

@end
