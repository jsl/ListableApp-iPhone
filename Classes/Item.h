//
//  Item.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject {
	NSString *name;
	NSDecimalNumber *remoteId;
	NSNumber *completed;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSDecimalNumber *remoteId;
@property (nonatomic, retain) NSNumber *completed;

@end
