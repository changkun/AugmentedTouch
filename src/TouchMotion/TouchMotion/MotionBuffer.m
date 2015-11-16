//
//  MotionBuffer.m
//  TouchMotion
//
//  Created by 欧长坤 on 10/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MotionBuffer.h"

@implementation MotionBuffer

- (instancetype)initWithUserID:(int)userid andTestCount:(int)testcount andTestCase:(int)testcase andTapCount:(int)tapcount andSensorFlag:(int)sensorflag andHandPosture:(int)handposture {
    if ([super init] != nil) {
        _tail = 0;
        for (int i = 0 ; i < BUFFER_FRAME; i++) {
            x[i] = y[i] = z[i] = 0;
        }
        _userID = userid;
        _testCount = testcount;
        _testCase = testcase;
        _tapCount = tapcount;
        _sensorFlag = sensorflag;
        _handPosture = handposture;
    }
    return self;

}

// 拷贝构造(copy constructor)
- (instancetype)initWithBuffer:(MotionBuffer *)buffer {
    if ([super init] != nil) {
        _tail = buffer.tail;
        for (int i = 0; i < BUFFER_FRAME; i++) {
            x[i] = buffer->x[i];
            y[i] = buffer->y[i];
            z[i] = buffer->z[i];
        }
        _userID = buffer.userID;
        _testCount = buffer.testCount;
        _testCase = buffer.testCase;
        _tapCount = buffer.tapCount;
        _sensorFlag = buffer.sensorFlag;
        _handPosture = buffer.handPosture;
    }
    return self;
}

- (void)addX:(double)X Y:(double)Y Z:(double)Z {
    x[_tail] = X;
    y[_tail] = Y;
    z[_tail] = Z;
    _tail = (_tail+1)%BUFFER_FRAME;
}

- (void)setUserID:(int)userid andTestCount:(int)testcount andTestCase:(int)testcase andTapCount:(int)tapcount andHandPosture:(int)handposture {
    _userID = userid;
    _testCount = testcount;
    _testCase = testcase;
    _tapCount = tapcount;
    _handPosture = handposture;
}

- (double)getXbyIndex:(int)i {
    return x[i];
}
- (double)getYbyIndex:(int)i {
    return y[i];
}
- (double)getZbyIndex:(int)i {
    return z[i];
}
-(NSString *)description {
    NSString *str = [NSString stringWithFormat:@"(%d,%d,%d,%d,%d,%d)",
                     _userID,
                     _testCount,
                     _testCase,
                     _tapCount,
                     _sensorFlag,
                     _handPosture];
    return str;
}
@end