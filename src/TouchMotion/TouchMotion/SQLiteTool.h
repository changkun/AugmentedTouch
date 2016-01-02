//
//  SQLiteTool.h
//  TouchMotion
//
//  Created by 欧长坤 on 10/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <Foundation/Foundation.h>


@class MotionData;
@class MotionBuffer;

@interface SQLiteTool : NSObject

// 初始化数据库连接
+(void)initialize;

/**
 *  开启事务
 *
 *  @return 是否开启成功
 */
+(int)beginService;
/**
 *  提交事务
 *
 *  @return 是否提交成功
 */
+(int)commitService;

/**
 *  插入MotionData
 *
 *  @param data MotionData数据
 *
 *  @return 返回是否写入成功
 */
+ (BOOL)wirteDataWithMotionData:(MotionData *)data;
/**
 *  插入MotionBuffer
 *
 *  @param buffer 插入MotionBuffer数据
 *
 *  @return 返回是否成功
 */
+ (BOOL)writeBufferWithMotionBuffer:(MotionBuffer *)buffer;

/**
 *  清空所有的Motion数据
 *
 *  @return 返回是否清空成功
 */
+ (BOOL)removeAllMotion;
+ (BOOL)removeAllMotionData;
+ (BOOL)removeAllMotionBuffer;

// 查询所有的userID

// 查询当前有多少用户
+ (NSInteger)recordUserNumbers;
// 查询userid用户的testcount
+ (NSInteger)currentUserIDsTestCount:(int)userid;

@end
