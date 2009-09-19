//
//  ListItemCustomCell.m
//  Listable
//
//  Created by Justin Leitgeb on 9/18/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "ListItemCustomCell.h"


@implementation ListItemCustomCell

@synthesize checked, title, listItemsController, item;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// cell's title label
		self.textLabel.backgroundColor = self.backgroundColor;
		self.textLabel.opaque = NO;
		self.textLabel.textColor = [UIColor blackColor];
		self.textLabel.highlightedTextColor = [UIColor whiteColor];
		self.textLabel.font = [UIFont boldSystemFontOfSize:18.0];
		
		// cell's check button
		checkButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		checkButton.frame = CGRectZero;
		checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		
		[checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchDown];
		checkButton.backgroundColor = self.backgroundColor;
		[self.contentView addSubview:checkButton];
    }
    return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
    CGRect contentRect = [self.contentView bounds];
	
	CGRect frame = CGRectMake(contentRect.origin.x + 40.0, 8.0, contentRect.size.width, 30.0);
	self.textLabel.frame = frame;
	
	// layout the check button image
	UIImage *checkedImage = [UIImage imageNamed:@"checked.png"];
	frame = CGRectMake(contentRect.origin.x + 10.0, 12.0, checkedImage.size.width, checkedImage.size.height);
	checkButton.frame = frame;
	
	UIImage *image = (self.checked) ? checkedImage: [UIImage imageNamed:@"unchecked.png"];
	UIImage *newImage = [image stretchableImageWithLeftCapWidth:12.0 topCapHeight:0.0];
	[checkButton setBackgroundImage:newImage forState:UIControlStateNormal];
}

// called when the checkmark button is touched 
- (void)checkAction:(id)sender {
	self.checked = !self.checked;
	[self setImageOnCheckedState];
	[self.listItemsController toggleCompletedStateForItem:self.item];
}

// Sets appropriate image based on state of "checked"
- (void)setImageOnCheckedState {
	UIImage *checkImage = (self.checked) ? [UIImage imageNamed:@"checked.png"] : [UIImage imageNamed:@"unchecked.png"];
	[checkButton setImage:checkImage forState:UIControlStateNormal];
}

- (void)dealloc {
	[checkButton release];
	[title release];
	[listItemsController release];
	[item release];
	
    [super dealloc];
}

@end
