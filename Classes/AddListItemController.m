//
//  AddListItemController.m
//  SharedList
//
//  Created by Justin Leitgeb on 9/11/09.
//  Copyright 2009 Stack Builders Inc.. All rights reserved.
//

#import "Constants.h"
#import "AddListItemController.h"

#import "ListItemsController.h"

@implementation AddListItemController

@synthesize listItemNameTextField;
@synthesize listItemsController;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (IBAction) doneButtonPressed:(id)sender {
	[ self.listItemsController addListItemWithName:listItemNameTextField.text ];
	[ self.navigationController popViewControllerAnimated:YES ];
}

// Gets rid of the keyboard no matter what the responder is
- (void)dropKickResponder {
	[ listItemNameTextField resignFirstResponder ];
}

-(IBAction)dismissKeyboard: (id)sender {
	[ self dropKickResponder ];
}

- (void)textFieldDidEndEditing:(UITextField *)theTextField {
	[ self dropKickResponder ];
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
	[ self dropKickResponder ];
	
	return YES;
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	[ listItemNameTextField becomeFirstResponder ];
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
    [ super didReceiveMemoryWarning ];	
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	[ listItemsController release ];
	[ listItemNameTextField release ];
	
    [ super dealloc ];
}

@end
