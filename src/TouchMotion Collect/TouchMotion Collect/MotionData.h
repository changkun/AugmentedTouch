//
//  MotionData.h
//  TouchMotion Collect
//
//  Created by 欧长坤 on 24/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MotionData : NSObject


@property (nonatomic, assign) int userID;
@property (nonatomic, assign) int tapCount;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign) double roll;
@property (nonatomic, assign) double pitch;
@property (nonatomic, assign) double yaw;
@property (nonatomic, assign) double accx;
@property (nonatomic, assign) double accy;
@property (nonatomic, assign) double accz;
@property (nonatomic, assign) double rotationRateX;
@property (nonatomic, assign) double rotationRateY;
@property (nonatomic, assign) double rotationRateZ;
@property (nonatomic, copy) NSDate *time;
@property (nonatomic, assign) int movingFlag; // only 0, 1, 2. 0 means beganTouch, 1 means moving events, 2 means endTouch
@property (nonatomic, assign) int hand; // only 1 and 0. 0 means left and 1 means right


- (instancetype)initWithUserID:(int)userID
                   andTapCount:(int)tapCount
                          andX:(CGFloat)x
                          andY:(CGFloat)y
                    andOffsetX:(CGFloat)offsetX
                    andOffsetY:(CGFloat)offsetY
                       andRoll:(double)roll
                      andPitch:(double)pitch
                        andYaw:(double)yaw
                       andAccX:(double)accX
                       andAccY:(double)accY
                       andAccZ:(double)accZ
              andRotationRateX:(double)rotationX
              andRotationRateY:(double)rotationY
              andRotationRateZ:(double)rotationZ
                       andHand:(int)hand
                       andTime:(NSDate *)time
                 andMovingFlag:(int)flag;

@end
