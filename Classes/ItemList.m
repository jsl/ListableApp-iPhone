//
//  ItemList.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ItemList.h"


@implementation ItemList

@synthesize name;
@synthesize remoteId;
@synthesize linkId;

- (void)dealloc {
	[name release];
	[remoteId release];
	[linkId release];
	
    [super dealloc];
}

@end
