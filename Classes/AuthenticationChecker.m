//
//  AuthenticationChecker.m
//  Listable
//
//  Created by Justin Leitgeb on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AuthenticationChecker.h"
#import "Constants.h"

@implementation AuthenticationChecker


- (BOOL) isTokenValid:(NSString *)accessToken {
	NSString *urlString = [ NSString stringWithFormat:@"%@/api_authentication/%@.json", API_SERVER, [ accessToken URLEncodeString] ];

	NSURL *myURL = [NSURL URLWithString:urlString];

	NSURLRequest *URLRequest = [NSURLRequest requestWithURL:myURL        
												cachePolicy: NSURLRequestReloadIgnoringCacheData
											timeoutInterval: 30.0 ];

	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES]; 

	NSData *data				= nil;
	NSHTTPURLResponse *response = nil;
	NSError *error				= nil;
	data			= [ NSURLConnection sendSynchronousRequest: URLRequest
											 returningResponse: &response
														 error: &error	];
		
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

	NSInteger statusCode = [response statusCode];

	if (statusCode == 200) {
		return YES;
	} else if (statusCode == 404) {
		return NO;		
	} else {
		NSLog(@"Got a weird status code of %i", statusCode);
		return NO;
	}
	
	[response release];
}

@end
