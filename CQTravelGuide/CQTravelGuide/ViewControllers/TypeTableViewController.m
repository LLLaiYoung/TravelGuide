//
//  CQTypeTableController.m
//  CQTravelGuide
//
//  Created by chairman on 15/11/10.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "TypeTableViewController.h"
#import "RXMLElement.h"
#import "SightType.h"
#import "DownLoadManager.h"
#import "DataBaseManager.h"
#import "FMDB.h"
#import "CQHeaderView.h"
@interface TypeTableViewController ()
<
HeaderViewPushDelegate
>

@property (nonatomic, strong) DataBaseManager *DBManager;
@property (nonatomic, assign) BOOL databaseHasData;///<数据库是否有数据
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) CQHeaderView *headerView;

@end

@implementation TypeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    NSDate *nowDate = [NSDate date];//获取系统当前时间
    self.DBManager = [[DataBaseManager alloc]init];
    NSDate *lastArchiveDate = self.DBManager.lastArchiveDate;//调取数据库最后存档时间

    
    long dateLongTime = nowDate.timeIntervalSinceNow - lastArchiveDate.timeIntervalSinceNow;
    NSLog(@"距离现在已经有%li小时",dateLongTime/60/60);//   秒/分/时
    NSUInteger dateTime = dateLongTime/60/60;
    BOOL isBig = dateTime>=8;//判断时间差(小时)是否大于需要自动从网络请求的时间 根据需求设定时间
    NSLog(@"%i",isBig);
    if (isBig || ![self.DBManager numberOfCQType]) {//当时间差大于3小时 或者数据库数据为空时
        self.databaseHasData = NO;
        if (![self.DBManager numberOfCQType]) {
            NSLog(@"数据库为空");
        }
    } else { //当时间差小于3小时 并且数据库数据不为空时
        self.databaseHasData = YES;
    }
    if (!self.databaseHasData) {//当数据库数据为不存在时
        [self refreshBarBtn:nil];
    }
    CQHeaderView *headerView = [[CQHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 300)];
    self.tableView.tableHeaderView = headerView;
    self.headerView = headerView;
    self.headerView.headerViewPushDelegate = self;
    [self motionBegan:UIEventSubtypeNone withEvent:nil];
}

- (void)praseXML:(NSData *)data {
    RXMLElement *root = [RXMLElement elementFromXMLData:data];
    if (!root) {    //当data为nil时候 直接return
        return;
    }
    [self.DBManager deleteAllSightType];//清空数据库
    [root iterateWithRootXPath:@"//city" usingBlock:^(RXMLElement *city) {
        NSString *typeID = [city child:@"id"].text;
        NSString *typeName = [city child:@"name"].text;
        SightType *theType = [[SightType alloc]init];
        theType.typeName =  typeName;
        theType.typeID = @(typeID.integerValue);

        [self.DBManager insertIntoCQTypeAtIndex:theType];//添加到数据库 离线缓存
    }];
    [self.tableView reloadData];
}
//刷新数据
- (IBAction)refreshBarBtn:(UIBarButtonItem *)sender {
    NSString *link = @"http://1100163.sinaapp.com/open/?sort=all";
    
    DownLoadManager *downLoadXML = [[DownLoadManager alloc]init];
    //block调用
    [downLoadXML downloadXML:link withData:^(NSData *data) {
        [self praseXML:data];
    }];
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
    return [self.DBManager numberOfCQType];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CQTypeCell" forIndexPath:indexPath];
    self.indexPath = indexPath;
    SightType *theType = [self.DBManager cqTypeAtIndex:indexPath.row];
    cell.textLabel.text = theType.typeName;
    return cell;
}

#pragma mark - HeaderViewPushDelegate
- (void)pushWithViewController:(UIViewController *)viewController {
    [self.navigationController pushViewController:viewController animated:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath * indexPath = [self.tableView indexPathForCell:sender];
    SightType *theType = [self.DBManager cqTypeAtIndex:indexPath.row];
    if ([segue.identifier isEqualToString:@"type2sign"]) {
        [segue.destinationViewController setValue:theType forKey:@"currentType"];
    }
}
#pragma mark - motion

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSArray *array =[[DataBaseManager defaultManager] randomSightOfNumber:4];
    NSLog(@"Random===%@",array);
    self.headerView.dataSource = array;
    [self.headerView reloadCollectionData];
}
@end
