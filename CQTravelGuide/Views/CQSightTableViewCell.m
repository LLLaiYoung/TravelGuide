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
        self.headImageView.layer.cornerRadius = self.headImageView.frame.size.height/2;
        self.headImageView.layer.masksToBounds = YES;
        if (_theSight.sightImageData) {//当sightImageData有值的时候
            self.headImageView.image = [UIImage imageWithData:_theSight.sightImageData];
        } else {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_theSight.sightImageLink]];
            
            [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                if (connectionError) {
                    NSLog(@"链接错误:%@",connectionError);
                }
                NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
                if (code!=200) {
                    NSLog(@"响应错误代码:%li",code);
                }
                
                _theSight.sightImageData = data;
                [[DataBaseManager defaultManager]updateSight:_theSight];
                self.headImageView.image = [UIImage imageWithData:data];
            }];
        }
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
