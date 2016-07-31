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

@interface HeTabBarVC : RDVTabBarController<UIAlertViewDelegate>
@property(strong,nonatomic)HeUserVC *userVC;
@property(strong,nonatomic)HeBeautyZoneVC *beautyZoneVC;
@property(strong,nonatomic)HeRecommendVC *recommendVC;
@property(strong,nonatomic)HeDiscoverVC *discoverVC;

@end
