//
//  HeUserLocatiVC.h
//  beautyContest
//
//  Created by Danertu on 16/10/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>

@interface HeUserLocatiVC : HeBaseViewController<BMKMapViewDelegate,BMKLocationServiceDelegate>
{
    IBOutlet BMKMapView* _mapView;
    BMKLocationService* _locService;
}
@property(strong,nonatomic)NSDictionary *userLocationDict;

@end
