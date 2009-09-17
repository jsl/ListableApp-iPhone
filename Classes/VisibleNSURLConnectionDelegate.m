//
//  VisibleNSURLConnectionDelegate.m
//  Listable
//
//  Created by Justin Leitgeb on 9/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "VisibleNSURLConnectionDelegate.h"


@implementation VisibleNSURLConnectionDelegate

@synthesize receivedData, tableView, loadingMsg;

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
	NSString *jsonData = [[NSString alloc] initWithBytes:[self.receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	NSMutableDictionary *createResponse = [jsonData JSONValue];
	
	[jsonData release];
    [connection release];
	
	
	[self.navigationController popViewControllerAnimated:YES];	
}

- (void)dealloc {
	[tableView release];
	[receivedData release];
	[loadingMsg release];
	
    [super dealloc];
}

@end
