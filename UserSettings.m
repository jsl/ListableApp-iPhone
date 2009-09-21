//
//  UserSettings.m
//  Listable
//
//  Created by Justin Leitgeb on 9/21/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "UserSettings.h"
#import "SynthesizeSingleton.h"

@implementation UserSettings

@synthesize authToken;

SYNTHESIZE_SINGLETON_FOR_CLASS(UserSettings);

- (void)dealloc {
	[authToken release];
	
    [super dealloc];
}

@end
