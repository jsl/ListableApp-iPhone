//
//  CustomButton.m
//  Listable
//
//  Created by Justin Leitgeb on 9/24/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "CustomButton.h"


@implementation CustomButton

- (id)initWithCoder:(NSCoder *)coder {
	if (self = [super initWithCoder:coder]) {
		UIImage *normalImage = [ [UIImage imageNamed:@"custombuttonnormal.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:22];
		UIImage *pressedImage = [[UIImage imageNamed:@"custombuttonpressed.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:22];
		
		[self setBackgroundImage:normalImage forState:UIControlStateNormal];
		[self setBackgroundImage:pressedImage forState:UIControlStateHighlighted];
	}
	return self;
}

@end
