//
//  MotionBuffer.h
//  TouchMotion
//
//  Created by 欧长坤 on 10/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define BUFFER_FRAME 50
@interface MotionBuffer : NSObject
{
    double x[BUFFER_FRAME];
    double y[BUFFER_FRAME];
    double z[BUFFER_FRAME];
}

// 记录缓存尾部，数据连续的从 tail 至 tail-1
@property (nonatomic) int tail;


@property (nonatomic) int userID;
@property (nonatomic) int testCount;
@property (nonatomic) int testCase;
@property (nonatomic) int tapCount;
// 0 means devMotion, and when sensorFlag == 0 xyz means rool,pitch,yaw
// 1 means acc,
// 2 means gyro
@property (nonatomic) int sensorFlag;
@property (nonatomic) int handPosture;

// 每个用户(user_id)可以测试多次(test_count)，每次测试都记录是那种test_case，第tap_count次点击的buffer，
// (id, user_id, test_count, test_case, tap_count, sensor_flag, hand_posture, x, y, z )

// 初始化时，整个buffer都是0
- (instancetype)initWithUserID:(int)userid
                  andTestCount:(int)testcount
                   andTestCase:(int)testcase
                   andTapCount:(int)tapcount
                 andSensorFlag:(int)sensorflag
                andHandPosture:(int)handPosture;


// 拷贝构造
- (instancetype)initWithBuffer:(MotionBuffer *)buffer;

- (void)setUserID:(int)userid
     andTestCount:(int)testcount
      andTestCase:(int)testcase
      andTapCount:(int)tapcount
   andHandPosture:(int)handposture;

- (double)getXbyIndex:(int)i;
- (double)getYbyIndex:(int)i;
- (double)getZbyIndex:(int)i;

- (void)addX:(double)X Y:(double)Y Z:(double)Z;

@end
