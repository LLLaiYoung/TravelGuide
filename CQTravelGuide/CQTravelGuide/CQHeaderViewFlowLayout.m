//
//  CQHeaderViewFlowLayout.m
//  CQTravelGuide
//
//  Created by chairman on 16/4/27.
//  Copyright © 2016年 LaiYong. All rights reserved.
//

#import "CQHeaderViewFlowLayout.h"
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
@implementation CQHeaderViewFlowLayout
- (instancetype)init
{
    self = [super init];
    if (self) {
        CGFloat Spacing = 20;
        CGFloat width = (SCREEN_WIDTH-20*3)/2;
        NSLog(@"width = %f",width);
        self.itemSize = CGSizeMake(130, 130);
        //* 行 */
        self.minimumInteritemSpacing = Spacing;
        //* 列 */
        self.minimumLineSpacing = 10;
        
        self.sectionInset = UIEdgeInsetsMake(10, Spacing, 10, 10);
    }
    return self;
}
@end
