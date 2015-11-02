//
//  MotionDataTool.m
//  TouchMotion Collect
//
//  Created by 欧长坤 on 26/10/15.
//  Copyright © 2015 Changkun Ou. All rights reserved.
//

#import "MotionDataTool.h"
#import "MotionData.h"
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
        x REAL DEFAULT 0,                           \
        y REAL DEFAULT 0,                           \
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
        int result = sqlite3_exec(db, sql, NULL, NULL, &error_msg);
        if (result == SQLITE_OK) {
            NSLog(@"成功创建表");
        } else {
            NSLog(@"创建表失败: %s", error_msg);
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

//+ (BOOL)insertMotionData:(MotionData *)data {
//    NSString *sql = [NSString stringWithFormat:@"insert into touchesData(x, y, roll, pitch, yaw, hand) values (%f, %f, %f, %f, %f, %d);", data.x, data.y, data.roll, data.pitch, data.yaw, data.hand];
//    char *error_msg = NULL;
//    int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, &error_msg);
//    return result == SQLITE_OK;
//}

+ (BOOL)insertAllData:(MotionData *)data {
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString=[dateFormat stringFromDate:data.time];
    //    NSLog(@"%@", dateString);
    
    NSString *sql = [NSString stringWithFormat:@"insert into touchesData(user_id, x, y, roll, pitch, yaw, acc_x, acc_y, acc_z, rotation_x, rotation_y, rotation_z, hand, moving_flag, touch_time) values (%d, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %f, %d, %d, datetime(\"%@\"));", data.userID, data.x, data.y, data.roll, data.pitch, data.yaw, data.accx, data.accy, data.accz, data.rotationRateX, data.rotationRateY, data.rotationRateZ, data.hand, data.movingFlag, dateString];
    char *error_msg = NULL;
    int result = sqlite3_exec(db, sql.UTF8String, NULL, NULL, &error_msg);
    //    NSLog(@"%s", error_msg);
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