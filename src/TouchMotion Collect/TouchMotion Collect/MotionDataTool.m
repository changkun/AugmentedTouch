//
//  MotionDataTool.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 26/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MotionDataTool.h"
#import "MotionData.h"
#import "MotionBuffer.h"
#import <sqlite3.h>

@implementation MotionDataTool

// static 保证db这个变量只能在这个.m文件中直接访问
static sqlite3 *db;

// 这个方法会在第一次使用MotionDataTool的时候自动调用
+ (void)initialize {
    // 0. 获得沙盒中的数据库文件名
    NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"TouchWithMotionData.sqlite"];
    NSLog(@"%@", filepath);
    // 1. sqlite3_open 创建(打开)数据库，当文件不存在时会自动创建
    int result = sqlite3_open(filepath.UTF8String, &db);
    
    if (result == SQLITE_OK) {
        NSLog(@"打开数据库成功");
        
        // 2. 创建表
        
        // (id, UserID, x, y, roll, pitch, yaw, accX, accY, accZ, rotationX, rotationY, rotationZ, hand, movingFlag, TouchTime)
        
        const char *sql = "CREATE TABLE IF NOT EXISTS touchesData ( \
        id INTEGER PRIMARY KEY AUTOINCREMENT,       \
        user_id INTEGER DEFAULT 0,                  \
        tap_count INTEGER DEFAULT 0,                \
        x REAL DEFAULT 0,                           \
        y REAL DEFAULT 0,                           \
        offset_x REAL DEFAULT 0,                    \
        offset_y REAL DEFAULT 0,                    \
        roll REAL DEFAULT 0,                        \
        pitch REAL DEFAULT 0,                       \
        yaw REAL DEFAULT 0,                         \
        acc_x REAL DEFAULT 0,                       \
        acc_y REAL DEFAULT 0,                       \
        acc_z REAL DEFAULT 0,                       \
        rotation_x REAL DEFAULT 0,                  \
        rotation_y REAL DEFAULT 0,                  \
        rotation_z REAL DEFAULT 0,                  \
        hand INTEGER DEFAULT 0,                     \
        moving_flag INTEGER DEFAULT 0,              \
        touch_time DATETIME DEFAULT (datetime('now','localtime')));";
        
        char *error_msg = NULL;
        
//        const char *sql1 = "drop table touchesData;";
//        const char *sql2 = "drop table sensorBuffer;";
//        sqlite3_exec(db, sql1, NULL, NULL, &error_msg);
//        sqlite3_exec(db, sql2, NULL, NULL, &error_msg);
        
        int result = sqlite3_exec(db, sql, NULL, NULL, &error_msg);
        if (result == SQLITE_OK) {
            NSLog(@"成功创建表");
        } else {
            NSLog(@"创建表失败: %s", error_msg);
        }
    } else {
        NSLog(@"打开数据库失败, error number: %d", result);
    }
    
    if (result == SQLITE_OK) {
        NSLog(@"打开数据库成功");
        
        // 2. 创建表
        
        // (id, UserID, x, y, roll, pitch, yaw, accX, accY, accZ, rotationX, rotationY, rotationZ, hand, movingFlag, TouchTime)
        

        
        const char *sql = "CREATE TABLE IF NOT EXISTS sensorBuffer ( \
        id INTEGER PRIMARY KEY AUTOINCREMENT,       \
        user_id INTEGER DEFAULT 0,                  \
        tap_index INTEGER DEFAULT 0,                \
        x REAL DEFAULT 0,                           \
        y REAL DEFAULT 0,                           \
        z REAL DEFAULT 0,                           \
        hand INTEGER DEFAULT 0,                     \
        sensor_flag INTEGER DEFAULT 0 );";

        char *error_msg = NULL;

//        const char *sql3 = "drop table sensorBuffer;";
//        sqlite3_exec(db, sql3, NULL, NULL, &error_msg);

        
        
        int result = sqlite3_exec(db, sql, NULL, NULL, &error_msg);
        if (result == SQLITE_OK) {
            NSLog(@"成功创建sensorBuffer表");
        } else {
            NSLog(@"创建sensorBuffer表失败: %s", error_msg);
        }
    } else {
        NSLog(@"打开数据库失败, error number: %d", result);
    }
}

+ (NSArray *)getMotionData {
    // 0. 定义结果数组
    NSMutableArray *requestData = nil;
    
    // 1. 定义SQL语句
    const char *sql = "select x, y, roll, hand from touchesData where moving_flag = 0;";
    
    // 2. 定义一个结果存放集
    sqlite3_stmt *stmt = NULL;
    
    // 3. 检查SQL语句的合法性
    int result = sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    
    if (result == SQLITE_OK) {
        requestData = [NSMutableArray array];
        // 语句合法, 执行并取出结果
        while (sqlite3_step(stmt) == SQLITE_ROW) {
            MotionData *data = [[MotionData alloc] init];
            // 获得第0列的数据
            data.x = sqlite3_column_double(stmt, 0);
            data.y = sqlite3_column_double(stmt, 1);
            data.roll = sqlite3_column_double(stmt, 2);
            data.hand = sqlite3_column_double(stmt, 3);
            
            [requestData addObject:data];
        }
    } else {
        NSLog(@"SQL语句不合法");
    }
    return requestData;
}

+ (BOOL)insertAllData:(MotionData *)data {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormat stringFromDate:data.time];
    //    NSLog(@"%@", dateString);
    
    NSString *sql = [NSString stringWithFormat:@"insert into touchesData( \
                     user_id,           \
                     tap_count,         \
                     x,                 \
                     y,                 \
                     offset_x,          \
                     offset_y,          \
                     roll,              \
                     pitch,             \
                     yaw,               \
                     acc_x,             \
                     acc_y,             \
                     acc_z,             \
                     rotation_x,        \
                     rotation_y,        \
                     rotation_z,        \
                     hand,              \
                     moving_flag,       \
                     touch_time)        \
        values (%d, %d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d, datetime(\"%@\"));",
                     data.userID,
                     data.tapCount,
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
                     data.rotationRateX,
                     data.rotationRateY,
                     data.rotationRateZ,
                     data.hand,
                     data.movingFlag,
                     dateString];
    char *error_msg = NULL;
    int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, &error_msg);
    //    NSLog(@"%s", error_msg);
    return result == SQLITE_OK;
}

+(int)beginService{
    char *errmsg;
    int rc = sqlite3_exec(db, "BEGIN transaction", NULL, NULL, &errmsg);
    return rc;
}
+(int)commitService{
    char *errmsg;
    int rc = sqlite3_exec(db, "COMMIT transaction", NULL, NULL, &errmsg);
    return rc;
}

+ (BOOL)writeBufferDataWithBuffer:(MotionBuffer *)buffer {
    int result = SQLITE_OK;
    
    NSLog(@"%@", buffer);
    
    int start = [buffer getTail];
    int end;
    if (start == 0) {
        end = BUFFER_FRAME-1;
    } else {
        end = start-1;
    }
    
    for (int i = start; i != end; i = (i+1)%BUFFER_FRAME) {
        NSString *sql = [NSString stringWithFormat:@"insert into sensorBuffer   \
                         (user_id, tap_index, x, y, z, hand, sensor_flag)       \
                         values(%d,      %d,       %f,%f,%f, %d, %d)",
                         [buffer getUserID],
                         [buffer getTapIndex],
                         [buffer getXbyIndex:i],
                         [buffer getYbyIndex:i],
                         [buffer getZbyIndex:i],
                         [buffer getHand],
                         [buffer getSensorFlag]];
        char *error_msg = NULL;
        result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, &error_msg);
    }
    return result == SQLITE_OK;
}


+ (BOOL)removeAllData {
    // 清空数据库
    const char * sql1 = "delete from touchesData;";
    char *error_msg = NULL;
    int result = sqlite3_exec(db, sql1, NULL, NULL, &error_msg);
    if (result == SQLITE_OK) {
        // 使primary key为0
        const char * sql2 = "UPDATE sqlite_sequence SET seq = 0 WHERE name='touchesData';";
        result = sqlite3_exec(db, sql2, NULL, NULL, &error_msg);
        return result == SQLITE_OK;
    } else {
        return NO;
    }
}

+ (BOOL)removeallBufferData {
    // 清空数据库
    const char * sql1 = "delete from sensorBuffer;";
    char *error_msg = NULL;
    int result = sqlite3_exec(db, sql1, NULL, NULL, &error_msg);
    if (result == SQLITE_OK) {
        // 使primary key为0
        const char * sql2 = "UPDATE sqlite_sequence SET seq = 0 WHERE name='sensorBuffer';";
        result = sqlite3_exec(db, sql2, NULL, NULL, &error_msg);
        
//        // 调试用
//        const char *sql3 = "drop table sensorBuffer;";
//        result = sqlite3_exec(db, sql3, NULL, NULL, &error_msg);

        return result == SQLITE_OK;
    } else {
        return NO;
    }
    
    
}

+ (NSInteger)recordNumber {
    const char *sql = "select count(*) from touchesData;";
    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    sqlite3_step(stmt);
    return sqlite3_column_double(stmt, 0);
}

+ (NSInteger)recordSamples {
    const char *sql = "select count(DISTINCT user_id) from touchesData;";
    sqlite3_stmt *stmt = NULL;
    sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    sqlite3_step(stmt);
    return sqlite3_column_double(stmt, 0);
}


////执行插入事务语句
//+ (void)execInsertTransactionSql:(NSMutableArray *)transactionSql
//{
//    //使用事务，提交插入sql语句
//    @try{
//        char *errorMsg;
//        if (sqlite3_exec(database, "BEGIN", NULL, NULL, &errorMsg)==SQLITE_OK)
//        {
//            NSLog(@"启动事务成功");
//            sqlite3_free(errorMsg);
//            sqlite3_stmt *statement;
//            for (int i = 0; i<transactionSql.count; i++)
//            {
//                if (sqlite3_prepare_v2(database,[[transactionSql objectAtIndex:i] UTF8String], -1, &statement,NULL)==SQLITE_OK)
//                {
//                    if (sqlite3_step(statement)!=SQLITE_DONE) sqlite3_finalize(statement);
//                }
//            }
//            if (sqlite3_exec(database, "COMMIT", NULL, NULL, &errorMsg)==SQLITE_OK)   NSLog(@"提交事务成功");
//            sqlite3_free(errorMsg);
//        }
//        else sqlite3_free(errorMsg);
//    }
//    @catch(NSException *e)
//    {
//        char *errorMsg;
//        if (sqlite3_exec(database, "ROLLBACK", NULL, NULL, &errorMsg)==SQLITE_OK)  NSLog(@"回滚事务成功");
//        sqlite3_free(errorMsg);
//    }
//    @finally{}
//}

@end