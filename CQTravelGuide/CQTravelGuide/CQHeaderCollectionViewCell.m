//
//  CQHeaderCollectionViewCell.m
//  CQTravelGuide
//
//  Created by chairman on 16/4/27.
//  Copyright © 2016年 LaiYong. All rights reserved.
//

#import "CQHeaderCollectionViewCell.h"
#import "Sight.h"
@interface CQHeaderCollectionViewCell()
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end
@implementation CQHeaderCollectionViewCell
- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGFloat height = 30;
        CGFloat y = (self.bounds.size.height-height)/2;
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, y, self.bounds.size.width, height)];;
        _titleLabel.font = [UIFont systemFontOfSize:17];
        _titleLabel.textColor = [UIColor redColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.layer.cornerRadius = self.bounds.size.height/2;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.imageView addSubview:self.titleLabel];
        [self.contentView addSubview:self.imageView];
    }
    return self;
}

- (void)setSight:(Sight *)sight {
    _sight = sight;
    self.imageView.image = [UIImage imageWithData:_sight.sightImageData];
    self.titleLabel.text = _sight.sightName;
}

- (void)deviceShared {
    CABasicAnimation *shareAnimation = [CABasicAnimation animation];
    shareAnimation.keyPath = @"transform.rotation.z";
    shareAnimation.fromValue = @(-M_PI/20);
    shareAnimation.toValue = @(M_PI/20);
    shareAnimation.duration = 0.1;
    //* 每次动画后倒回回放 */
    shareAnimation.autoreverses = YES;
    //* 重复次数 */
    shareAnimation.repeatCount = 4;
    //* 拿到可见cell里的imageView */
    for (CQHeaderCollectionViewCell *cell in self.visibleCells) {
        [cell.imageView.layer addAnimation:shareAnimation forKey:@"deviceShare"];
    }
}

@end
