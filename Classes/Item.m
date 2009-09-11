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

- (void)dealloc {
	[name release];
	[remoteId release];
	
    [super dealloc];
}

@end
