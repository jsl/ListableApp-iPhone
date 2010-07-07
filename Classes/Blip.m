//
//  Blip.m
//  Listable
//
//  Created by Justin Leitgeb on 10/27/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import "Blip.h"

@implementation Blip

@synthesize originatingUsername, userImage, message, timeAgo, itemList;

- (void)dealloc {
	[originatingUsername release];
	[userImage release];
	[message release];
	[timeAgo release];
	[itemList release];
	
    [super dealloc];
}

@end
