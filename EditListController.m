//
//  EditListController.m
//  Listable
//
//  Created by Justin Leitgeb on 9/19/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "EditListController.h"
#import "ItemList.h"

@implementation EditListController

@synthesize listNameTextField;
@synthesize doneButton;
@synthesize listItemsController;
@synthesize list;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [ super viewDidLoad ];
	
	[ self.listNameTextField becomeFirstResponder ];
	self.listNameTextField.text = list.name;
}

- (IBAction) doneButtonPressed: (id)sender {
	[ listItemsController updateListName:self.list name:self.listNameTextField.text ];	
	listItemsController.loadingWithUpdate = YES; // Tell it not to automatically load remote data until we finish.
	listItemsController.itemList.name = self.listNameTextField.text;
	
	[self.navigationController popViewControllerAnimated:YES];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[ listNameTextField release ];
	[ doneButton release ];
	[ listItemsController release ];
	[ list release ];
	
    [super dealloc];
}

@end
