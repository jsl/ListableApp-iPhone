//
//  UserSettings.h
//  Listable
//
//  Created by Justin Leitgeb on 9/21/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserSettings : NSObject {
	
	NSString *authToken;
	NSDecimalNumber *maxLists;
}

@property (nonatomic, retain) NSString *authToken;
@property (nonatomic, retain) NSDecimalNumber *maxLists;

+ (UserSettings *)sharedUserSettings;

@end
