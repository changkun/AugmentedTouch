//
//  ButtonView.m
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//
#import <CoreMotion/CoreMotion.h>

#import "ButtonView.h"
#import "AppDelegate.h"
#import "MotionData.h"

@interface ButtonView ()
{
    CMMotionManager *mManager;
}

@property (nonatomic, strong) UILabel *scoreLabel;

@end

@implementation ButtonView

+ (instancetype)buttonViewWithCornerRadius:(CGFloat)radius
                                     frame:(CGRect)frame
                           backgroundColor:(UIColor *)color
                                 textColor:(UIColor *)textColor
                                  textFont:(UIFont *)textFont
                                    number:(int)number {
    ButtonView *view = [[[self class] alloc] initWithFrame:frame];
    view.score = number;
    view.layer.cornerRadius = radius;
    view.backgroundColor = color ?: [UIColor whiteColor];
    view.userInteractionEnabled = YES;
    if (textColor) {
        view.scoreLabel.textColor = textColor;
    }
    if (textFont) {
        view.scoreLabel.font = textFont;
    }
    return view;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) return nil;
    UILabel *scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:scoreLabel];
    self.scoreLabel = scoreLabel;
    mManager = [(AppDelegate *)[[UIApplication sharedApplication] delegate] sharedManager];
    return self;
}

- (void)setScore:(NSInteger)score {
    _score = score;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)score];
}

- (void)motionDataCreateWithTouches:(NSSet<UITouch *> *)touches andMovingFlag:(int)movingflag {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    MotionData* data = [[MotionData alloc] initWithUserID:[self.delegate currentUserID]
                                             andTestCount:[self.delegate currentTestCount]
                                              andTestCase:[self.delegate currentTestCase]
                                              andTapCount:[self.delegate currentTapCount]
                                            andMovingFlag:movingflag
                                           andHandPosture:[self.delegate currentHandPosture]
                                                     andX:point.x+self.frame.origin.x
                                                     andY:point.y+self.frame.origin.y
                                               andOffsetX:point.x
                                               andOffsetY:point.y
                                                  andRoll:mManager.deviceMotion.attitude.roll
                                                 andPitch:mManager.deviceMotion.attitude.pitch
                                                   andYaw:mManager.deviceMotion.attitude.yaw
                                                  andAccX:mManager.accelerometerData.acceleration.x
                                                  andAccY:mManager.accelerometerData.acceleration.y
                                                  andAccZ:mManager.accelerometerData.acceleration.z
                                             andRotationX:mManager.gyroData.rotationRate.x
                                             andRotationY:mManager.gyroData.rotationRate.y
                                             andRotationZ:mManager.gyroData.rotationRate.z
                                                  andTime:[NSDate date]];
    
    //NSLog(@"%@", data);
    
    [self.delegate onButtonViewClick:data withMovingFlag:movingflag withSeft:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [UIView beginAnimations:nil context:nil];
    self.backgroundColor = [UIColor lightGrayColor];
    self.scoreLabel.textColor = [UIColor lightGrayColor];
    [UIView commitAnimations];
    
    [self motionDataCreateWithTouches:touches andMovingFlag:0];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self motionDataCreateWithTouches:touches andMovingFlag:1];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [UIView beginAnimations:nil context:nil];
    self.backgroundColor = [UIColor colorWithRed:255 green:255 blue:255 alpha:0.8];
    [UIView commitAnimations];
    
    [self motionDataCreateWithTouches:touches andMovingFlag:2];
}


@end
