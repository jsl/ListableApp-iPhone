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
}

@property (nonatomic, retain) NSString *token;

@end
