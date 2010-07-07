//
//  Blip.h
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemList.h"

@interface Blip : NSObject {
	NSString *originatingUsername;
	NSString *userImage;
	NSString *message;
	NSString *timeAgo;
	NSNumber *listId;
	ItemList *itemList;
}

@property (nonatomic, retain) NSString *originatingUsername; 
@property (nonatomic, retain) NSString *userImage;
@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) NSString *timeAgo;
@property (nonatomic, retain) ItemList *itemList;

@end
