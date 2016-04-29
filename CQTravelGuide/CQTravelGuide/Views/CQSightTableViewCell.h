//
//  CQSightTableViewCell.h
//  CQTravelGuide
//
//  Created by chairman on 15/12/17.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Sight.h"
@interface CQSightTableViewCell : UITableViewCell
@property (nonatomic, strong) Sight *theSight;
@property (nonatomic, weak) id targer;
@property (nonatomic, assign) SEL selector;
@end
