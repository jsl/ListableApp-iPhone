//
//  AccountChangeRequiredDelegate.h
//  Listable
//
//  Created by Justin Leitgeb on 10/16/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AccountChangeRequiredDelegate : NSObject <UIAlertViewDelegate> {
	NSString *token;
	NSMutableData *data;
	NSURLConnection *connection;
	int ticks;
	NSTimer *timer;
}

- (void)fetchToken;
- (void)loadAccountInBrowser;
- (void)displayConnectivityProblemMessage;

@property (nonatomic, retain) NSString *token;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSTimer *timer;
@property (nonatomic) int ticks;

@end
