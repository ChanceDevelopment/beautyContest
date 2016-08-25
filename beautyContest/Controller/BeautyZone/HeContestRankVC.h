//
//  HeContestRankVC.h
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "EGORefreshTableFootView.h"
#import "EGORefreshTableHeaderView.h"

@interface HeContestRankVC : HeBaseViewController<EGORefreshTableFootDelegate,EGORefreshTableHeaderDelegate,UITableViewDelegate,UITableViewDataSource>
{
    int updateOption;  //1:上拉刷新   2:下拉加载
    BOOL _reloading;
}

@property(strong,nonatomic)NSDictionary *contestDict;
@property(strong,nonatomic)NSMutableArray *topManRank; //排名前面的男神
@property(strong,nonatomic)NSMutableArray *topWomanRank; //排名前面的女神

@end
