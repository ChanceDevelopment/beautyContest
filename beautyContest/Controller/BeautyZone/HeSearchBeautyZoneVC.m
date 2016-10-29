//
//  HeSearchBeautyZoneVC.m
//  beautyContest
//
//  Created by Danertu on 16/10/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeSearchBeautyZoneVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestDetailVC.h"
#import "HeBeautyContestTableCell.h"
#import "DropDownListView.h"
#import "HeDistributeContestVC.h"
#import "FTPopOverMenu.h"
#import "HeFaceToFaceZoneVC.h"
#import "HeZoneConfirmVC.h"
#import "HeUserInfoVC.h"

@interface HeSearchBeautyZoneVC ()
{
    BOOL searchUser;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)NSMutableArray *userDataSource;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;
@property(strong,nonatomic)NSCache *imageCache;
@property(strong,nonatomic)UISearchBar *searchBar;
@property(strong,nonatomic)NSDictionary *userLocationDict;

@end

@implementation HeSearchBeautyZoneVC
@synthesize tableview;
@synthesize userDataSource;
@synthesize dataSource;
@synthesize refreshHeaderView;
@synthesize refreshFooterView;
@synthesize pageNo;
@synthesize imageCache;
@synthesize searchBar;
@synthesize userLocationDict;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"推荐";
        [label sizeToFit];
        self.title = @"推荐";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    imageCache = [[NSCache alloc] init];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNo = 0;
    updateOption = 1;
    userLocationDict = [[NSDictionary alloc] initWithDictionary:[HeSysbsModel getSysModel].userLocationDict];
    searchUser = NO;
    userDataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    [self pullUpUpdate];
    
    CGFloat searchX = 20;
    CGFloat searchY = 5;
    CGFloat searchW = SCREENWIDTH - 2 * searchX - 60;
    CGFloat searchH = 30;
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(searchX, searchY, searchW, searchH)];
    searchBar.tintColor = APPDEFAULTORANGE;
    searchBar.delegate = self;
    searchBar.barStyle = UIBarStyleDefault;
    searchBar.placeholder = @"请输入关键字";
    self.navigationItem.titleView = searchBar;
    
//    down_dark_green
    CGFloat filterH = 20;
    CGFloat filterW = 50;
    CGFloat filterY = 12;
    CGFloat filterX = SCREENWIDTH - 10 - filterW;
    UIButton *filterButton = [[UIButton alloc] initWithFrame:CGRectMake(filterX, filterY, filterW, filterH)];
    [filterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [filterButton.titleLabel setFont:[UIFont systemFontOfSize:13.5]];
    [filterButton setTitle:@"赛区" forState:UIControlStateNormal];
    
    UIImageView *arrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_down"]];
    arrowImage.frame = CGRectMake(40, 6.5, 7, 7);
    [filterButton addSubview:arrowImage];
    [filterButton addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:filterButton];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)filterButtonClick:(UIButton *)button
{
    NSArray *menuArray = @[@"赛区",@"用户"];
    [FTPopOverMenu setTintColor:APPDEFAULTORANGE];
    [FTPopOverMenu showForSender:button
                        withMenu:menuArray
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           [button setTitle:menuArray[selectedIndex] forState:UIControlStateNormal];
                           switch (selectedIndex) {
                               case 0:
                               {
                                   searchUser = NO;
                                   break;
                               }
                               case 1:
                               {
                                   searchUser = YES;
                                   break;
                               }
                               
                               default:
                                   break;
                           }
                           
                           
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
}

- (void)loadBeautyContestWithKeyWord:(NSString *)keyword
{
    if (keyword == nil) {
        keyword = @"";
    }
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/ZoneRankByKeyword.action",BASEURL];
    if (searchUser) {
        requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/SelectUserByKeyword.action",BASEURL];
    }
    NSDictionary *requestMessageParams = @{@"keyword":keyword};
    
    [self showHudInView:self.view hint:@"搜索中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [dataSource removeAllObjects];
            [userDataSource removeAllObjects];
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [tableview reloadData];
                });
                return;
            }
            if (searchUser) {
                for (NSDictionary *zoneDict in resultArray) {
                    [userDataSource addObject:zoneDict];
                }
                
            }
            else{
                for (NSDictionary *zoneDict in resultArray) {
                    [dataSource addObject:zoneDict];
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.3];
                [self.tableview reloadData];
            });
            
        }
        else{
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if (updateOption == 2 && [resultArray count] == 0) {
                pageNo--;
                return;
            }
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
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
    [self loadBeautyContestWithKeyWord:searchKey];
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


#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    //刷新列表
    [self loadBeautyContestWithKeyWord:searchBar.text];
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
    pageNo++;
    
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
    if (searchUser) {
        return [userDataSource count];
    }
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
        if (searchUser) {
            zoneDict = [userDataSource objectAtIndex:row];
        }
        else{
            zoneDict = [dataSource objectAtIndex:row];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    if (searchUser) {
        UITableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        NSString *userHeader = [zoneDict objectForKey:@"userHeader"];
        if ([userHeader isMemberOfClass:[NSNull class]]) {
            userHeader = @"";
        }
        CGFloat userX = 10;
        CGFloat userY = 10;
        CGFloat userH = cellSize.height - 2 * userY;
        CGFloat userW = userH;
        NSString *imageKey = [NSString stringWithFormat:@"%@_%ld",userHeader,row];
        UIImageView *userIcon = [imageCache objectForKey:imageKey];
        if (!userIcon) {
            userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(userX, userY, userW, userH)];
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
            [userIcon sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
            userIcon.layer.cornerRadius = userW / 2.0;
            userIcon.layer.masksToBounds = YES;
            [imageCache setObject:userIcon forKey:imageKey];
        }
        [cell addSubview:userIcon];
        
        CGFloat nameX = CGRectGetMaxX(userIcon.frame) + 10;
        CGFloat nameH = cellSize.height;
        CGFloat nameW = SCREENWIDTH - 10 - nameX;
        CGFloat nameY = 0;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameW, nameH)];
        nameLabel.text = [NSString stringWithFormat:@"%@",zoneDict[@"userNick"]];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [cell addSubview:nameLabel];
        return cell;
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
    userHear = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHear];
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
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (searchUser) {
        return 60;
    }
    return 250;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *zoneDict = nil;
    @try {
        if (searchUser) {
            zoneDict = [userDataSource objectAtIndex:row];
        }
        else{
            zoneDict = [dataSource objectAtIndex:row];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    if (searchUser) {
        HeUserInfoVC *userInfoVC = [[HeUserInfoVC alloc] init];
        User *userInfo = [[User alloc] initUserWithDict:zoneDict];
        userInfoVC.userInfo = userInfo;
        userInfoVC.isScanUser = YES;
        userInfoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfoVC animated:YES];
        return;
    }
    HeContestDetailVC *contestDetailVC = [[HeContestDetailVC alloc] init];
    contestDetailVC.contestBaseDict = [[NSDictionary alloc] initWithDictionary:zoneDict];
    contestDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contestDetailVC animated:YES];
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
