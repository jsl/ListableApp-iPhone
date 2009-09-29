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
	
    if (self.connection)
        self.data = [[NSMutableData data] retain]; 		
    else
		[ self alertOnHTTPFailure ];
	
	return self;	
}

- (id)initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:(NSURL *)inUrl delegate:(UIViewController *)inDelegate statusDisplay:(StatusDisplay *)inStatusDisplay statusMessage:(NSString *)inStatusMessage {
	NSMutableURLRequest *request = [ NSMutableURLRequest requestWithURL:inUrl ];
	
	return [self initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:request delegate:inDelegate statusDisplay:inStatusDisplay statusMessage:inStatusMessage ];
}

- (id)initWithUrlAndDelegate: (NSURL *)inUrl delegate:(UIViewController *)inDelegate {
	return [self initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:inUrl delegate:inDelegate statusDisplay:nil statusMessage:nil ];
}

- (id)init {
    return [self initWithUrlAndDelegate:nil delegate:nil ];
}


- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {	
	self.didReceiveResponse = YES;
	
	if ([response respondsToSelector:@selector(statusCode)])
		self.statusCode = [ NSNumber numberWithInt:[((NSHTTPURLResponse *)response) statusCode] ];
	
	[self.data setLength:0];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [ self.connection release ];	
    [ self.data release ];
	[ self.timer invalidate ];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	if (! ( self.statusDisplay == nil ) )
		[ self.statusDisplay stop ];	

	[ self displayConnectivityProblemMessage ];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData {
    [self.data appendData:inData];
}

- (void)checkIfResponseReceived: (NSTimer *)theTimer {	
	if (self.didReceiveResponse) {
		[self.timer invalidate];
		
	} else {
		// If we've gone too long, show an alert.
		self.ticks++;
		
		if (self.ticks > 150) {
			[self.connection cancel];
			
			[connection release];			
			[data release];
			
			[self.timer invalidate];

			[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

			[ self displayConnectivityProblemMessage ];
			
			if (! ( self.statusDisplay == nil ) )
				[ self.statusDisplay stop ];

		}
	}
}

// To be displayed on timeouts and when we get a connection failure.
- (void)displayConnectivityProblemMessage {
	UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:@"Unable to connect to server"
													 message:@"Unable to connect to ListableApp.com.  Please try again, or contact support@listableapp.com if problems persist."
													delegate:self
										   cancelButtonTitle:@"OK" 
										   otherButtonTitles:nil ];
	
	[alert show];
	[alert release];	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
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
		if ([ delegate respondsToSelector:@selector(renderFailureJSONResponse: withStatusCode:) ]) {
			[delegate renderFailureJSONResponse:parsedJsonObject withStatusCode:[ self.statusCode intValue ] ];
		}
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
