//
//  CQSightTableViewCell.m
//  CQTravelGuide
//
//  Created by chairman on 15/12/17.
//  Copyright © 2015年 LaiYong. All rights reserved.
//

#import "CQSightTableViewCell.h"
#import "DataBaseManager.h"

@interface CQSightTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextView *breifTextView;

@end
@implementation CQSightTableViewCell


- (void)setTheSight:(Sight *)theSight {
    if (_theSight!=theSight) {
        _theSight = theSight;
        if (!_theSight) {
            return;
        }
        
        //手势
        self.headImageView.userInteractionEnabled = YES;
        //Cell重用会导致一个UIImageView添加多个手势.
        if (self.headImageView.gestureRecognizers.count==0) {//当imageView没有手势的时候就添加手势
            UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self.targer action:self.selector];
            [self.headImageView addGestureRecognizer:tapGR];
        }
        //设置圆角
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height/2;
        self.headImageView.layer.masksToBounds = YES;
        //* 代码重构 */
        [_theSight setImageForImageView:self.headImageView];
        self.titleLabel.text = _theSight.sightName;
        self.breifTextView.editable = NO;
        self.breifTextView.text = _theSight.sightBrief;
    }
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
