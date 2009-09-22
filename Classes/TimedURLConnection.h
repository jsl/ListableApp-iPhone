//
//  TimedUrlConnection.h
//  Listable
//
//  Created by Justin Leitgeb on 9/22/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimedConnection.h"
#import "StatusDisplay.h"

@interface TimedURLConnection : NSObject {	

	NSURL *url;
	NSMutableData *data;
	NSURLConnection *connection;
	id <TimedConnection> delegate;
	NSNumber *statusCode;
	int ticks;
	NSTimer *timer;
	BOOL didReceiveResponse;
	StatusDisplay *statusDisplay;
}

@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) id <TimedConnection> delegate;
@property (nonatomic, retain) NSNumber *statusCode;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) BOOL didReceiveResponse;
@property (nonatomic, retain) StatusDisplay *statusDisplay;
@property (nonatomic) int ticks;

- (id)initWithRequestAndDelegateAndStatusDisplayAndStatusMessage:(NSMutableURLRequest *)inRequest delegate:(UIViewController *)inDelegate statusDisplay:(StatusDisplay *)inStatusDisplay statusMessage:(NSString *)inStatusMessage;
- (id)initWithUrlAndDelegateAndStatusDisplayAndStatusMessage:(NSURL *)url delegate:(UIViewController *)delegate statusDisplay:(StatusDisplay *)statusDisplay statusMessage:(NSString *)statusMessage;
- (id)initWithUrlAndDelegate: (NSURL *)url delegate:(UIViewController *)delegate;
- (id) init;

- (void)alertOnHTTPFailure;

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)inData;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)checkIfResponseReceived: (NSTimer *)theTimer;

@end
