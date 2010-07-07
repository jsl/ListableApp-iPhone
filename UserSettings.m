//
//  UserSettings.m
//  Listable
//
//  Created by Justin Leitgeb on 9/21/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import "UserSettings.h"
#import "SynthesizeSingleton.h"

@implementation UserSettings

@synthesize authToken;
@synthesize maxLists;

SYNTHESIZE_SINGLETON_FOR_CLASS(UserSettings);

- (void)dealloc {
	[authToken release];
	[maxLists release];
	
    [super dealloc];
}

@end
