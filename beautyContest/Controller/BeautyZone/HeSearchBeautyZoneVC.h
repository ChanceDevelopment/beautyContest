//
//  HeSearchBeautyZoneVC.h
//  beautyContest
//
//  Created by Danertu on 16/10/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeSearchBeautyZoneVC : HeBaseViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate,UISearchBarDelegate>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@end
