//
//  Item.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Item.h"


@implementation Item

@synthesize name;
@synthesize remoteId;
@synthesize completed;
@synthesize createdAt;
@synthesize creatorEmail;

- (void)dealloc {
	[name release];
	[remoteId release];
	[completed release];
	[createdAt release];
	[creatorEmail release];
	
    [super dealloc];
}

- (id) copyWithZone:(NSZone *)zone {
	Item *copy = [ [self class] allocWithZone:zone ];
	
	copy.name			= self.name;
	copy.remoteId		= self.remoteId;
	copy.completed		= self.completed;
	copy.createdAt		= self.createdAt;
	copy.creatorEmail	= self.creatorEmail;
	
	return copy;
}

@end
