//
//  StatusToolbarGenerator.h
//  Listable
//
//  Created by Justin Leitgeb on 9/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusToolbarGenerator : NSObject {
	NSString *message;
	UIView *uiView;
	UIToolbar *toolbar;
}

- (id) initWithView:(UIView *)view;
- (UIToolbar *) toolbarWithTitle:(NSString *)title;

@property (nonatomic, retain) NSString *message;
@property (nonatomic, retain) UIView *uiView;
@property (nonatomic, retain) UIToolbar *toolbar;

@end
