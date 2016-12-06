//
//  HeDistributeContestVC.h
//  beautyContest
//
//  Created by HeDongMing on 16/8/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "DeleteImageProtocol.h"

@interface HeDistributeContestVC : HeBaseViewController<DeleteImageProtocol,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIAlertViewDelegate>
@property(strong,nonatomic)NSString *zonePassword;
@property(assign,nonatomic)BOOL isFaceContest;

@end
