//
//  MotionData.m
//  TouchMotion
//
//  Created by 欧长坤 on 09/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MotionData.h"

@implementation MotionData

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
                       andTime:(NSDate *)time {
    if (self == [super init]) {
        _userID = userid;
        _testCount = testcount;
        _testCase = testcase;
        _tapCount = tapcount;
        _movingFlag = movingflag;
        _handPosture = handposture;
        
        _x = x;
        _y = y;
        _offsetX = offsetx;
        _offsetY = offsety;
        
        _roll = devroll;
        _pitch = devpitch;
        _yaw = devyaw;
        
        _accx = accx;
        _accy = accy;
        _accz = accz;
        
        _rotationX = rotationx;
        _rotationY = rotationy;
        _rotationZ = rotationz;

        _time = time;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"( %d,%d,%d,%d,%d | %f,%f,%f,%f | %f,%f,%f | %f,%f,%f | %f,%f,%f | '%@' )",
            _userID,
            _testCount,
            _testCase,
            _tapCount,
            _movingFlag,
            
            _x,
            _y,
            _offsetX,
            _offsetY,
            
            _roll,
            _pitch,
            _yaw,
            
            _accx,
            _accy,
            _accz,
            
            _rotationX,
            _rotationY,
            _rotationZ,
            
            _time];
}

@end
