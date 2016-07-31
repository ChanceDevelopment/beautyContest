//
//  HeBeautyZoneVC.h
//  beautyContest
//
//  Created by HeDongMing on 16/7/30.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeBeautyZoneVC : HeBaseViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@end
