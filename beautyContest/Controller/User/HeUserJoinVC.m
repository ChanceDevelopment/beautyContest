//
//  HeWorkingTaskVC.m
//  huayoutong
//
//  Created by Tony on 16/7/27.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeUserJoinVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestDetailVC.h"
#import "HeBeautyContestTableCell.h"
#import "DropDownListView.h"
#import "HeDistributeContestVC.h"
#import "HeUserJoinCell.h"
#import "HeUserNewJoinCell.h"

#define TextLineHeight 1.2f

@interface HeUserJoinVC ()<UITableViewDelegate,UITableViewDataSource,DropDownChooseDataSource,DropDownChooseDelegate>
{
    BOOL requestReply; //是否已经完成
    NSInteger orderType; //排序类型
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
@end

@implementation HeUserJoinVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize chooseArray;
@synthesize searchBar;
@synthesize imageCache;

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
        label.text = @"我的参与";
        [label sizeToFit];
        
        self.title = @"我的参与";
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


- (void)initializaiton
{
    [super initializaiton];
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
    
    NSArray *defaultArray = @[@"距离",@"热度",@"赏金"];
    DropDownListView *timedropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(0,0, SCREENWIDTH, sectionHeaderView.frame.size.height) dataSource:self delegate:self defaultTitleArray:defaultArray];
    if (!ISIOS7) {
        timedropDownView.frame = CGRectMake(0,0, SCREENWIDTH, sectionHeaderView.frame.size.height);
    }
    timedropDownView.tag = 1;
    timedropDownView.mSuperView = self.view;
    
    [sectionHeaderView addSubview:timedropDownView];
    
    CGFloat searchX = 30;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX;
    CGFloat searchH = SCREENHEIGH - 2 * searchY;
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
//    self.navigationItem.rightBarButtonItem = distributeItem;
}

- (void)distributeButtonClick:(UIButton *)button
{
    NSLog(@"distributeButtonClick");
    HeDistributeContestVC *distributeContestVC = [[HeDistributeContestVC alloc] init];
    distributeContestVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:distributeContestVC animated:YES];
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
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/getHistoryPart.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"userId":userid,@"start":pageNum};
    [self showHudInView:self.view hint:@"正在获取..."];
    
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
            for (NSDictionary *zoneDict in resultArray) {
                [dataSource addObject:zoneDict];
            }
            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            [self.tableview reloadData];
        }
        else{
            NSArray *resultArray = [respondDict objectForKey:@"json"];
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
    
    HeUserNewJoinCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeUserNewJoinCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
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
    
    id zoneCreatetimeObj = [zoneDict objectForKey:@"zoneCreatetime"];
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
    
    id timeLeftObj = zoneDict[@"timeLeft"];
    
    NSString *timeTip = @"赛区马上截止";
    if ([timeLeftObj floatValue] <= 0) {
        timeTip = @"赛区已经截止";
    }
    
    //秒
    CGFloat timeLeft_second = [timeLeftObj integerValue] / 1000.0;
    if (timeLeft_second < 60.0) {
        timeTip = @"赛区马上截止";
    }
    else{
        timeLeft_second = timeLeft_second / 60.0;
    }
    
    if (timeLeft_second < 60.0) {
        timeTip = [NSString stringWithFormat:@"%d分钟后赛区截止",(int)ceil(timeLeft_second) - 1];
    }
    else{
        timeLeft_second = timeLeft_second / 60.0;
    }
    
    if (timeLeft_second < 60.0) {
        timeTip = [NSString stringWithFormat:@"%d小时后赛区截止",(int)ceil(timeLeft_second) - 1];
    }
    else{
        timeLeft_second = timeLeft_second / 24.0;
        timeTip = [NSString stringWithFormat:@"%d天后赛区截止",(int)ceil(timeLeft_second) - 1];
    }
    cell.distanceTimeLabel.text = timeTip;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 270;
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
