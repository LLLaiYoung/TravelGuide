//
//  CQHeaderView.m
//  CQTravelGuide
//
//  Created by chairman on 16/4/27.
//  Copyright © 2016年 LaiYong. All rights reserved.
//

#import "CQHeaderView.h"
#import "CQHeaderViewFlowLayout.h"
#import "CQHeaderCollectionViewCell.h"
#import "SightDetailViewController.h"

static NSString *cellIdentifier = @"headerCell";

@interface CQHeaderView()
<
UICollectionViewDataSource,
UICollectionViewDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) CQHeaderCollectionViewCell *headerCell;
@end

@implementation CQHeaderView
#pragma mark - view init
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:[[CQHeaderViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self.collectionView registerClass:[CQHeaderCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
        self.headerCell = [CQHeaderCollectionViewCell new];
    }
    return self;
}

- (void)reloadCollectionData {
    NSArray *visible = [self.collectionView visibleCells];
    self.headerCell.visibleCells = visible;
    [self.headerCell deviceShared];
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.collectionView reloadData];
    });
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.dataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CQHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.sight = self.dataSource[indexPath.row];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SightDetailViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"webSight"];
    detailVC.theSight = self.dataSource[indexPath.row];
    if ([self.headerViewPushDelegate respondsToSelector:@selector(pushWithViewController:)]) {
        [self.headerViewPushDelegate pushWithViewController:detailVC];
    }
}


@end
