//
//  StatusDisplay.h
//  Listable
//
//  Created by Justin Leitgeb on 9/16/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StatusDisplay : NSObject {
	UIView *uiView;
	UIToolbar *toolbar;
}

- (id) initWithView:(UIView *)view;
- (void) startWithTitle:(NSString *)title;
- (void) stop;

@property (nonatomic, retain) UIView *uiView;
@property (nonatomic, retain) UIToolbar *toolbar;

@end
