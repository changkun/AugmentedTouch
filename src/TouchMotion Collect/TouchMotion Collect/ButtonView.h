//
//  ButtonView.h
//  TouchMotion Collect
//
//  Created by 欧长坤 on 24/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MotionData.h"

@protocol ButtonViewDelegate <NSObject>

// only 0, 1, 2. 0 means beganTouch, 1 means moving events, 2 means endTouch
- (void)onButtonViewClick:(MotionData *)data withFlag:(int)flag;
// only 1 and 0. 0 means left and 1 means right
- (int)whichHand;
- (int)currentUserID;
@end


@interface ButtonView : UIView

@property (nonatomic) NSInteger score;

@property (nonatomic, weak) id<ButtonViewDelegate> delegate;

+ (instancetype)buttonViewWithCornerRadius:(CGFloat)radius
                                     frame:(CGRect)frame
                           backgroundColor:(UIColor *)color
                                 textColor:(UIColor *)textColor
                                  textFont:(UIFont *)textFont
                                    number:(int)number;


@end
