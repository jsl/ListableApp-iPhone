//
//  AddListItemController.h
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListItemsController.h"

@interface AddListItemController : UIViewController {
	IBOutlet UIButton *doneButton;
	IBOutlet UITextField *listItemNameTextField;
	
	ListItemsController *listItemsController;
}

- (IBAction) doneButtonPressed: (id)sender;
- (IBAction) dismissKeyboard: (id)sender;

@property (nonatomic, retain) ListItemsController *listItemsController;
@property (nonatomic, retain) IBOutlet UITextField *listItemNameTextField;

@end


