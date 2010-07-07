//
//  ShakeableTableView.h
//  Listable
//
//  Created by Justin Leitgeb on 9/19/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShakeableTableView : UITableView {
	id viewDelegate;
}

@property (nonatomic, retain) id viewDelegate;

@end
