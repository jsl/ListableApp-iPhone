//
//  StringHelper.m
//  PTLog
//
//  Created by Ellen Miner on 1/2/09.
//  Copyright 2009 RaddOnline. All rights reserved.
//

#import "StringHelper.h"


@implementation NSString (StringHelper)

- (CGFloat)RAD_widthFromScreenSize {
	return [UIScreen mainScreen].bounds.size.width - 75;
}

#pragma mark Methods to determine the height of a string for resizeable table cells
- (CGFloat)RAD_textHeightForSystemFontOfSize:(CGFloat)size {
	//Calculate the expected size based on the font and linebreak mode of your label
	CGFloat maxWidth = [ self RAD_widthFromScreenSize ];
	CGFloat maxHeight = 9999;
	CGSize maximumLabelSize = CGSizeMake(maxWidth,maxHeight);
	
	CGSize expectedLabelSize = [self sizeWithFont:[UIFont systemFontOfSize:size] 
								   constrainedToSize:maximumLabelSize 
									   lineBreakMode:UILineBreakModeWordWrap]; 
	
	return expectedLabelSize.height;
}

- (CGRect)RAD_frameForCellLabelWithSystemFontOfSize:(CGFloat)size x_pos:(CGFloat)x_pos y_pos:(CGFloat)y_pos {
	CGFloat width = [ self RAD_widthFromScreenSize ];
	CGFloat height = [self RAD_textHeightForSystemFontOfSize:size] + 10.0;
	return CGRectMake(x_pos, y_pos, width, height);
}


- (void)RAD_resizeLabel:(UILabel *)aLabel WithSystemFontOfSize:(CGFloat)size x_pos:(CGFloat)x_pos y_pos:(CGFloat)y_pos {
	aLabel.frame = [self RAD_frameForCellLabelWithSystemFontOfSize:size x_pos:x_pos y_pos:y_pos];
	aLabel.text = self;
	[aLabel sizeToFit];
}

- (UILabel *)RAD_newSizedCellLabelWithSystemFontOfSize:(CGFloat)size x_pos:(CGFloat)x_pos y_pos:(CGFloat)y_pos {
	UILabel *cellLabel = [[UILabel alloc] initWithFrame:[self RAD_frameForCellLabelWithSystemFontOfSize:size x_pos:x_pos y_pos:y_pos]];
	cellLabel.textColor = [UIColor blackColor];
	cellLabel.backgroundColor = [UIColor clearColor];
	cellLabel.textAlignment = UITextAlignmentLeft;
	cellLabel.font = [UIFont systemFontOfSize:size];
	
	cellLabel.text = self; 
	cellLabel.numberOfLines = 0; 
	[cellLabel sizeToFit];
	return cellLabel;
}

@end
