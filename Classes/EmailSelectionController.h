//
//  EmailSelectionController.h
//  Listable
//
//  Created by Justin Leitgeb on 9/12/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CollaboratorsController.h"

@interface EmailSelectionController : UITableViewController {
	NSArray *emails;
	CollaboratorsController *collaboratorsController;
}

@property (nonatomic, retain) NSArray *emails;
@property (nonatomic, retain) CollaboratorsController *collaboratorsController;

@end
