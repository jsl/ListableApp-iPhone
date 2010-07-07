//
//  ShakeableTableView.m
//  Listable
//
//  Created by Justin Leitgeb on 9/19/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import "ShakeableTableView.h"
#import "ShakeDelegate.h"

@implementation ShakeableTableView

@synthesize viewDelegate;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if ( event.subtype == UIEventSubtypeMotionShake ) {
		if ([viewDelegate respondsToSelector:@selector(shakeHappened:)]) {
			id <ShakeDelegate> theViewDelegate = (id<ShakeDelegate>)viewDelegate;
			[theViewDelegate shakeHappened:self];
		}		
    }
	
    if ( [super respondsToSelector:@selector(motionEnded:withEvent:)] )
        [super motionEnded:motion withEvent:event];
}

- (BOOL)canBecomeFirstResponder {
	return YES; 
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dealloc {
	[viewDelegate release];
	
    [super dealloc];
}


@end
