//
//  HeTabBarVC.h
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeBaseViewController.h"
#import "RDVTabBarController.h"
#import "HeBeautyZoneVC.h"
#import "HeRecommendVC.h"
#import "HeDiscoverVC.h"
#import "HeUserVC.h"
#import "HeNewRecommendVC.h"
#import <CoreLocation/CoreLocation.h>

@interface HeTabBarVC : RDVTabBarController<UIAlertViewDelegate,CLLocationManagerDelegate>
@property(strong,nonatomic)HeUserVC *userVC;
@property(strong,nonatomic)HeBeautyZoneVC *beautyZoneVC;
@property(strong,nonatomic)HeNewRecommendVC *recommendVC;
@property(strong,nonatomic)HeDiscoverVC *discoverVC;

@end
