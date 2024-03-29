//
//  Item.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Item : NSObject <NSCopying> {
	NSString *name;
	NSDecimalNumber *remoteId;
	NSNumber *completed;
	
	NSString *createdAt;
	NSString *creatorEmail;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *createdAt;
@property (nonatomic, retain) NSString *creatorEmail;
@property (nonatomic, retain) NSDecimalNumber *remoteId;
@property (nonatomic, retain) NSNumber *completed;

@end
