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
    
    // 记录缓存尾部，数据连续的从 tail 至 tail-1
    int tail;
    
    // 0 means devMotion,
    // 1 means acc,
    // 2 means gyro
    int sensorFlag;
    
    int userID;
    int tapCount;
    int handPosture;
}

// 初始化时，整个buffer都是0
- (instancetype)initWithSensorFlag:(int)flag;
- (instancetype)initWithBuffer:(MotionBuffer *)buffer;

- (void)setHand:(int)Hand andUserID:(int)userid andTapIndex:(int)tapindex;

- (int)getUserID;
- (int)getTail;
- (int)getSensorFlag;
- (int)getTapIndex;
- (int)getHand;
- (double)getXbyIndex:(int)i;
- (double)getYbyIndex:(int)i;
- (double)getZbyIndex:(int)i;


- (void)addX:(double)X Y:(double)Y Z:(double)Z;

@end
