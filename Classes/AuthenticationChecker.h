//
//  AuthenticationChecker.h
//  Listable
//
//  Created by Justin Leitgeb on 9/17/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AuthenticationChecker : NSObject {

}

- (BOOL) isTokenValid:(NSString *)accessToken;

@end
