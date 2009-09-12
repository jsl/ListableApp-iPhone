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
}

@property (nonatomic, retain) NSString *name; 
@property (nonatomic, retain) NSDecimalNumber *remoteId;

@end
