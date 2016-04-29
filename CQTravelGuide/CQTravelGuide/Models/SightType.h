//
//  CQType.h
//  CQTravelGuide
//
//  Created by chairman on 15/11/11.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SightType : NSObject

@property (strong, nonatomic) NSNumber *typeID;///<景点类型id
@property (copy, nonatomic) NSString *typeName;///<景点类型名称
@property (nonatomic, strong) NSDate *date;///<最后存档时间
@end
