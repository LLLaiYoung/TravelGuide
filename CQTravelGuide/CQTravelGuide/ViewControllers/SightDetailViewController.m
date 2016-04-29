//
//  CQsightDetailViewController.m
//  CQTravelGuide
//
//  Created by chairman on 15/11/16.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "SightDetailViewController.h"
#import "Sight.h"
#import "RXMLElement.h"
#import "DownLoadManager.h"
#import "DataBaseManager.h"
#import "MapViewController.h"

@interface SightDetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation SightDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = self.theSight.sightName;
    NSLog(@"%li",self.theSight.sightID.integerValue);
    if (self.theSight.sightHTMLString) {
        [self.webView loadHTMLString:self.theSight.sightHTMLString baseURL:nil];
    } else {
        NSString *link = [NSString stringWithFormat:@"http://1100163.sinaapp.com/open/?p=%li",self.theSight.sightID.integerValue];
        DownLoadManager *downLoadXML = [[DownLoadManager alloc]init];
        [downLoadXML downloadXML:link withData:^(NSData *data) {
            [self ParseXML:data];
        }];
    }
}



- (void)ParseXML:(NSData *)data {
    RXMLElement *sight = [RXMLElement elementFromHTMLData:data];
    [sight iterateWithRootXPath:@"//description" usingBlock:^(RXMLElement *sight) {
        [[DataBaseManager defaultManager]updateSight:self.theSight];//添加数据库
        //在webView中加载THMLString
        [self.webView loadHTMLString:sight.text baseURL:nil];
    }];
}
- (IBAction)go2MapViewController:(UIBarButtonItem *)sender {
    MapViewController *mapVC = [[MapViewController alloc] init];
    mapVC.theSight = self.theSight;
    [self.navigationController pushViewController:mapVC animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
