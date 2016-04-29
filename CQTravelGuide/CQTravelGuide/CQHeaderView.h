//
//  CQHeaderView.h
//  CQTravelGuide
//
//  Created by chairman on 16/4/27.
//  Copyright © 2016年 LaiYong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HeaderViewPushDelegate <NSObject>
@required
- (void)pushWithViewController:(UIViewController *)viewController;
@optional

@end

@interface CQHeaderView : UIView
@property (nonatomic, weak) id<HeaderViewPushDelegate> headerViewPushDelegate;
@property (nonatomic, strong) NSArray *dataSource;
- (void)reloadCollectionData;///<控制器调用 刷新数据
@end
