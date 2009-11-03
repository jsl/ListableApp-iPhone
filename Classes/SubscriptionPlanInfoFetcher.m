//
//  SubscriptionPlanInfoFetcher.m
//  Listable
//
//  Created by Justin Leitgeb on 11/2/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "SubscriptionPlanInfoFetcher.h"
#import "UserSettings.h"
#import "JSON.h"
#import "URLEncode.h"
#import "Constants.h"

@implementation SubscriptionPlanInfoFetcher

@synthesize data, connection;

- (void)fetchInfo {
	NSString *format = @"%@/subscription_plan.json?user_credentials=%@";
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
	
	[UserSettings sharedUserSettings].maxLists = [parsedJsonObject objectForKey:@"max_lists"];
}

- (void)dealloc {
	[data release];
	[connection release];
	
	[super dealloc];
}

@end
