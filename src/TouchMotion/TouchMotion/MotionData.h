//
//  MotionData.h
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MotionData : NSObject

// 用户ID
@property (nonatomic, assign) int userID;

// 第几次测试
@property (nonatomic, assign) int testCount;

// 测试的是那种情况
// only 0, 1
// 0 means random
// 1 means preinstall
@property (nonatomic, assign) int testCase;

// 点击次数
@property (nonatomic, assign) int tapCount;

// only 0, 1, 2.
// 0 means beganTouch,
// 1 means moving events,
// 2 means endTouch
@property (nonatomic, assign) int movingFlag;

// only 0, 1, 2, 3.
// 0 means left thumb,
// 1 means right thumb,
// 2 means left index,
// 3 means right index
@property (nonatomic, assign) int handPosture;
// 触摸位置
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;

// 相对按钮的触摸Offset
@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat offsetY;

// DeviceMotion Sensor
@property (nonatomic, assign) double roll;
@property (nonatomic, assign) double pitch;
@property (nonatomic, assign) double yaw;

// Accelerator Sensor
@property (nonatomic, assign) double accx;
@property (nonatomic, assign) double accy;
@property (nonatomic, assign) double accz;

// Gyroscope Sensor
@property (nonatomic, assign) double rotationX;
@property (nonatomic, assign) double rotationY;
@property (nonatomic, assign) double rotationZ;

// 触摸时间
@property (nonatomic, copy) NSDate *time;



- (instancetype)initWithUserID:(int)userid
                  andTestCount:(int)testcount
                   andTestCase:(int)testcase
                   andTapCount:(int)tapcount
                 andMovingFlag:(int)movingflag
                andHandPosture:(int)handposture
                          andX:(CGFloat)x
                          andY:(CGFloat)y
                    andOffsetX:(CGFloat)offsetx
                    andOffsetY:(CGFloat)offsety
                       andRoll:(double)devroll
                      andPitch:(double)devpitch
                        andYaw:(double)devyaw
                       andAccX:(double)accx
                       andAccY:(double)accy
                       andAccZ:(double)accz
                  andRotationX:(double)rotationx
                  andRotationY:(double)rotationy
                  andRotationZ:(double)rotationz
                       andTime:(NSDate *)time;

@end
