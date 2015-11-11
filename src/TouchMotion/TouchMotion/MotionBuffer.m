//
//  MotionBuffer.m
//  TouchMotion
//
//  Created by 欧长坤 on 10/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MotionBuffer.h"

@implementation MotionBuffer

- (instancetype)initWithSensorFlag:(int)flag {
    if ([super init] != nil) {
        for (int i = 0 ; i < BUFFER_FRAME; i++) {
            x[i] = y[i] = z[i] = 0;
        }
        tail = 0;
        sensorFlag = flag;
        
        handPosture = 0;
    }
    return self;
}

- (instancetype)initWithBuffer:(MotionBuffer *)buffer {
    if ([super init] != nil) {
        for (int i = 0; i < BUFFER_FRAME; i++) {
            x[i] = buffer->x[i];
            y[i] = buffer->y[i];
            z[i] = buffer->z[i];
        }
        tail = buffer->tail;
        handPosture = buffer->handPosture;
        userID = buffer->userID;
        tapCount= buffer->tapCount;
        sensorFlag = buffer->sensorFlag;
    }
    return self;
}

- (void)addX:(double)X Y:(double)Y Z:(double)Z {
    x[tail] = X;
    y[tail] = Y;
    z[tail] = Z;
    tail = (tail+1)%BUFFER_FRAME;
}

- (void)setHand:(int)Hand andUserID:(int)userid andTapIndex:(int)tapindex {
    handPosture = Hand;
    userID = userid;
    tapCount = tapindex;
}


- (int)getUserID {
    return userID;
}
- (int)getTail {
    return tail;
}
- (int)getTapIndex {
    return tapCount;
}
- (int)getSensorFlag {
    return sensorFlag;
}
- (int)getHand {
    return handPosture;
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
    NSString *str = [NSString stringWithFormat:@"(userID:%d, tapIndex:%d, hand:%d)", userID, tapCount, handPosture];
    return str;
}
@end