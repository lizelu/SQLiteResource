//
//  CarTableViewController.m
//  SQLiteDemo
//
//  Created by ZeluLi on 15/9/10.
//  Copyright (c) 2015年 zeluli. All rights reserved.
//

#import "CarTableViewController.h"
#import "CarCell.h"
#import "OperationSqliteTools.h"
#import <sqlite3.h>
@interface CarTableViewController ()
@property (assign, nonatomic) sqlite3 *database;
@property (strong, nonatomic) NSArray *datasource;
@end

@implementation CarTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _database = [OperationSqliteTools openDatabaseWithName:@"Cars.sqlite"];
    
    [self queryInfoNoValuesWithSqlite:_database];
}


- (void) queryInfoNoValuesWithSqlite: (sqlite3 *) database{
    NSString * qureyInfo = @"SELECT * FROM CARBRAND";
    
    _datasource =  [OperationSqliteTools queryInfoWithDataBase:database WithSQL:qureyInfo];
    
    [self.tableView reloadData];
}

- (IBAction)insertData:(id)sender {
    [self insertIntoDataWithSqlite:_database];
}

- (void) insertIntoDataWithSqlite: (sqlite3 *) database{
    
    NSString *insertData = @"INSERT OR REPLACE INTO CARBRAND VALUES(?,?,?,?)";
    
    //获取最后一个索引
    NSArray *lastObject = [_datasource lastObject];
    
    NSInteger brandId = [lastObject[0] integerValue];
    
    NSArray *data = @[@(brandId + 1), @"悍马哈哈哈", @"H", @"http://img.autoimg.cn/logo/brand/100/130090252174664593.jpg"];
    
    BOOL result = [OperationSqliteTools insertDataWithDataBase:database WithSQL:insertData WithParameter:data];
    
    if (result) {
        [self queryInfoNoValuesWithSqlite:database];
    } else {
        NSLog(@"插入失败");
    }
}


-(void) deleteDataWithBrandId: (NSNumber *) brandId{
    NSString *deleteSql = @"DELETE FROM CARBRAND WHERE BRANDID=?";
    
    NSArray *data = @[brandId];
    
    BOOL result = [OperationSqliteTools deleteDataWithDataBase:_database WithSQL:deleteSql WithParameter:data];
    
    if (result) {
         [self queryInfoNoValuesWithSqlite:_database];
    } else {
        NSLog(@"删除失败");
    }
    
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return _datasource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CarCell" forIndexPath:indexPath];
    [cell setCellDataWithArray:_datasource[indexPath.row]];
    [self transitionWithType:kCATransitionPush WithSubtype:indexPath.row ForView:cell];
    return cell;
}

#pragma CATransition动画实现
- (void) transitionWithType:(NSString *) type WithSubtype:(NSInteger) row ForView : (UIView *) view
{
    NSString *subtype = nil;
    if (row%2 == 0) {
        subtype = kCATransitionFromLeft;
    } else {
        subtype = kCATransitionFromRight;
    }
    
    //创建CATransition对象
    CATransition *animation = [CATransition animation];
    
    //设置运动时间
    animation.duration = 0.5f;
    
    //设置运动type
    animation.type = type;
    if (subtype != nil) {
        
        //设置子类
        animation.subtype = subtype;
    }
    
    //设置运动速度
    animation.timingFunction = UIViewAnimationOptionCurveEaseInOut;
    
    [view.layer addAnimation:animation forKey:@"animation"];
}




// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self deleteDataWithBrandId:_datasource[indexPath.row][0]];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
