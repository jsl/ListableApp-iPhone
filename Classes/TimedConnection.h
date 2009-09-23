/*
 *  TimedConnection.h
 *  Listable
 *
 *  Created by Justin Leitgeb on 9/22/09.
 *  Copyright 2009 BlockStackers. All rights reserved.
 *
 */

@protocol TimedConnection <NSObject>

- (void) renderSuccessJSONResponse: (id)parsedJsonObject;
- (void) renderFailureJSONResponse: (id)parsedJsonObject withStatusCode:(int)statusCode;

@end
