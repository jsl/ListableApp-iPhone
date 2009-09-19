//
//  EditListController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/19/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemList.h"
#import "ListItemsController.h"

@interface EditListController : UIViewController {
	IBOutlet UIButton *doneButton;
	IBOutlet UITextField *listNameTextField;

	ListItemsController *listItemsController;
	ItemList *list;
}

- (IBAction) doneButtonPressed: (id)sender;

@property (nonatomic, retain) IBOutlet UITextField *listNameTextField;
@property (nonatomic, retain) IBOutlet UIButton *doneButton;
@property (nonatomic, retain) ListItemsController *listItemsController;
@property (nonatomic, retain) ItemList *list;

@end
