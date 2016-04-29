//
//  DownLoadManager.m
//  CQTravelGuide
//
//  Created by chairman on 15/11/16.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "DownLoadManager.h"

@implementation DownLoadManager
/**
 *dataHandler 相当于一个函数名 返回值类型是void 这个函数的参数是NSData类型的参数  参数名是data
 */
- (void)downloadXML:(NSString *)link withData:(void (^)(NSData *data))dataHandler {
    NSURL *url = [NSURL URLWithString:link];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (connectionError) {
            NSLog(@"链接错误:%@",connectionError);
        }
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (code!=200) {
            NSLog(@"响应错误代码:%li",code);
        }
        dataHandler(data);//block里面的参数不是本身block的参数  而是需要传值的参数
    }];
}
@end
