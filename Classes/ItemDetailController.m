//
//  ItemDetailController.m
//  Listable
//
//  Created by Justin Leitgeb on 9/19/09.
//  Copyright 2009 BlockStackers. All rights reserved.
//

#import "ItemDetailController.h"


@implementation ItemDetailController

@synthesize listNameTextView;
@synthesize createdAtLabel;
@synthesize creatorEmailLabel;

@synthesize doneButton;
@synthesize listItemsController;
@synthesize item;


/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
	[ self.listNameTextView becomeFirstResponder ];
	self.listNameTextView.text = item.name;
	self.createdAtLabel.text = item.createdAt;
	self.creatorEmailLabel.text = item.creatorEmail;
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (IBAction) doneButtonPressed: (id)sender {
	[listItemsController updateAttributeOnItem:item attribute:@"name" newValue:self.listNameTextView.text displayMessage:@"Updating list item..."];
	
	[self.navigationController popViewControllerAnimated:YES];
}

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
	[listNameTextView release];
	[createdAtLabel release];
	[creatorEmailLabel release];
	
	[doneButton release];
	[listItemsController release];
	[item release];
	
    [super dealloc];
}


@end
