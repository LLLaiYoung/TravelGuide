//
//  CQType.h
//  CQTravelGuide
//
//  Created by chairman on 15/11/11.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SightType : NSObject

@property (strong, nonatomic) NSNumber *typeID;
@property (copy, nonatomic) NSString *typeName;
@property (nonatomic, strong) NSDate *date;
@end
