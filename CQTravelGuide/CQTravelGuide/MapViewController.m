//
//  MapViewController.m
//  CQTravelGuide
//
//  Created by chairman on 16/4/8.
//  Copyright © 2016年 LaiYong. All rights reserved.
//
//define this constant if you want to use Masonry without the 'mas_' prefix
#define MAS_SHORTHAND

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS

#import "MapViewController.h"
#import "Masonry.h"
#import <MapKit/MapKit.h>
#import "Sight.h"
#import "DataBaseManager.h"
#import "SightDetailViewController.h"
@interface MapViewController ()
<
MKMapViewDelegate
>
@property (nonatomic, strong) MKMapView *mapView;
@end

@implementation MapViewController
- (MKMapView *)mapView {
    if (!_mapView) {
        _mapView = [[MKMapView alloc] init];
        _mapView.delegate = self;
        [self.view addSubview:_mapView];
    }
    return _mapView;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.mapView makeConstraints:^(MASConstraintMaker *make) {
        make.topMargin.equalTo(CGRectGetMaxY(self.navigationController.navigationBar.frame));
        make.left.bottom.and.right.equalTo(self.view);
    }];
    self.mapView.showsUserLocation = YES;
    self.mapView.showsScale = YES;
    self.mapView.showsTraffic = YES;
    if (self.theSight) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.theSight.coordinate, 1000, 1000);
        [self.mapView setRegion:region];
        [self.mapView addAnnotation:(id)self.theSight];
    }
    if (self.sights.count!=0) {
        [self.mapView setRegion:[self reginThatContainsAnnotions:self.sights] animated:YES];
        [self.mapView addAnnotations:self.sights];
    }

}
/**
 *  多个对象显示在屏幕中
 *
 *  @param annotions 需要计算frame的数组对象,需要遵循<MKAnnotation>
 *
 *  @return 计算后的中心点
 */
- (MKCoordinateRegion)reginThatContainsAnnotions:(NSArray *)annotions {
    if (annotions.count==0) {
        MKCoordinateRegion regin;
        return regin;
    }
    double maxLatitude,minLatitude,maxlongitude,minLongitude;
    //* 将数组的第一个元素,设置为 maxLatitude,minLatitude,maxlongitude,minLongitude */
    id <MKAnnotation>theSight = annotions[0];
    maxLatitude = theSight.coordinate.latitude;
    maxlongitude = theSight.coordinate.longitude;
    minLatitude = theSight.coordinate.latitude;
    minLongitude = theSight.coordinate.longitude;
    //* for in 遍历 出最大的 maxLatitude,minLatitude,maxlongitude,minLongitude */
    for (theSight in annotions) {
        if (maxlongitude < theSight.coordinate.longitude) {
            maxlongitude = theSight.coordinate.longitude;
            NSLog(@"maxlongitude=%f",maxlongitude);
        }
        if (maxLatitude < theSight.coordinate.latitude) {
            maxLatitude = theSight.coordinate.latitude;
            NSLog(@"maxLatitude = %f",maxLatitude);
        }
        if (minLongitude > theSight.coordinate.longitude) {
            minLongitude = theSight.coordinate.longitude;
            NSLog(@"minLongitude = %f",minLongitude);
        }
        if (minLatitude > theSight.coordinate.latitude) {
            minLatitude = theSight.coordinate.latitude;
            NSLog(@"minLatitude = %f",minLatitude);
        }
    }
    //* 计算 中心点 */
    CLLocationCoordinate2D center;
    center.latitude = (minLatitude + maxLatitude)/2;
    center.longitude = (maxlongitude + minLongitude)/2;
    //* span 跨度 */
    double deltLatitude = maxLatitude - minLatitude;
    double deltLongtitude = maxlongitude - minLongitude;
    //* 相对值 不然会显示不完全 */
    deltLatitude *= 1.2;
    deltLongtitude *= 1.2;
    MKCoordinateRegion region = MKCoordinateRegionMake(center, MKCoordinateSpanMake(deltLatitude, deltLongtitude));
    return region;
}
#pragma mark - MKMapViewDelegate 自定义大头针
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    //* 跟tableViewCell的重用机制是一样的 */
    static NSString *annotationId = @"annotation";
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:annotationId];
    if (!annotationView) {//* 写在括号里面的是不变的 */
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:annotationId];
        //* 自定义大头针的image */
        annotationView.image = [UIImage imageNamed:@"Pin-black"];
        annotationView.canShowCallout = YES;
        //* 设置中心点偏移量 */
        annotationView.centerOffset = CGPointMake(-14, -16);
        //* 弹出框的偏移量 */
        annotationView.calloutOffset = CGPointMake(-7, 0);
        //* 添加辅助视图 */
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        annotationView.leftCalloutAccessoryView = imageView;
        if (self.sights.count!=0) {//是单个对象就不现实rightCalloutAccessoryView
            UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
            annotationView.rightCalloutAccessoryView = button;
        }
    }
    UIImageView *imageView = (UIImageView *)annotationView.leftCalloutAccessoryView;
    //* 因为Sight遵循了<MKAnnotation>协议,所以Sight *theSight = annotation; */
    Sight *theSight = annotation;
    [theSight setImageForImageView:imageView];
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    if (control==view.rightCalloutAccessoryView) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SightDetailViewController *sightDetailVC = [storyboard instantiateViewControllerWithIdentifier:@"webSight"];
        [sightDetailVC setValue:view.annotation forKey:@"theSight"];
        [self.navigationController pushViewController:sightDetailVC animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}

@end
