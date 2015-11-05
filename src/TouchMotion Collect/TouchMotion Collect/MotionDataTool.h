//
//  MotionDataTool.h
//  TouchMotion Collect
//
//  Created by 欧长坤 on 26/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MotionData;
@class MotionBuffer;

@interface MotionDataTool : NSObject

+ (void)initialize;

// 调用整个数据集(当前只查询x,y,roll,hand)
+ (NSArray *)getMotionData;

// 插入MotionData
//+ (BOOL)insertMotionData:(MotionData *)data;

// 插入全部数据
+ (BOOL)insertAllData:(MotionData *)data;
//+ (BOOL)writeBufferDataWithUserID:(int)userID
//                         tapCount:(int)tapCount
//                                X:(double)X
//                                Y:(double)Y
//                                Z:(double)Z
//                       sensorFlag:(int)flag;
+ (BOOL)writeBufferDataWithBuffer:(MotionBuffer *)buffer;

+ (BOOL)removeAllData;
+ (BOOL)removeallBufferData;
+ (NSInteger)recordNumber;
+ (NSInteger)recordSamples;

@end
