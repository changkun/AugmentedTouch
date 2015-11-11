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

// 开启事务
+(int)beginService;
// 提交事务
+(int)commitService;

// 插入MotionData
+ (BOOL)wirteDataWithMotionData:(MotionData *)data;
// 插入MotionBUffer
+ (BOOL)writeBufferWithMotionBuffer:(MotionBuffer *)buffer;

// 清空数据
+ (BOOL)removeAllMotion;
+ (BOOL)removeAllMotionData;
+ (BOOL)removeAllMotionBuffer;

// 查询所有的userID

// 查询当前有多少用户
+ (NSInteger)recordUserNumbers;
// 查询userid用户的testcount
+ (NSInteger)currentUserIDsTestCount:(int)userid;

@end
