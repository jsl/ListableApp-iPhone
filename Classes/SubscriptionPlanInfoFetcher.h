//
//  SubscriptionPlanInfoFetcher.h
//  Listable
//
//  Created by Justin Leitgeb on 11/2/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SubscriptionPlanInfoFetcher : NSObject {
	NSMutableData *data;
	NSURLConnection *connection;
}

- (void)fetchInfo;

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;

@end
