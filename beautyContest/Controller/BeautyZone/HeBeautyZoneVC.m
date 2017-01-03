//
//  HeWorkingTaskVC.m
//  huayoutong
//
//  Created by Tony on 16/7/27.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeBeautyZoneVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestDetailVC.h"
#import "HeBeautyContestTableCell.h"
#import "DropDownListView.h"
#import "HeDistributeContestVC.h"
#import "FTPopOverMenu.h"
#import "HeFaceToFaceZoneVC.h"
#import "HeZoneConfirmVC.h"
#import "HeSearchBeautyZoneVC.h"
#import "HeNewUserInfoVC.h"

#define TextLineHeight 1.2f
#define MinLocationSucceedNum 1   //要求最少成功定位的次数

@interface HeBeautyZoneVC ()<UITableViewDelegate,UITableViewDataSource,DropDownChooseDataSource,DropDownChooseDelegate,BMKLocationServiceDelegate>
{
    BOOL requestReply; //是否已经完成
    NSInteger orderType; //排序类型
    BMKLocationService *_locService;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;
@property(strong,nonatomic)NSMutableArray *chooseArray;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSCache *imageCache;

@property(assign,nonatomic)NSInteger locationSucceedNum;

@property(strong,nonatomic)NSDictionary *userLocationDict;

@end

@implementation HeBeautyZoneVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize chooseArray;
@synthesize searchBar;
@synthesize imageCache;
@synthesize locationSucceedNum;
@synthesize userLocationDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"赛区";
        [label sizeToFit];
        
        self.title = @"赛区";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    //加载比赛
    [self loadBeautyContestShow:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _locService.delegate = self;
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    _locService.delegate = nil;
}

- (void)initializaiton
{
    [super initializaiton];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUserSucceed:) name:@"blockUserSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delTemporary:) name:@"delTemporaryNotification" object:nil];
    imageCache = [[NSCache alloc] init];
    requestReply = NO;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNo = 0;
    updateOption = 1;
    
    orderType = 0;
    
    chooseArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //距离数据
    NSArray *distanceArray = @[@"所有"];
    //地点数据
    NSArray *hotArray = @[@"所有"];
    //时间数据
    NSArray *timeArray = @[@"所有"];
    
    chooseArray = [NSMutableArray arrayWithArray:@[distanceArray,hotArray,timeArray]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContestZone:) name:@"updateContestZone" object:nil];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    //启动LocationService
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter  = 1.5f;
    [_locService startUserLocationService];
    
    
    locationSucceedNum = 0;
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    [self pullUpUpdate];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
    NSArray *defaultArray = @[@"赏金",@"热度",@"距离"];
    DropDownListView *timedropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(0,0, SCREENWIDTH, sectionHeaderView.frame.size.height) dataSource:self delegate:self defaultTitleArray:defaultArray];
    if (!ISIOS7) {
        timedropDownView.frame = CGRectMake(0,0, SCREENWIDTH, sectionHeaderView.frame.size.height);
    }
    timedropDownView.tag = 1;
    timedropDownView.mSuperView = self.view;
    
    [sectionHeaderView addSubview:timedropDownView];
    
    CGFloat searchX = 30;
    CGFloat searchY = 7;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = 30;
    
    UIView *searchView = [[UIView alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchView.backgroundColor = APPDEFAULTORANGE;
    searchView.layer.masksToBounds = YES;
    searchView.layer.cornerRadius = searchH / 2.0;
    searchView.layer.borderWidth = 0.5;
    searchView.layer.borderColor = [UIColor whiteColor].CGColor;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:searchView.bounds];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"        关键词搜索";
    titleLabel.font = [UIFont systemFontOfSize:13.5];
    [searchView addSubview:titleLabel];
    self.navigationItem.titleView = searchView;
    
    UIImageView *searchIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_search"]];
    searchIcon.frame = CGRectMake(5, (searchH - 20) / 2.0, 18, 20);
    [titleLabel addSubview:searchIcon];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchMethod:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [searchView addGestureRecognizer:tap];
    
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    //    searchBar.tintColor = [UIColor colo]
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"请输入关键字";
//    self.navigationItem.titleView = searchBar;
    
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(distributeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    distributeItem.target = self;
    self.navigationItem.rightBarButtonItem = distributeItem;
}

- (void)updateUserPositionWithPosition:(NSDictionary *)positionDict userId:(NSString *)userId
{
    NSString *longitude = positionDict[@"longitude"];
    NSString *latitude = positionDict[@"latitude"];
    NSDictionary *params = @{@"userId":userId,@"latitude":latitude,@"longitude":longitude};
    NSString *updateUserPositionUrl = [NSString stringWithFormat:@"%@/user/updateUserPosition.action",BASEURL];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:updateUserPositionUrl params:params  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
//            NSLog(@"update position succeed");
        }
        else{
            NSString *errorInfo = respondDict[@"data"];
//            NSLog(@"update position faild, error info = %@",errorInfo);
        }
        
    } failure:^(NSError *error){
        NSLog(@"访问服务器出错");
    }];
}

//删除临时赛区
- (void)delTemporary:(NSNotification *)notification
{
    [[self rdv_tabBarController] setTabBarHidden:NO animated:YES];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSDictionary *params = @{@"userid":userid};
    NSString *requestRecommendDataPath = [NSString stringWithFormat:@"%@/zone/delTemporayByUserid.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            //            [self showHint:data];
        }
    } failure:^(NSError *error){
        NSLog(@"errorInfo = %@",error);
    }];
}

- (void)blockUserSucceed:(NSNotification *)notificaition
{
    NSDictionary *userInfo = notificaition.userInfo;
    NSString *userId = userInfo[@"userId"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *zoneDict in dataSource) {
        NSString *zoneUserId = zoneDict[@"userId"];
        if ([zoneUserId isMemberOfClass:[NSNull class]]) {
            zoneUserId = @"";
        }
        if (![zoneUserId isEqualToString:userId]) {
            [array addObject:zoneDict];
        }
    }
    dataSource = [[NSMutableArray alloc] initWithArray:array];
    [tableview reloadData];
}

- (void)searchMethod:(UITapGestureRecognizer *)tap
{
    HeSearchBeautyZoneVC *searchVC = [[HeSearchBeautyZoneVC alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
}
- (void)distributeButtonClick:(UIButton *)button
{
    NSLog(@"distributeButtonClick");
    NSArray *menuArray = @[@"发布赛区",@"面对面创建赛区",@"加入赛区验证"];
    [FTPopOverMenu setTintColor:APPDEFAULTORANGE];
    [FTPopOverMenu showForSender:button
                        withMenu:menuArray
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           switch (selectedIndex) {
                               case 0:
                               {
                                   //发布赛区
                                   HeDistributeContestVC *distributeContestVC = [[HeDistributeContestVC alloc] init];
                                   distributeContestVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:distributeContestVC animated:YES];
                                   break;
                               }
                               case 1:
                               {
                                   //面对面创建赛区
                                   HeFaceToFaceZoneVC *faceZoneVC = [[HeFaceToFaceZoneVC alloc] init];
                                   faceZoneVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:faceZoneVC animated:YES];
                                   break;
                               }
                               case 2:
                               {
                                   //加入赛区验证
                                   HeZoneConfirmVC *zoneConfirmVC = [[HeZoneConfirmVC alloc] init];
                                   zoneConfirmVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:zoneConfirmVC animated:YES];
                                   break;
                               }
                               default:
                                   break;
                           }
                           
                           
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
    
    
}

- (void)updateContestZone:(NSNotification *)notification
{
    updateOption = 1;
    pageNo = 0;
    [self loadBeautyContestShow:YES];
}
- (UIButton *)buttonWithTitle:(NSString *)buttonTitle frame:(CGRect)buttonFrame
{
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:143.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[UIImage imageNamed:@"filterButtonBG"] forState:UIControlStateSelected];
    [button setBackgroundImage:[Tool buttonImageFromColor:sectionHeaderView.backgroundColor withImageSize:button.frame.size] forState:UIControlStateNormal];
    
    return button;
}

- (void)filterButtonClick:(UIButton *)button
{
    if ((requestReply == NO && button.tag == 100) || (requestReply == YES && button.tag == 101)) {
        return;
    }
    NSArray *subViewsArray = sectionHeaderView.subviews;
    for (UIView *subview in subViewsArray) {
        if ([subview isKindOfClass:[UIButton class]]) {
            ((UIButton *)subview).selected = !((UIButton *)subview).selected;
        }
    }
    requestReply = YES;
    if (button.tag == 100) {
        requestReply = NO;
    }
    [self loadBeautyContestShow:YES];
}

- (void)loadBeautyContestShow:(BOOL)show
{
    NSString *requestWorkingTaskPath = @"";
    
    NSString *longitudeStr = [userLocationDict objectForKey:USERLONGITUDEKEY];
    NSString *latitudeStr = [userLocationDict objectForKey:USERLATITUDEKEY];
    
    NSNumber *longitudeNum = [NSNumber numberWithFloat:[longitudeStr floatValue]];
    NSNumber *latitudeNum = [NSNumber numberWithFloat:[latitudeStr floatValue]];
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"longitude":longitudeNum,@"latitude":latitudeNum,@"number":pageNum};
    switch (orderType) {
        case 0:
        {
            //赏金
            requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/zoneRankByZoneReward.action",BASEURL];
            requestMessageParams = @{@"start":pageNum};
            break;
        }
        case 1:
        {
            requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/ZoneHotRank.action",BASEURL];
            requestMessageParams = @{@"start":pageNum};
            break;
        }
        case 2:
        {
            requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/selectZoneByDistance.action",BASEURL];
            
            break;
        }
        default:
            break;
    }
    
    [self showHudInView:self.tableview hint:@"获取赛区中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        if (show) {
            [Waiting dismiss];
        }
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            if (updateOption == 1) {
                [dataSource removeAllObjects];
            }
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            NSString *blockKey = [NSString stringWithFormat:@"%@_%@",BLOCKINGLIST,myUserId];
            
            NSArray *blockArray = [[NSUserDefaults standardUserDefaults] objectForKey:blockKey];
            for (NSDictionary *zoneDict in resultArray) {
                BOOL isBlock = NO;
                for (NSDictionary *dict in blockArray) {
                    NSString *userId = dict[@"userId"];
                    NSString *zoneUserId = zoneDict[@"userId"];
                    if ([zoneUserId isMemberOfClass:[NSNull class]]) {
                        zoneUserId = @"";
                    }
                    if ([zoneUserId isEqualToString:userId]) {
                        isBlock = YES;
                        break;
                    }
                }
                if (!isBlock) {
                    [dataSource addObject:zoneDict];
                }
                
            }
            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            [self.tableview reloadData];
        }
        else{
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                resultArray = nil;
            }
            if (updateOption == 2 && [resultArray count] == 0) {
                pageNo--;
                return;
            }
        }
    } failure:^(NSError *error){
        if (show) {
            [Waiting dismiss];
        }
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)addFooterView
{
    if (tableview.contentSize.height >= SCREENHEIGH) {
        [self pullDownUpdate];
    }
}

-(void)pullUpUpdate
{
    self.refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - self.tableview.bounds.size.height, SCREENWIDTH, self.tableview.bounds.size.height)];
    refreshHeaderView.delegate = self;
    [tableview addSubview:refreshHeaderView];
    [refreshHeaderView refreshLastUpdatedDate];
}
-(void)pullDownUpdate
{
    if (refreshFooterView == nil) {
        self.refreshFooterView = [[EGORefreshTableFootView alloc] init];
    }
    refreshFooterView.frame = CGRectMake(0, tableview.contentSize.height, SCREENWIDTH, 650);
    refreshFooterView.delegate = self;
    [tableview addSubview:refreshFooterView];
    [refreshFooterView refreshLastUpdatedDate];
    
}

#pragma mark -- dropDownListDelegate
- (void)selectInSection:(NSInteger)section
{
    updateOption = 1;
    switch (section) {
        case 0:
        {
            orderType = 0;
            break;
        }
        case 1:{
            orderType = 1;
            break;
        }
        case 2:{
            orderType = 2;
            break;
        }
        default:
            break;
    };
    pageNo = 0;//选择以后相当于刷新
    [self loadBeautyContestShow:YES];
}

-(void) chooseAtSection:(NSInteger)section index:(NSInteger)index
{
    NSString *chooseStirng = [[chooseArray objectAtIndex:section] objectAtIndex:index];
    NSLog(@"chooseStirng = %@",chooseStirng);
    updateOption = 1;
    switch (section) {
        case 0:
        {
            orderType = 0;
            break;
        }
        case 1:{
            orderType = 1;
            break;
        }
        case 2:{
            orderType = 2;
            break;
        }
        default:
            break;
    };
    pageNo = 0;//选择以后相当于刷新
    [self loadBeautyContestShow:YES];
}

#pragma mark -- dropdownList DataSource
-(NSInteger)numberOfSections
{
    return [chooseArray count];
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section
{
    NSArray *arry =chooseArray[section];
    return [arry count];
}
-(NSString *)titleInSection:(NSInteger)section index:(NSInteger) index
{
    NSString *str = nil;
    @try {
        str = chooseArray[section][index];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    return str;
    
}
-(NSInteger)defaultShowSection:(NSInteger)section
{
    return 0;
}

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    //刷新列表
    [self loadBeautyContestShow:NO];
    [self updateDataSource];
}

-(void)updateDataSource
{
    [self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:1.0];//视图的数据下载完毕之后，开始刷新数据
}

- (void)doneLoadingTableViewData{
    
    //  model should call this when its done loading
    _reloading = NO;
    switch (updateOption) {
        case 1:
            [refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:tableview];
            break;
        case 2:
            [refreshFooterView egoRefreshScrollViewDataSourceDidFinishedLoading:tableview];
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //刚开始拖拽的时候触发下载数据
    [refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    [refreshFooterView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
    [refreshFooterView egoRefreshScrollViewDidEndDragging:scrollView];
}

/*******************Foot*********************/
#pragma mark -
#pragma mark EGORefreshTableFootDelegate Methods
- (void)egoRefreshTableFootDidTriggerRefresh:(EGORefreshTableFootView*)view
{
    updateOption = 2;//加载历史标志
    pageNo = [dataSource count];
    
    @try {
        
    }
    @catch (NSException *exception) {
        //抛出异常不应当处理dateline
    }
    @finally {
        [self reloadTableViewDataSource];//触发刷新，开始下载数据
    }
}
- (BOOL)egoRefreshTableFootDataSourceIsLoading:(EGORefreshTableFootView*)view{
    
    return _reloading; // should return if data source model is reloading
    
}
- (NSDate*)egoRefreshTableFootDataSourceLastUpdated:(EGORefreshTableFootView*)view{
    
    return [NSDate date]; // should return date data source was last changed
    
}

/*******************Header*********************/
#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods
- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
    updateOption = 1;//刷新加载标志
    pageNo = 0;
    @try {
    }
    @catch (NSException *exception) {
        //抛出异常不应当处理dateline
    }
    @finally {
        [self reloadTableViewDataSource];//触发刷新，开始下载数据
    }
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
    return _reloading; // should return if data source model is reloading
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
    return [NSDate date]; // should return date data source was last changed
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeBeautyContestTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *zoneDict = nil;
    @try {
        zoneDict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    HeBeautyContestTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBeautyContestTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    id zoneReward = [zoneDict objectForKey:@"zoneReward"];
    if ([zoneReward isMemberOfClass:[NSNull class]]) {
        zoneReward = @"";
    }
    id zoneTitle = [zoneDict objectForKey:@"zoneTitle"];
    if ([zoneTitle isMemberOfClass:[NSNull class]]) {
        zoneTitle = @"";
    }
    cell.topicLabel.text = zoneTitle;
    
    
    NSString *zoneCover = [zoneDict objectForKey:@"zoneCover"];
    if ([zoneCover isMemberOfClass:[NSNull class]]) {
        zoneCover = @"";
    }
    NSArray *zoneCoverArray = [zoneCover componentsSeparatedByString:@","];
    zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,[zoneCoverArray firstObject]];
    UIImageView *imageview = [imageCache objectForKey:zoneCover];
    if (!imageview) {
        [cell.bgImage sd_setImageWithURL:[NSURL URLWithString:zoneCover] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
        imageview = cell.bgImage;
    }
    cell.bgImage = imageview;
    [cell.bgView addSubview:cell.bgImage];
    
    
    NSString *userHear = [zoneDict objectForKey:@"userHeader"];
    if ([userHear isMemberOfClass:[NSNull class]]) {
        userHear = @"";
    }
    if (![userHear hasPrefix:@"http"]) {
        userHear = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHear];
    }
    
    UIImageView *userHearimageview = [imageCache objectForKey:userHear];
    if (!userHearimageview) {
        [cell.detailImage sd_setImageWithURL:[NSURL URLWithString:userHear] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userHearimageview = cell.detailImage;
    }
    cell.detailImage = userHearimageview;
    [cell.bgView addSubview:cell.detailImage];
    
    id zoneCreatetimeObj = [zoneDict objectForKey:@"zoneDeathline"];
    if ([zoneCreatetimeObj isMemberOfClass:[NSNull class]] || zoneCreatetimeObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        zoneCreatetimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long timestamp = [zoneCreatetimeObj longLongValue];
    NSString *zoneCreatetime = [NSString stringWithFormat:@"%lld",timestamp];
    if ([zoneCreatetime length] > 3) {
        //时间戳
        zoneCreatetime = [zoneCreatetime substringToIndex:[zoneCreatetime length] - 3];
    }
    
    NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"YYYY-MM-dd"];
    cell.tipLabel.text = [NSString stringWithFormat:@"$%.2f",[zoneReward floatValue]];
    cell.timeLabel.text = time;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeaderView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 250;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *zoneDict = nil;
    @try {
        zoneDict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    HeContestDetailVC *contestDetailVC = [[HeContestDetailVC alloc] init];
    contestDetailVC.contestBaseDict = [[NSDictionary alloc] initWithDictionary:zoneDict];
    contestDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contestDetailVC animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    return YES;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchbar
{
    if ([searchbar isFirstResponder]) {
        [searchbar resignFirstResponder];
    }
    NSString *searchKey = searchBar.text;
    NSLog(@"searchKey = %@",searchKey);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    
    //NSLog(@"heading is %@",userLocation.heading);
}


//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    CLLocation *newLocation = userLocation.location;
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    NSString *latitudeStr = [NSString stringWithFormat:@"%f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%f",coordinate.longitude];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    //更新用户的地理位置
    NSDictionary *positionDict = @{@"longitude":longitudeStr,@"latitude":latitudeStr};
    [HeSysbsModel getSysModel].userLocationDict = [[NSDictionary alloc] initWithDictionary:positionDict];
    [self updateUserPositionWithPosition:positionDict userId:userId];
    
    if (newLocation) {
        locationSucceedNum = locationSucceedNum + 1;
        if (locationSucceedNum >= MinLocationSucceedNum) {
            [self hideHud];
            locationSucceedNum = 0;
            [[NSUserDefaults standardUserDefaults] setObject:latitudeStr forKey:USERLATITUDEKEY];
            [[NSUserDefaults standardUserDefaults] setObject:longitudeStr forKey:USERLONGITUDEKEY];
            
            userLocationDict = @{USERLATITUDEKEY:latitudeStr,USERLONGITUDEKEY:longitudeStr};
            [HeSysbsModel getSysModel].userLocationDict = [[NSDictionary alloc] initWithDictionary:userLocationDict];
        }
    }
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

#pragma mark CLLocationManagerDelegate
//iOS6.0以后定位更新使用的代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations objectAtIndex:0];
    CLLocationCoordinate2D coordinate1 = newLocation.coordinate;
    
    CLLocationCoordinate2D coordinate = [self returnBDPoi:coordinate1];
    NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.longitude];
    
    
    if (newLocation) {
        locationSucceedNum = locationSucceedNum + 1;
        if (locationSucceedNum >= MinLocationSucceedNum) {
            [self hideHud];
            locationSucceedNum = 0;
            [[NSUserDefaults standardUserDefaults] setObject:latitudeStr forKey:USERLATITUDEKEY];
            [[NSUserDefaults standardUserDefaults] setObject:longitudeStr forKey:USERLONGITUDEKEY];
            
        }
    }
    
}

#pragma 火星坐标系 (GCJ-02) 转 mark-(BD-09) 百度坐标系 的转换算法
-(CLLocationCoordinate2D)returnBDPoi:(CLLocationCoordinate2D)PoiLocation
{
    const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    float x = PoiLocation.longitude + 0.0065, y = PoiLocation.latitude + 0.006;
    float z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    float theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationCoordinate2D GCJpoi=
    CLLocationCoordinate2DMake( z * sin(theta),z * cos(theta));
    return GCJpoi;
}

//定位失误时触发
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    //    [self.view makeToast:@"定位失败,请重新定位" duration:2.0 position:@"center"];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateContestZone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"blockUserSucceed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"delTemporaryNotification" object:nil];
}
/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
