//
//  ButtonView.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 24/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "ButtonView.h"

#import "AppDelegate.h"
#import "MotionData.h"
#import "MotionDataTool.h"
#import "AppDelegate.h"

#define DEFAULT_FRAME CGRectMake(0, 0, 140, 140)

@interface ButtonView()
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

- (void)motionDataCreateWithTouches:(NSSet<UITouch *> *)touches andMovingFlag:(int)flag {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    MotionData* data_all = [[MotionData alloc] initWithUserID:[self.delegate currentUserID]
                                                         andX:point.x+self.frame.origin.x
                                                         andY:point.y+self.frame.origin.y
                                                      andRoll:mManager.deviceMotion.attitude.roll
                                                     andPitch:mManager.deviceMotion.attitude.pitch
                                                       andYaw:mManager.deviceMotion.attitude.yaw
                                                      andAccX:mManager.accelerometerData.acceleration.x
                                                      andAccY:mManager.accelerometerData.acceleration.y
                                                      andAccZ:mManager.accelerometerData.acceleration.z
                                             andRotationRateX:mManager.gyroData.rotationRate.x
                                             andRotationRateY:mManager.gyroData.rotationRate.y
                                             andRotationRateZ:mManager.gyroData.rotationRate.z
                                                      andHand:[self.delegate whichHand]
                                                      andTime:[NSDate date]
                                                andMovingFlag:flag];
    
    NSLog(@"%@", data_all);
    
    [self.delegate onButtonViewClick:data_all withFlag:flag];
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
