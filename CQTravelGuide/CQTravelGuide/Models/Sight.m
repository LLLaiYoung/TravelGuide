//
//  CQTypeTravelDetail.m
//  CQTravelGuide
//
//  Created by chairman on 15/11/11.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "Sight.h"
#import "DataBaseManager.h"

@implementation Sight
//* 在模型层遵守<MKAnnotation>协议 重写相应的setter函数对 coordinate title subtitle 进行赋值 isEqualToString 判断的是内容,而!=是说的内存地址 重写相应的setter函数需要重新对属性使用修饰词进行修饰 */


- (void)setSightCoordinate:(NSString *)sightCoordinate {
    if (![_sightCoordinate isEqualToString:sightCoordinate]) {
#warning copy
        _sightCoordinate = [sightCoordinate copy];
        NSArray *sightCoordinates = [sightCoordinate componentsSeparatedByString:@","];
        CGFloat latitude = [sightCoordinates.firstObject doubleValue];
        CGFloat longitude = [sightCoordinates.lastObject doubleValue];
        _coordinate.latitude = latitude;
        _coordinate.longitude = longitude;
    }
}

- (void)setSightName:(NSString *)sightName {
    _sightName = [sightName copy];
    _title =sightName;
}

- (void)setSightBrief:(NSString *)sightBrief {
    _sightBrief = [sightBrief copy];
    NSString *subTitle = [NSString stringWithFormat:@"%@...",[sightBrief substringToIndex:9]];
    _subtitle = subTitle;
}


- (void)setImageForImageView:( UIImageView * _Nonnull )imageView {
    if (!imageView) {
        return;
    }
    if (self.sightImageData) {//当sightImageData有值的时候
        imageView.image = [UIImage imageWithData:self.sightImageData];
    } else {
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.sightImageLink]];
        
        [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (connectionError) {
                NSLog(@"链接错误:%@",connectionError);
            }
            NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
            if (code!=200) {
                NSLog(@"响应错误代码:%li",code);
            }
            
            self.sightImageData = data;
            [[DataBaseManager defaultManager]updateSight:self];
            imageView.image = [UIImage imageWithData:data];
        }];
    }

}

@end
