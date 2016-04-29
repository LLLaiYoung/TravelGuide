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
#import "MapViewController.h"
@interface SightTableViewController ()
<
UINavigationControllerDelegate,
UIImagePickerControllerDelegate
>

@property (strong, nonatomic) NSMutableArray *sightList;
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) Sight *theSight;
@property (nonatomic, strong) NSMutableArray *coordinates;
@end

@implementation SightTableViewController
- (NSMutableArray *)coordinates {
    if (!_coordinates) {
        _coordinates = [NSMutableArray array];
    }
    return _coordinates;
}
- (UIImagePickerController *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UIImagePickerController alloc] init];
        _imagePicker.delegate = self;
        _imagePicker.allowsEditing = YES;
    }
    return _imagePicker;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    self.title  = self.currentType.typeName;
    //UIRefreshControl 只能用于tableViewController
    self.refreshControl = [[UIRefreshControl alloc]init];//下拉刷新

    [self.refreshControl addTarget:self action:@selector(reloadSight:) forControlEvents:UIControlEventValueChanged];//绑定Action
    
    [self readData];
}
//读取数据
- (void)readData {
    self.sightList=[[DataBaseManager defaultManager] readSightListByType:self.currentType];//读取数据库数据
    if (self.sightList.count==0 || !self.sightList) {
        [self reloadSight:nil];
    } else {
        [self.tableView reloadData];
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
    cell.targer = self;
    cell.selector = @selector(didTap:);
    cell.theSight= self.sightList[indexPath.row];

    
    return cell;
}


- (void)didTap:(UITapGestureRecognizer *)sender {
    
    CQSightTableViewCell *cell = [self findCellWith:sender.view];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    self.theSight = self.sightList[indexPath.row];
    
    __weak typeof(self) weakSelf = self;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    //相机调用
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"拍照替换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            weakSelf.imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //  相机的调用为照相模式
            weakSelf.imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            //  设置为NO则隐藏了拍照按钮
            weakSelf.imagePicker.showsCameraControls = YES;
            //  设置相机摄像头默认为前置
            weakSelf.imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            //  设置相机闪光灯开关
            weakSelf.imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
            [weakSelf presentViewController:weakSelf.imagePicker animated:YES completion:nil];
            /**
             * 如果相机是英文
             *  设置info.plist Localized resources can be mixed = YES;
             */
        } else {
            NSLog(@"当前设备不支持相机调用");
        }
    }];
    [alertController addAction:photoAction];
    
    //相册读取
    UIAlertAction *photoAlbumAction = [UIAlertAction actionWithTitle:@"相册替换" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            weakSelf.imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            [weakSelf presentViewController:weakSelf.imagePicker animated:YES completion:nil];
        }
    }];
    [alertController addAction:photoAlbumAction];
    
    //保存到系统相册
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UIImageView *imageView = (UIImageView *)sender.view;
        UIImage *image = imageView.image;
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
    }];
    [alertController addAction:saveAction];
    
    //取消
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];

    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];

}
#pragma mark - 找cell
- (CQSightTableViewCell *)findCellWith:(UIView *)view {
    UIView *superView = view.superview;
    if (![superView isKindOfClass:[UIView class] ]) {
        return nil;
    }
    while (superView) {//window的superview为空
        if ([superView isKindOfClass:[CQSightTableViewCell class]]) {
            return (CQSightTableViewCell *)superView;
        }
        superView = superView.superview;
    }
    return nil;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"%s",__func__);
}
#pragma mark - UIImagePickerControllerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    NSLog(@"%@",info);
//    self.imageView.image = info[UIImagePickerControllerEditedImage];
    self.theSight.sightImageData = UIImagePNGRepresentation(info[UIImagePickerControllerEditedImage]);
    [[DataBaseManager defaultManager]updateSight:self.theSight];
    __weak typeof(self) weakSelf = self;
    [self dismissViewControllerAnimated:YES completion:^{
        [weakSelf readData];
    }];
    
}

- (IBAction)go2MapViewController:(UIBarButtonItem *)sender {
    [self.coordinates removeAllObjects];
    MapViewController *mapViewVC = [[MapViewController alloc] init];
    mapViewVC.title = self.title;
    mapViewVC.sights = self.sightList;
    [self.navigationController pushViewController:mapViewVC animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    if ([segue.identifier isEqualToString:@"type2detail"]) {

        [segue.destinationViewController setValue:self.sightList[indexPath.row] forKey:@"theSight"];
    }
}


@end
