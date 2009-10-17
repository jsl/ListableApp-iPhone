//
//  Collaborator.m
//  Listable
//
//  Created by Justin Leitgeb on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Collaborator.h"


@implementation Collaborator

@synthesize email;
@synthesize remoteId;
@synthesize isCreator;

- (void)dealloc {
	[email release];
	[remoteId release];
	[isCreator release];
	
    [super dealloc];
}


@end
