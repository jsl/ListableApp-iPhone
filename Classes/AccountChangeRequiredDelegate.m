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

@implementation AccountChangeRequiredDelegate

@synthesize token;

// Only alert in this controller is to upgrade account with button index 1
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {		
		NSString *format = @"%@/subscription_redirect?key=%@";
		
		NSString *myUrlStr = [ NSString stringWithFormat:format, 
							  ACCOUNT_SERVER, 
							  [ self.token URLEncodeString] ];
		
		NSURL *myUrl = [NSURL URLWithString:myUrlStr];	
		
		[[UIApplication sharedApplication] openURL:myUrl];		
	}
}


- (void)dealloc {
	[token release];
	
	[super dealloc];
}

@end
