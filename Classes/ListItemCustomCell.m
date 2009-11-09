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

@synthesize title, listItemsController, item, checkButton;

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
		self.checkButton.tag = 99;
		
		[ self.contentView addSubview:self.checkButton ];
    }
    return self;
}

// called when the checkmark button is touched 
- (void)checkAction:(id)sender {	
	[ self.listItemsController toggleCompletedStateForItem:self.item ];
}

- (void)dealloc {
	[checkButton release];
	[title release];
	[listItemsController release];
	[item release];
	
    [super dealloc];
}

@end
