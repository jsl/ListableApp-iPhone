//
//  ListItemCustomCell.m
//  Listable
//
//  Created by Justin Leitgeb on 9/18/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "ListItemCustomCell.h"
#import "StringHelper.h"


@implementation ListItemCustomCell

@synthesize checked, title, listItemsController, item, checkButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		
		// cell's check button
		self.checkButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
		self.checkButton.frame = CGRectZero;
		self.checkButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.checkButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		
		[ self.checkButton addTarget:self action:@selector(checkAction:) forControlEvents:UIControlEventTouchDown ];
		self.checkButton.backgroundColor = self.backgroundColor;
		[ self.contentView addSubview:self.checkButton ];
    }
    return self;
}

- (void)layoutSubviews {
	
	// Just clear out the cell on redraw, we have to re-create it depending on if it's in editing mode or not.
	NSEnumerator *enumerator = [[self.contentView subviews] objectEnumerator];
	id setObject;
	while ((setObject = [enumerator nextObject]) != nil) {
		[setObject removeFromSuperview];
	}
	
	if (self.editing) {
		// remove checkButton from cell
		[ self.checkButton removeFromSuperview ];
		
		// Reconfigure title to shift left
		UILabel *newLabel = [title RAD_newSizedCellLabelWithSystemFontOfSize:kTextViewFontSize x_pos:8.0f y_pos:10.0f];
		
		[self.contentView addSubview:newLabel];
		
		[newLabel release];
		
    } else {
		CGRect contentRect = [self.contentView bounds];
		
		// layout the check button image
		UIImage *checkedImage = [UIImage imageNamed:@"checked_larger.png"];
		
		CGRect frame = CGRectMake(contentRect.origin.x, 0.0, checkedImage.size.width, self.frame.size.height);
		checkButton.frame = frame;
		
		UIImage *image = (self.checked) ? checkedImage: [UIImage imageNamed:@"unchecked_larger.png"];
		[ checkButton setImage:image forState:UIControlStateNormal];
		[ checkButton setContentMode:UIViewContentModeCenter];
		
		[ self.contentView addSubview:checkButton ];
		
		UILabel *newLabel = [title RAD_newSizedCellLabelWithSystemFontOfSize:kTextViewFontSize x_pos:40.0f y_pos:10.0f];
		
		[self.contentView addSubview:newLabel];
		
		
		[ newLabel release ];
    }
	
	self.title = item.name;
	self.checked = ( [ item.completed intValue ] == 1 ? YES : NO );
	

	[super layoutSubviews];
}

// called when the checkmark button is touched 
- (void)checkAction:(id)sender {
	self.checked = !self.checked;
	[self.listItemsController toggleCompletedStateForItem:self.item];
}

- (void)dealloc {
	[checkButton release];
	[title release];
	[listItemsController release];
	[item release];
	
    [super dealloc];
}

@end
