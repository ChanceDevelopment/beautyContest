//
//  HeUserJoinVC.h
//  beautyContest
//
//  Created by HeDongMing on 16/8/24.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeUserJoinVC : HeBaseViewController<UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate,EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate,UISearchBarDelegate>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@end
