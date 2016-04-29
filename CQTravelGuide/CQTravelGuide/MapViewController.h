//
//  MapViewController.h
//  CQTravelGuide
//
//  Created by chairman on 16/4/8.
//  Copyright © 2016年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sight.h"
@interface MapViewController : UIViewController
@property (nonatomic, strong) Sight *theSight;
@property (nonatomic, strong) NSArray *sights;
@end
