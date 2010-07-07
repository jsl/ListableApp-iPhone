//
//  ListItemCustomCell.h
//  Listable
//
//  Created by Justin Leitgeb on 9/18/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ListItemCustomCell.h"
#import "Item.h"
#import "ListItemsController.h"

@interface ListItemCustomCell : UITableViewCell {
	NSString *title;
	
	UIButton *checkButton;
	
	Item *item;
	ListItemsController *listItemsController;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) ListItemsController *listItemsController;
@property (nonatomic, retain) Item *item;
@property (nonatomic, retain) UIButton *checkButton;

- (void)checkAction:(id)sender;

@end
