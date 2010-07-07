//
//  URLEncode.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/10/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import "URLEncode.h"


@implementation NSString (URLEncode)

// URL encode a string 
+ (NSString *)URLEncodeString:(NSString *)string { 
    NSString *result = (NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)string, NULL, CFSTR("% '\"?=&+<>;:-"), kCFStringEncodingUTF8); 
	
    return [result autorelease]; 
} 

// Helper function 
- (NSString *)URLEncodeString { 
    return [NSString URLEncodeString:self]; 
} 


@end
