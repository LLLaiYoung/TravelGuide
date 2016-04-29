//
//  CQHeaderCollectionViewCell.h
//  CQTravelGuide
//
//  Created by chairman on 16/4/27.
//  Copyright © 2016年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Sight;
@interface CQHeaderCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) Sight *sight;
//* 可见cell 做动画 */
@property (nonatomic, strong) NSArray *visibleCells;
//* 摇晃手机 0.4s */
- (void)deviceShared;
@end
