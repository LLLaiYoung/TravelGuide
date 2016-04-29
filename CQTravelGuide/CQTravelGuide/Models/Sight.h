//
//  CQTypeTravelDetail.h
//  CQTravelGuide
//
//  Created by chairman on 15/11/11.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@interface Sight <MKAnnotation>: NSObject
@property (strong, nonatomic) NSNumber * _Nonnull sightID;///<景点ID
@property (strong, nonatomic) NSNumber * _Nonnull sightTypeID;///<景点类型ID
@property (copy, nonatomic) NSString * _Nonnull sightName;///<景点名称
@property (copy, nonatomic) NSString * _Nonnull sightBrief;///<景点摘要
@property (copy, nonatomic) NSString * _Nonnull sightImageLink;///<景点图片链接
@property (copy, nonatomic) NSString *  _Nonnull sightCoordinate;///<景点坐标
@property (copy, nonatomic) NSString * _Nonnull sightHTMLString;///<景点Html链接
@property (nonatomic, strong) NSData * _Nonnull sightImageData;///<图片数据
@property (nonatomic, strong) NSDate * _Nonnull date;///<最后存档时间


@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly, copy, nullable) NSString *title;
@property (nonatomic, readonly, copy, nullable) NSString *subtitle;


- (void)setImageForImageView:( UIImageView * _Nonnull )imageView;

@end
