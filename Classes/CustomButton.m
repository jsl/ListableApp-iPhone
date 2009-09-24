//
//  CustomButton.m
//  Listable
//
//  Created by Justin Leitgeb on 9/24/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "CustomButton.h"


@implementation CustomButton

// global images so we don't load/create them over and over
UIImage *normalImage;
UIImage *pressedImage;

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		if (!normalImage) {
			UIImage *image = [UIImage imageNamed:@"custombuttonnormal.png"];
			normalImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12];
		}
		
		if (!pressedImage) {
			UIImage *image = [UIImage imageNamed:@"custombuttonpressed.png"];
			pressedImage = [image stretchableImageWithLeftCapWidth:12 topCapHeight:12];
		}
		
		[self setBackgroundImage:normalImage forState:UIControlStateNormal];
		[self setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	}
	return self;
}

@end
