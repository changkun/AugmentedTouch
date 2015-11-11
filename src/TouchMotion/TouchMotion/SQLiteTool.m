//
//  SQLiteTool.m
//  TouchMotion
//
//  Created by 欧长坤 on 10/11/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import <sqlite3.h>

#import "SQLiteTool.h"
#import "MotionData.h"
#import "MotionBuffer.h"

@implementation SQLiteTool

static sqlite3 *db;

+ (void)initialize {

    // 0. 获得沙盒中的数据库文件名
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TouchWithMotion.sqlite"];
    NSLog(@"%@",filepath);
    int result;
    
    // 1. 打开数据库, 当数据库不存在时候会自动创建
    result = sqlite3_open(filepath.UTF8String, &db);
    if (result == SQLITE_OK) {
        NSLog(@"successful open database TouchWithMotion.sqlite");
    }
    
    // 2. 创建表
    
    // 每个用户(user_id)可以测试多次(test_count)，每次测试可以点击多次(tap_count)，每次点击有不同的movingFlag
    const char *motionData = "CREATE TABLE IF NOT EXISTS MotionData ( \
    id INTEGER PRIMARY KEY AUTOINCREMENT,       \
    user_id INTEGER DEFAULT 0,                  \
    test_count INTEGER DEFAULT 0,               \
    test_case INTEGER DEFAULT 0,                \
    tap_count INTEGER DEFAULT 0,                \
    moving_flag INTEGER DEFAULT 0,              \
    hand_posture INTEGER DEFAULT 0,             \
                                                \
    x REAL DEFAULT 0,                           \
    y REAL DEFAULT 0,                           \
                                                \
    offset_x REAL DEFAULT 0,                    \
    offset_y REAL DEFAULT 0,                    \
                                                \
    roll REAL DEFAULT 0,                        \
    pitch REAL DEFAULT 0,                       \
    yaw REAL DEFAULT 0,                         \
                                                \
    acc_x REAL DEFAULT 0,                       \
    acc_y REAL DEFAULT 0,                       \
    acc_z REAL DEFAULT 0,                       \
                                                \
    rotation_x REAL DEFAULT 0,                  \
    rotation_y REAL DEFAULT 0,                  \
    rotation_z REAL DEFAULT 0,                  \
                                                \
    touch_time DATETIME DEFAULT (datetime('now','localtime')));";
    
//    const char *motionBuffer = "CREATE TABLE IF NOT EXISTS MotionBuffer ( \
//    id INTEGER PRIMARY KEY AUTOINCREMENT,       \
//    user_id INTEGER DEFAULT 0,                  \
//    tap_index INTEGER DEFAULT 0,                \
//    x REAL DEFAULT 0,                           \
//    y REAL DEFAULT 0,                           \
//    z REAL DEFAULT 0,                           \
//    hand INTEGER DEFAULT 0,                     \
//    sensor_flag INTEGER DEFAULT 0 );";
    
    char *error_msg = NULL;
    
    // 3. 执行
    result = sqlite3_exec(db, motionData, NULL, NULL, &error_msg);
    if (result == SQLITE_OK) {
        NSLog(@"successful open table MotionData");
    }
//    sqlite3_exec(db, motionBuffer, NULL, NULL, &error_msg);
    
}

+ (BOOL)wirteDataWithMotionData:(MotionData *)data {
    
    // 格式化时间
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormat stringFromDate:data.time];
    
    // 写入MotionData
    NSString *sql = [NSString stringWithFormat:@"insert into MotionData(    \
                     user_id,           \
                     test_count,        \
                     test_case,         \
                     tap_count,         \
                     moving_flag,       \
                     hand_posture,      \
                                        \
                     x,                 \
                     y,                 \
                                        \
                     offset_x,          \
                     offset_y,          \
                                        \
                     roll,              \
                     pitch,             \
                     yaw,               \
                                        \
                     acc_x,             \
                     acc_y,             \
                     acc_z,             \
                                        \
                     rotation_x,        \
                     rotation_y,        \
                     rotation_z,        \
                                        \
                     touch_time)        \
                     values (%d,%d,%d,%d,%d,%d, %f,%f,%f,%f, %f,%f,%f,%f,%f,%f,%f,%f,%f, datetime(\"%@\"));",
                     data.userID,
                     data.testCount,
                     data.testCase,
                     data.tapCount,
                     data.movingFlag,
                     data.handPosture,
                     data.x,
                     data.y,
                     data.offsetX,
                     data.offsetY,
                     data.roll,
                     data.pitch,
                     data.yaw,
                     data.accx,
                     data.accy,
                     data.accz,
                     data.rotationX,
                     data.rotationY,
                     data.rotationZ,
                     dateString];
    char *error_msg = NULL;
    int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, &error_msg);
    return result == SQLITE_OK;
}
+ (BOOL)writeBufferWithMotionBuffer:(MotionBuffer *)buffer {
    
    // 写入Buffer
    
    return YES;
}


+ (NSInteger)recordUserNumbers {
    const char *sql = "select count(DISTINCT user_id) from MotionData;";
    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    sqlite3_step(stmt);
    return sqlite3_column_double(stmt, 0);
}

+ (NSInteger)currentUserIDsTestCount:(int)userid {
    NSString *str = [NSString stringWithFormat:@"select count(DISTINCT test_count) from MotionData where user_id = %d;", userid];
    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(db, str.UTF8String, -1, &stmt, NULL);
    sqlite3_step(stmt);
    return sqlite3_column_double(stmt, 0);
}

+ (int)beginService{
    char *errmsg;
    int rc = sqlite3_exec(db, "BEGIN transaction", NULL, NULL, &errmsg);
    return rc;
}
+ (int)commitService{
    char *errmsg;
    int rc = sqlite3_exec(db, "COMMIT transaction", NULL, NULL, &errmsg);
    return rc;
}

+ (BOOL)removeAllMotionData {
    // 清空数据库
    const char * sql1 = "delete from MotionData;";
    char *error_msg = NULL;
    int result = sqlite3_exec(db, sql1, NULL, NULL, &error_msg);
    if (result == SQLITE_OK) {
        // 使primary key为0
        const char * sql2 = "UPDATE sqlite_sequence SET seq = 0 WHERE name='MotionData';";
        result = sqlite3_exec(db, sql2, NULL, NULL, &error_msg);
        return result == SQLITE_OK;
    } else {
        return NO;
    }
}

@end
