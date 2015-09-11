//
//  OperationSqliteTools.h
//  SettingBundleDemo
//
//  Created by Mr.LuDashi on 15/8/31.
//  Copyright (c) 2015年 zeluli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface OperationSqliteTools : NSObject

/*******************************
 *功能：打开数据库
 *参数：databaseName -- 数据库名称
 *返回：数据库对象（sqlite3对象）
 *******************************/
+ (sqlite3 *) openDatabaseWithName: (NSString *)databaseName;

/*******************************
 *功能：关闭数据库
 *参数：database -- sqlite3 对象
 *返回：空
 *******************************/
+ (void) closeDatabaseWithName: (sqlite3 *)database;

/*******************************
 *功能：查询数据，无绑定变量
 *参数：database -- sqlite3 对象， SQL:要执行的SQL查询语句
 *返回：封装成数组的查询数据
 *******************************/
+ (NSArray *) queryInfoWithDataBase: (sqlite3 *) database
                            WithSQL: (NSString *) SQL;


/*******************************
 *功能：查询数据，有绑定变量
 *参数：database -- sqlite3 对象， SQL:要执行的SQL查询语句，parameter:绑定变量的值
 *返回：封装成数组的查询数据
 *******************************/
+ (NSArray *) queryInfoWithDataBase: (sqlite3 *) database
                            WithSQL: (NSString *) SQL
                      WithParameter: (NSArray *)parameter;


/*******************************
 *功能：插入数据
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:插入成功， NO:插入失败
 *******************************/
+ (BOOL) insertDataWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter;

/*******************************
 *功能：更新数据
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:更新成功， NO:更新失败
 *******************************/
+ (BOOL) updateDataWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter;


/*******************************
 *功能：删除数据
 *参数：database -- sqlite3 对象， SQL:要执行的SQL插入语句，parameter:绑定变量的值
 *返回：插入结果，YES:删除成功， NO:删除失败
 *******************************/
+ (BOOL) deleteDataWithDataBase: (sqlite3 *) database
                        WithSQL: (NSString *) SQL
                  WithParameter: (NSArray *)parameter;

/*******************************
 *功能：打印出查询后的结果
 *参数：array -- 结果数组
 *返回：空
 *******************************/
+ (void) displayResultWithArray: (NSArray *) array;


@end
