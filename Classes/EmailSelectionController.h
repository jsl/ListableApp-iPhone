//
//  EmailSelectionController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ListItemsController.h"

@interface EmailSelectionController : UITableViewController {
	NSArray *emails;
	ListItemsController *listItemsController;
}

@property (nonatomic, retain) NSArray *emails;
@property (nonatomic, retain) ListItemsController *listItemsController;

@end
