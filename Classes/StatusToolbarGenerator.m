//
//  StatusToolbarGenerator.m
//  Listable
//
//  Created by Justin Leitgeb on 9/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatusToolbarGenerator.h"


@implementation StatusToolbarGenerator

@synthesize message, uiView, toolbar;

- (id) initWithView:(UIView *)view {
    /* first initialize the base class */
    self = [super init]; 

	// Initialize transitory footer toolbar
	self.toolbar = [UIToolbar new];
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
	
	self.uiView = view;
	
    return self;
}


- (UIToolbar *) toolbarWithTitle:(NSString *)title {
	
	UIBarButtonItem* bi = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:self action:nil];
	
	UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [activityIndicator startAnimating];
    UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [activityIndicator release];
	
	[toolbar setItems:[NSArray arrayWithObjects:bi, activityItem, nil]];
	
    [activityItem release];
	
	self.toolbar.translucent = YES;
	
	//Set the frame
	CGFloat toolbarHeight = [toolbar frame].size.height;
		
	CGRect mainViewBounds = uiView.bounds;
	[toolbar setFrame:CGRectMake(CGRectGetMinX(mainViewBounds), CGRectGetMinY(mainViewBounds) + CGRectGetHeight(mainViewBounds) - toolbarHeight, CGRectGetWidth(mainViewBounds),toolbarHeight)];
		
	self.toolbar.hidden = NO;
	
	return self.toolbar;
}

- (void)dealloc {
	[message release];
	[uiView release];
	[toolbar release];
	
    [super dealloc];
}


@end
