//
//  Collaborator.h
//  Listable
//
//  Created by Justin Leitgeb on 9/15/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Collaborator : NSObject {
	NSString *email;
	NSDecimalNumber *remoteId;
}

@property (nonatomic, retain) NSString *email; 
@property (nonatomic, retain) NSDecimalNumber *remoteId;

@end
