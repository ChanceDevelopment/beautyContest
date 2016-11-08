/************************************************************
  *  * EaseMob CONFIDENTIAL 
  * __________________ 
  * Copyright (C) 2013-2014 EaseMob Technologies. All rights reserved. 
  *  
  * NOTICE: All information contained herein is, and remains 
  * the property of EaseMob Technologies.
  * Dissemination of this information or reproduction of this material 
  * is strictly forbidden unless prior written permission is obtained
  * from EaseMob Technologies.
  */

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "LocationViewController.h"
#import "UIButton+Bootstrap.h"
#import "UIViewController+HUD.h"

static LocationViewController *defaultLocation = nil;

@interface LocationViewController () <MKMapViewDelegate>
{
    MKMapView *_mapView;
    MKPointAnnotation *_annotation;
    
    CLLocationCoordinate2D _currentLocationCoordinate;
    NSString *_addressString;
    BOOL _isSendLocation;
}

@property (strong, nonatomic) NSString *addressString;

@end

@implementation LocationViewController
@synthesize addressString = _addressString;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _isSendLocation = YES;
    }
    return self;
}

- (instancetype)initWithLocation:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _isSendLocation = NO;
        _currentLocationCoordinate = locationCoordinate;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    NSString *versionStirng = [[UIDevice currentDevice] systemVersion];
    
    if([versionStirng compare:@"7.9" options:NSNumericSearch] == NSOrderedDescending){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestAlwaysAuthorization];
        [locationManager startUpdatingLocation];
    }
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    label.text = @"位置信息";
    [label sizeToFit];
    
    UIButton *backBT = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBT setBackgroundImage:[UIImage imageNamed:@"btn_backItem"] forState:UIControlStateNormal];
    [backBT setBackgroundImage:[UIImage imageNamed:@"btn_backItemHL"] forState:UIControlStateHighlighted];
    [backBT addTarget:self action:@selector(backTolastView:) forControlEvents:UIControlEventTouchUpInside];
    backBT.tag = 1;
    backBT.frame = CGRectMake(0, 0, 25, 25);
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithCustomView:backBT];
    [leftBarItem setAction:@selector(backTolastView:)];
    self.navigationItem.leftBarButtonItem = leftBarItem;

    
    _mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
    _mapView.delegate = self;
    _mapView.showsUserLocation = YES;//显示当前位置
    _mapView.mapType = MKMapTypeStandard;
    _mapView.zoomEnabled = YES;
    [self.view addSubview:_mapView];
    
    if (_isSendLocation) {
        
        _mapView.showsUserLocation = YES;//显示当前位置
//        UIButton *distributebutton = [[UIButton alloc] init];
//        [distributebutton infoStyleWhite];
//        [distributebutton setTitle:@"发送" forState:UIControlStateNormal];
//        [distributebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        distributebutton.layer.borderColor = [[UIColor whiteColor] CGColor];
//        [distributebutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        distributebutton.frame = CGRectMake(self.navigationController.navigationBar.frame.size.height - 10, (self.navigationController.navigationBar.frame.size.height - 30)/2, 50, 25);
//        [distributebutton addTarget:self action:@selector(sendLocation) forControlEvents:UIControlEventTouchUpInside];
//        UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributebutton];
//        distributeItem.target = self;
//        distributeItem.action = @selector(sendLocation);
//        self.navigationItem.rightBarButtonItem = distributeItem;
        
        UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(sendLocation)];
        distributeItem.tintColor = [UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = distributeItem;
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
    
        [self startLocation];
    }
    else{
        [self removeToLocation:_currentLocationCoordinate];
    }
}

-(void)backTolastView:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - class methods

+ (instancetype)defaultLocation
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultLocation = [[LocationViewController alloc] initWithNibName:nil bundle:nil];
    });
    
    return defaultLocation;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    __weak typeof(self) weakSelf = self;
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:userLocation.location completionHandler:^(NSArray *array, NSError *error) {
        if (!error && array.count > 0) {
            CLPlacemark *placemark = [array objectAtIndex:0];
            weakSelf.addressString = placemark.name;
            
            [self removeToLocation:userLocation.coordinate];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [self showHint:@"定位失败"];
}

#pragma mark - public

- (void)startLocation
{
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [self showHudInView:self.view hint:@"正在定位..."];
}

-(void)createAnnotationWithCoords:(CLLocationCoordinate2D)coords
{
    if (_annotation == nil) {
        _annotation = [[MKPointAnnotation alloc] init];
    }
    else{
        [_mapView removeAnnotation:_annotation];
    }
    _annotation.coordinate = coords;
    [_mapView addAnnotation:_annotation];
}

- (void)removeToLocation:(CLLocationCoordinate2D)locationCoordinate
{
    [self hideHud];
    
    _currentLocationCoordinate = locationCoordinate;
    float zoomLevel = 0.01;
    MKCoordinateRegion region = MKCoordinateRegionMake(_currentLocationCoordinate, MKCoordinateSpanMake(zoomLevel, zoomLevel));
    [_mapView setRegion:[_mapView regionThatFits:region] animated:YES];
    
    if (_isSendLocation) {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
    
    [self createAnnotationWithCoords:_currentLocationCoordinate];
}

- (void)sendLocation
{
    if (_delegate && [_delegate respondsToSelector:@selector(sendLocationLatitude:longitude:andAddress:)]) {
        [_delegate sendLocationLatitude:_currentLocationCoordinate.latitude longitude:_currentLocationCoordinate.longitude andAddress:_addressString];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
