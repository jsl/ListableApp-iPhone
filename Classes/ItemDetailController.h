//
//  ItemDetailController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/19/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Item.h"
#import "ListItemsController.h"

@interface ItemDetailController : UIViewController {
	IBOutlet UIButton *doneButton;
	IBOutlet UITextView *listNameTextView;
	IBOutlet UILabel *creatorEmailLabel;
	IBOutlet UILabel *createdAtLabel;

	ListItemsController *listItemsController;
	Item *item;
}

- (IBAction) doneButtonPressed: (id)sender;

@property (nonatomic, retain) IBOutlet UITextView *listNameTextView;
@property (nonatomic, retain) IBOutlet UILabel *creatorEmailLabel;
@property (nonatomic, retain) IBOutlet UILabel *createdAtLabel;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) ListItemsController *listItemsController;
@property (nonatomic, retain) Item *item;

@end


