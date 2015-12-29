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

@interface SightDetailViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) Sight *theSight;
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

//- (void)downLoadXML:(NSString *)link {
//    NSURL *url = [NSURL URLWithString:link];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
//        if (connectionError) {
//            NSLog(@"sightDetailViewController连接错误==%@",connectionError);
//        }
//        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
//        if (code!=200) {
//            NSLog(@"sightDetailViewController响应错误!错误代码：%li",code);
//        }
//        [self ParseXML:data];
//    }];
//}


- (void)ParseXML:(NSData *)data {
    RXMLElement *sight = [RXMLElement elementFromHTMLData:data];
    [sight iterateWithRootXPath:@"//description" usingBlock:^(RXMLElement *sight) {
        [[DataBaseManager defaultManager]updateSight:self.theSight];//添加数据库
        //在webView中加载THMLString
        [self.webView loadHTMLString:sight.text baseURL:nil];
    }];
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
