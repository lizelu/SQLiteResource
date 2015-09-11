//
//  OperationSqliteTools.m
//  SettingBundleDemo
//
//  Created by Mr.LuDashi on 15/8/31.
//  Copyright (c) 2015年 zeluli. All rights reserved.
//

#import "OperationSqliteTools.h"

@implementation OperationSqliteTools

/*******************************
 *功能：打开数据库
 *参数：databaseName -- 数据库名称
 *返回：数据库对象（sqlite3对象）
 *******************************/
+ (sqlite3 *) openDatabaseWithName: (NSString *)databaseName{
    
    //将数据库文件复制到沙盒中
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //获取沙盒路径
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = paths[0];
    
    //拼接出数据库文件在沙盒中的路径
    NSString *sqlPath = [documentDirectory stringByAppendingPathComponent:databaseName];
    
    //判断沙盒中是否已经存在我们要打开的数据库文件
    BOOL success = [fileManager fileExistsAtPath:sqlPath];
    
    //不存在的情况，会从Bundle中把资源复制过去
    if (!success) {
        NSString *defautlDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:databaseName];
        
        NSError *error = nil;
        
        success = [fileManager copyItemAtPath:defautlDBPath toPath:sqlPath error:&error];
        
        if (!success) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
    //把路径转成C字符串
    const char * filePath = [sqlPath UTF8String];
    
    //声明sqlite3对象
    sqlite3 * database = nil;
    
    //打开数据库
    int result = sqlite3_open_v2(filePath, &database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    
    //成功打开
    if (result == SQLITE_OK) {
        return database;
    }
    
    return nil;
}

/*******************************
 *功能：关闭数据库
 *参数：database -- sqlite3 对象
 *返回：空
 *******************************/
+ (void) closeDatabaseWithName: (sqlite3 *)database{
    sqlite3_close(database);
}

/*******************************
 *功能：查询数据，无绑定变量
 *参数：database -- sqlite3 对象， SQL:要执行的SQL查询语句
 *返回：封装成数组的查询数据
 *******************************/
+ (NSArray *) queryInfoWithDataBase: (sqlite3 *) database
                            WithSQL: (NSString *) SQL{
    
    //获取预编译语句
    sqlite3_stmt *statement = [self prepareStatementWithSQL:SQL WithDatabase:database];
    
    //通过预编译语句获取数据
    NSArray *data = [self fetchDataWithStatement:statement];
    
    sqlite3_finalize(statement);
    
    
    return data;
}



/*******************************
 *功能：查询数据，有绑定变量
 *参数：database -- sqlite3 对象， SQL:要执行的SQL查询语句，parameter:绑定变量的值
 *返回：封装成数组的查询数据
 *******************************/
+ (NSArray *) queryInfoWithDataBase: (sqlite3 *) database
                            WithSQL: (NSString *) SQL
                      WithParameter: (NSArray *)parameter{
    
    //获取预编译语句
    sqlite3_stmt *statement = [self prepareStatementWithSQL:SQL WithDatabase:database];

    //绑定变量
    [self bindValueForSqliteStatement:&statement WithParameter:parameter];
    
    //通过预编译语句获取数据
    NSArray *data = [self fetchDataWithStatement:statement];
    
    sqlite3_finalize(statement);
    
    return data;

}

/*******************************
 *功能：插入数据
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:插入成功， NO:插入失败
 *******************************/
+ (BOOL) insertDataWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter{
    return [self executeSQLWithDataBase:database WithSQL:SQL WithParameter:parameter];
    
}

/*******************************
 *功能：更新数据
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:更新成功， NO:插入失败
 *******************************/
+ (BOOL) updateDataWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter{
    return [self executeSQLWithDataBase:database WithSQL:SQL WithParameter:parameter];
}


/*******************************
 *功能：删除数据
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:删除成功， NO:删除失败
 *******************************/
+ (BOOL) deleteDataWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter{
    return [self executeSQLWithDataBase:database WithSQL:SQL WithParameter:parameter];
}


/*******************************
 *功能：执行删除，更新，插入语句
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:更新成功， NO:插入失败
 *******************************/

+ (BOOL) executeSQLWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter{
    //预编译语句
    sqlite3_stmt *statement = [self prepareStatementWithSQL:SQL WithDatabase:database];
    
    //绑定变量
    [self bindValueForSqliteStatement:&statement WithParameter:parameter];
    
    //执行插入操作
    int insertResult = sqlite3_step(statement);
    
    NSLog(@"%d", insertResult);
    
    if (insertResult == SQLITE_DONE) {
        sqlite3_finalize(statement);
        return YES;
    }
    
    return NO;


}





/*******************************
 *功能：预编译SQL语句
 *参数：database -- sqlite3 对象， SQL:要执行的SQL查询语句
 *返回：预编译SQL语句
 *******************************/
+ (sqlite3_stmt *) prepareStatementWithSQL: (NSString *) SQL
                              WithDatabase: (sqlite3 *) database{
    //转成C字符串
    const char * zSql = [SQL UTF8String];
    
    //声明预编译语句
    sqlite3_stmt *statement = nil;
    
    //预编译SQL语句
    sqlite3_prepare_v2(database, zSql, -1, &statement, NULL);

    return statement;
}



/*******************************
 *功能：给预编译语句绑定变量
 *参数：statement -- 预编译语句指针地址， values: 要绑定的参数列表
 *返回：空
 *******************************/
+ (void) bindValueForSqliteStatement: (sqlite3_stmt **) statement
                       WithParameter: (NSArray *) values{
    //获取预编译语句的指针
    sqlite3_stmt *stmt = *statement;
    
    //循环给预编译语句中的变量赋值
    for (int i = 0; i < values.count; i ++) {
        
        id tempObj = values[i];
        
        //NSNumber类型处理
        if ([tempObj isKindOfClass: [NSNumber class]]) {
            
            if ([self isIntegerWithNumber:tempObj]) {
                //整型
                sqlite3_bind_int(stmt, i+1, [tempObj intValue]);
            } else {
                //浮点型
                sqlite3_bind_int(stmt, i+1, [tempObj floatValue]);
            }
            continue;
        }
        
        //字符串处理
        if ([tempObj isKindOfClass:[NSString class]]) {
            const char * tempString = [tempObj UTF8String];
            sqlite3_bind_text(stmt, i+1, tempString, -1, NULL);
            continue;
        }
    }
    
}

/*******************************
 *功能：判断NSNumber中是整型还是浮点型
 *参数：number -- NSNumber类型的参数
 *返回：Bool类型
 *******************************/

+ (BOOL) isIntegerWithNumber: (NSNumber *) number{
    float tempFloat = [number floatValue];
    
    int tempInt = [number intValue];
    
    return (tempFloat == tempInt);
}


/*******************************
 *功能：处理获取的数据
 *参数：statement -- 预编译SQL语句（sqlite3_stmt 对象）
 *返回：以数组的形式返回查询出来的数据
 *******************************/
+ (NSArray *) fetchDataWithStatement: (sqlite3_stmt *) statement{
    
    //获取产线结果的列数
    int columnCount = sqlite3_column_count(statement);
    
    NSMutableArray *rowArray = [[NSMutableArray alloc] init];
    
    //执行查询
    while (sqlite3_step(statement) == SQLITE_ROW) {
        
        NSMutableArray *columnArray = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < columnCount; i ++) {
            
            //获取对应列数的数据类型
            int columnType = sqlite3_column_type(statement, i);
            
            NSString *tempResult = @"";
            
            //根据类型使用不同的方法获取参数
            switch (columnType) {
                case SQLITE_INTEGER:
                {
                    int temp = sqlite3_column_int(statement, i);
                    tempResult = [NSString stringWithFormat:@"%d", temp];
                }
                    break;
                case SQLITE_FLOAT:
                {
                    double temp = sqlite3_column_double(statement, i);
                    tempResult = [NSString stringWithFormat:@"%lf", temp];
                }
                    break;
                    
                case SQLITE_TEXT:
                {
                    const unsigned char * temp = sqlite3_column_text(statement, i);
                    tempResult = [NSString stringWithUTF8String:(const char *)temp];
                }
                    
                    break;
                    
                case SQLITE_NULL:
                    
                default:
                    tempResult = @"";
                    break;
            }
            [columnArray addObject:tempResult];
        }
        
        [rowArray addObject:columnArray];
    }
    return [NSArray arrayWithArray:rowArray];
}

/*******************************
 *功能：打印出查询后的结果
 *参数：array -- 结果数组
 *返回：空
 *******************************/
+ (void) displayResultWithArray: (NSArray *) array{
    for (int row = 0; row < array.count; row ++){
        NSArray *rowArray = array[row];
        
        NSLog(@"\n\n第%d行", row);
        
        for (int column = 0; column < rowArray.count; column ++) {
            NSLog(@"第%d列数据：%@", column, rowArray[column]);
        }
    }
}




@end
