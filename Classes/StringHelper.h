//
//  StringHelper.h
//  PTLog
//
//  Created by Ellen Miner on 1/2/09.
//  Copyright 2009 RaddOnline. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (StringHelper)
- (CGFloat)RAD_widthFromScreenSize;
- (CGFloat)RAD_textHeightForSystemFontOfSize:(CGFloat)size;
- (CGRect)RAD_frameForCellLabelWithSystemFontOfSize:(CGFloat)size x_pos:(CGFloat)x_pos y_pos:(CGFloat)y_pos;
- (UILabel *)RAD_newSizedCellLabelWithSystemFontOfSize:(CGFloat)size x_pos:(CGFloat)x_pos y_pos:(CGFloat)y_pos;
- (void)RAD_resizeLabel:(UILabel *)aLabel WithSystemFontOfSize:(CGFloat)size x_pos:(CGFloat)x_pos y_pos:(CGFloat)y_pos;
@end

