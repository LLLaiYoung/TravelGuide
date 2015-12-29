//
//  CQTypeTravelViewController.m
//  CQTravelGuide
//
//  Created by chairman on 15/11/16.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "SightTableViewController.h"
#import "Sight.h"
#import "RXMLElement.h"
#import "DownLoadManager.h"
#import "DataBaseManager.h"
#import "CQSightTableViewCell.h"
@interface SightTableViewController ()

@property (strong, nonatomic) NSMutableArray *sightList;
@end

@implementation SightTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title  = self.currentType.typeName;
    //UIRefreshControl 只能用于tableViewController
    self.refreshControl = [[UIRefreshControl alloc]init];//下拉刷新

    [self.refreshControl addTarget:self action:@selector(reloadSight:) forControlEvents:UIControlEventValueChanged];//绑定Action
    
    NSLog(@"%@",[[DataBaseManager defaultManager] readSightListByType:self.currentType]);
     self.sightList=[[DataBaseManager defaultManager] readSightListByType:self.currentType];//读取数据库数据
    if (self.sightList.count==0 || !self.sightList) {
        [self reloadSight:nil];
    }
}

- (void)reloadSight:(UIRefreshControl *)sender {
    self.sightList = [[NSMutableArray alloc]init];
    NSInteger linkId = self.currentType.typeID.integerValue;
    NSString *link = [NSString stringWithFormat:@"http://1100163.sinaapp.com/open/?sort=%li",linkId];
    DownLoadManager *downLoadXML = [[DownLoadManager alloc]init];
    [downLoadXML downloadXML:link withData:^(NSData *data) {
        [self.refreshControl endRefreshing];//结束刷新
        [self parseXML:data];
    }];
}
//- (void)downloadXML:(NSString *)link {
//    NSURL *url = [NSURL URLWithString:link];
//    NSURLRequest * request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        if (connectionError) {
//            NSLog(@"链接错误:%@",connectionError);
//        }
//        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
//        if (code!=200) {
//            NSLog(@"响应错误代码:%li",code);
//        }
//        [self parseXML:data];
//    }];
//}

- (void)parseXML:(NSData *)data {
    RXMLElement *type = [RXMLElement elementFromXMLData:data];
    [type iterateWithRootXPath:@"//city" usingBlock:^(RXMLElement *sight) {
        Sight *aSight=[[Sight alloc]init];
        aSight.sightID=@([sight child:@"id"].text.integerValue);
        aSight.sightTypeID=@([sight child:@"sortid"].text.integerValue);
        aSight.sightName=[sight child:@"name"].text;
        aSight.sightBrief=[sight child:@"excerpt"].text;
        aSight.sightImageLink=[sight child:@"headimg"].text;
        aSight.sightCoordinate=[sight child:@"postion"].text;
        
        [self.sightList addObject:aSight];
    }];
    [[DataBaseManager defaultManager] saveSightList:self.sightList withSightType:self.currentType];//添加到数据库
    [self.tableView reloadData];
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
    return self.sightList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CQSightTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"detailCell" forIndexPath:indexPath];

    cell.theSight= self.sightList[indexPath.row];

    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"type2detail"]) {

        [segue.destinationViewController setValue:self.sightList[indexPath.row] forKey:@"theSight"];
    }
}


@end
