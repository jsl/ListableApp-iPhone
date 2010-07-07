//
//  URLEncode.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (URLEncode)

+ (NSString *)URLEncodeString:(NSString *)string; 
- (NSString *)URLEncodeString;

@end
