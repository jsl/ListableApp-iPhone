//
//  Collaborator.m
//  Listable
//
//  Created by Justin Leitgeb on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Collaborator.h"


@implementation Collaborator

@synthesize login;
@synthesize remoteId;
@synthesize userId;
@synthesize isCreator;
@synthesize userImage;

- (void)dealloc {
	[userImage release];
	[login release];
	[remoteId release];
	[userId release];
	[isCreator release];
	
    [super dealloc];
}


@end
