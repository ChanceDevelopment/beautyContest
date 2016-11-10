//
//  HeRecommendMessageVC.h
//  beautyContest
//
//  Created by Danertu on 2016/11/10.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeRecommendMessageVC : HeBaseViewController<EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@property(strong,nonatomic)NSString *userId;

@end
