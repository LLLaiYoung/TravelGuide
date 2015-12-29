//
//  DataBaseManager.h
//  CQTravelGuide
//
//  Created by chairman on 15/12/7.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SightType.h"
#import "Sight.h"

@interface DataBaseManager : NSObject
/**
 *  对于一个单例类，不论实例化对象多少次，都只有一个对象实例，而且这个实例一定是一个全局的能被整个系统访问到。
 */
+(instancetype)defaultManager;///<单例

//类型接口 速度较快  但是较麻烦
- (NSUInteger)numberOfCQType;///<返回对象总数
- (BOOL)insertIntoCQTypeAtIndex:(SightType *)sightType;///<插入数据
- (SightType *)cqTypeAtIndex:(NSUInteger)index;///<查询数据
- (NSDate *)lastArchiveDate;///<获取最后存档时间
- (void)deleteAllSightType;


//景点接口  速度较慢 较方便 （1000条数据下无压力）
-(void)saveSightList:(NSArray *)sightList withSightType:(SightType *)theSightType;
-(NSMutableArray *)readSightListByType:(SightType *)theType;
-(void)updateSight:(Sight *)aSight;
@end
