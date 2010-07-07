//
//  ToggleImageControl.h
//  Listable
//
//  Created by Justin Leitgeb on 9/18/09.
//  Copyright 2009 Stack Builders Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ToggleImageControl : UIControl {
	BOOL selected;
	UIImageView *imageView;
	UIImage *normalImage;
	UIImage *selectedImage;	
}

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) UIImage *normalImage;
@property (nonatomic, retain) UIImage *selectedImage;

@end
