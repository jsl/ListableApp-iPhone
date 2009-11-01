//
//  ItemList.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ItemList : NSObject {
	NSString *name;
	NSDecimalNumber *remoteId;
	NSDecimalNumber *linkId;
	NSDecimalNumber *maxItems;
	
	NSNumber *currentUserIsCreator;
}

@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSDecimalNumber *remoteId;
@property (nonatomic, retain) NSDecimalNumber *linkId;
@property (nonatomic, retain) NSNumber *currentUserIsCreator;
@property (nonatomic, retain) NSDecimalNumber *maxItems;

@end
