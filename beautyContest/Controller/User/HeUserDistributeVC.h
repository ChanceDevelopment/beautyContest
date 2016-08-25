//
//  HeUserDistributeVC.h
//  beautyContest
//
//  Created by Tony on 16/8/25.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeUserDistributeVC : HeBaseViewController<EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@property(strong,nonatomic)NSDictionary *contestDict;

@end
