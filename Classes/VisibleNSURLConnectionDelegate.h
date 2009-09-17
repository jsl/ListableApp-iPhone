//
//  VisibleNSURLConnectionDelegate.h
//  Listable
//
//  Created by Justin Leitgeb on 9/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VisibleNSURLConnectionDelegate : NSObject {
	NSMutableData *receivedData;
	UITableView *tableView;
	NSString *loadingMsg;
	SEL selResponseParser;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
- (void)connectionDidFail:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
- (void)connectionDidFinishLoading:(NSURLConnection *)connection;

@property (nonatomic, retain) NSMutableData *receivedData;
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSString *loadingMsg;
@property (nonatomic, retain) SEL *selResponseParser;

@end
