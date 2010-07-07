//
//  ItemList.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import "ItemList.h"


@implementation ItemList

@synthesize name;
@synthesize remoteId;
@synthesize linkId;
@synthesize currentUserIsCreator;
@synthesize maxItems;

- (void)dealloc {
	[name release];
	[remoteId release];
	[linkId release];
	[currentUserIsCreator release];
	[maxItems release];
	
    [super dealloc];
}

@end
