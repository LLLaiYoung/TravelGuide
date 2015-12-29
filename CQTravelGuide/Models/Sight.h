//
//  CQTypeTravelDetail.h
//  CQTravelGuide
//
//  Created by chairman on 15/11/11.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Sight : NSObject
@property (strong, nonatomic) NSNumber *sightID;///<景点ID
@property (strong, nonatomic) NSNumber *sightTypeID;///<景点类型ID
@property (copy, nonatomic) NSString *sightName;///<景点名称
@property (copy, nonatomic) NSString *sightBrief;///<景点摘要
@property (copy, nonatomic) NSString *sightImageLink;///<景点图片链接
@property (copy, nonatomic) NSString * sightCoordinate;///<景点坐标
@property (copy, nonatomic) NSString *sightHTMLString;///<景点Html链接
@property (nonatomic, strong) NSData *sightImageData;///<图片数据
@property (nonatomic, strong) NSDate *date;///<最后存档时间
@end
