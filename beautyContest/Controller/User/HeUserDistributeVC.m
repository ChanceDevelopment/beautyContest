//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserDistributeVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestantDetailVC.h"
#import "HeContestantTableCell.h"
#import "HeUserDistributeContestCell.h"
#import "HeUserRecommendCell.h"
#import "HeUserContestCell.h"

#define TextLineHeight 1.2f

@interface HeUserDistributeVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource; //推荐
@property(strong,nonatomic)NSMutableArray *zoneDataSource; //赛区

@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;

@property(strong,nonatomic)NSCache *imageCache;
@end

@implementation HeUserDistributeVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize zoneDataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
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
        label.text = @"我的发布";
        [label sizeToFit];
        
        self.title = @"我的发布";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadRankingDataShow:YES];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    zoneDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    imageCache = [[NSCache alloc] init];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor whiteColor];
    [Tool setExtraCellLineHidden:tableview];
    [self pullUpUpdate];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
    NSArray *buttonArray = @[@"推荐",@"赛区"];
    for (NSInteger index = 0; index < [buttonArray count]; index++) {
        CGFloat buttonW = SCREENWIDTH / [buttonArray count];
        CGFloat buttonH = sectionHeaderView.frame.size.height;
        CGFloat buttonX = index * buttonW;
        CGFloat buttonY = 0;
        CGRect buttonFrame = CGRectMake(buttonX , buttonY, buttonW, buttonH);
        UIButton *button = [self buttonWithTitle:buttonArray[index] frame:buttonFrame];
        button.tag = index + 100;
        if (index == 0) {
            button.selected = YES;
        }
        [sectionHeaderView addSubview:button];
    }
}

- (UIButton *)buttonWithTitle:(NSString *)buttonTitle frame:(CGRect)buttonFrame
{
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button setTitle:buttonTitle forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:143.0 / 255.0 alpha:1.0] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [button setBackgroundImage:[Tool buttonImageFromColor:[UIColor whiteColor] withImageSize:button.frame.size] forState:UIControlStateSelected];
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
    [self loadRankingDataShow:YES];
}

- (void)loadRankingDataShow:(BOOL)show
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:[zoneDataSource count]];
    NSDictionary *requestMessageParams = @{@"userId":userid};
    
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/recommend/getrecommend.action",BASEURL];
    if (requestReply) {
        requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/getHistoryZone.action",BASEURL];
        requestMessageParams = @{@"zoneUser":userid,@"start":pageNum};
    }
    
    
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
            if (!requestReply) {
                [dataSource removeAllObjects];
            }
            if (updateOption == 1) {
                if (requestReply) {
                    [zoneDataSource removeAllObjects];
                }
            }
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            for (NSDictionary *zoneDict in resultArray) {
                if (!requestReply) {
                    [dataSource addObject:zoneDict];
                }
                else{
                    [zoneDataSource addObject:zoneDict];
                }
                
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

#pragma mark -
#pragma mark Data Source Loading / Reloading Methods

- (void)reloadTableViewDataSource{
    _reloading = YES;
    //刷新列表
    [self loadRankingDataShow:NO];
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
    pageNo = 1;
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
    if (!requestReply) {
        return [dataSource count];
    }
    return [zoneDataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeUserDistributeContestCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    NSDictionary *dict = nil;
    @try {
        if (!requestReply) {
            dict = dataSource[row];
        }
        else{
            dict = zoneDataSource[row];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    
    if (!requestReply) {
        HeUserRecommendCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
        if (!cell) {
            cell = [[HeUserRecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        }
        NSString *recommendContent = dict[@"recommendContent"];
        if ([recommendContent isMemberOfClass:[NSNull class]] || recommendContent == nil) {
            recommendContent = @"";
        }
        CGFloat labelW = cell.contentLabel.frame.size.width;
        UIFont *font = [UIFont  systemFontOfSize:16.0];
        CGSize textSize = [MLLinkLabel getViewSizeByString:recommendContent maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
        if (textSize.height < 30) {
            textSize.height = 30;
        }
        CGRect contentFrame = cell.contentLabel.frame;
        contentFrame.size.height = textSize.height;
        cell.contentLabel.text = recommendContent;
        
        id recommendCreateTimeObj = [dict objectForKey:@"recommendCreateTime"];
        if ([recommendCreateTimeObj isMemberOfClass:[NSNull class]] || recommendCreateTimeObj == nil) {
            NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
            recommendCreateTimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
        }
        long long timestamp = [recommendCreateTimeObj longLongValue];
        NSString *recommendCreateTime = [NSString stringWithFormat:@"%lld",timestamp];
        if ([recommendCreateTime length] > 3) {
            //时间戳
            recommendCreateTime = [recommendCreateTime substringToIndex:[recommendCreateTime length] - 3];
        }
        
        NSString *time = [Tool convertTimespToString:[recommendCreateTime longLongValue] dateFormate:@"yyyy-MM-dd"];
        cell.timeLabel.text = [NSString stringWithFormat:@"%@",time];
        
        NSString *recommendCover = dict[@"recommendCover"];
        if ([recommendCover isMemberOfClass:[NSNull class]] || recommendCover == nil) {
            recommendCover = @"";
        }
        NSArray *recommendCoverArray = [recommendCover componentsSeparatedByString:@","];
        NSString *imageUrl = recommendCoverArray[0];
        NSString *imageKey = [NSString stringWithFormat:@"%ld_%@",row,imageUrl];
        UIImageView *imageview = [imageCache objectForKey:imageKey];
        if (!imageview) {
            imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,imageUrl];
            [cell.imageview sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
            imageview = cell.imageview;
        }
        cell.imageview = imageview;
        [cell addSubview:cell.imageview];
        
        return cell;
    }
    
    HeUserContestCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeUserContestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
    }
    
    NSString *zoneCover = dict[@"zoneCover"];
    NSString *imageKey = [NSString stringWithFormat:@"contest_%ld_%@",row,zoneCover];
    UIImageView *imageview = [imageCache objectForKey:imageKey];
    if (!imageview) {
        zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,zoneCover];
        [cell.imageview sd_setImageWithURL:[NSURL URLWithString:zoneCover] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
        imageview = cell.imageview;
    }
    cell.imageview = imageview;
    [cell addSubview:cell.imageview];
    
    NSString *zoneTitle = dict[@"zoneTitle"];
    if ([zoneTitle isMemberOfClass:[NSNull class]] || zoneTitle == nil) {
        zoneTitle = @"";
    }
    cell.contentLabel.text = zoneTitle;
    [cell.imageview addSubview:cell.contentLabel];
    
    id zoneCreatetimeObj = [dict objectForKey:@"zoneCreatetime"];
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
    
    NSString *creattime = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"yyyy-MM-dd HH:mm"];
    
    id zoneDeathlineObj = [dict objectForKey:@"zoneDeathline"];
    if ([zoneDeathlineObj isMemberOfClass:[NSNull class]] || zoneDeathlineObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        zoneDeathlineObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    timestamp = [zoneDeathlineObj longLongValue];
    NSString *zoneDeathlinetime = [NSString stringWithFormat:@"%lld",timestamp];
    if ([zoneDeathlinetime length] > 3) {
        //时间戳
        zoneDeathlinetime = [zoneDeathlinetime substringToIndex:[zoneDeathlinetime length] - 3];
    }
    
    NSString *deathlinetime = [Tool convertTimespToString:[zoneDeathlinetime longLongValue] dateFormate:@"yyyy-MM-dd HH:mm"];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%@ - %@",creattime,deathlinetime];
    [cell.imageview addSubview:cell.timeLabel];
    
    NSString *zoneAddress = dict[@"zoneAddress"];
    if ([zoneAddress isMemberOfClass:[NSNull class]] || zoneAddress == nil) {
        zoneAddress = @"";
    }
    cell.addressLabel.text = zoneAddress;
    [cell.imageview addSubview:cell.addressLabel];
    
    
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
    NSInteger row = indexPath.row;
    NSDictionary *dict = nil;
    @try {
        if (!requestReply) {
            dict = dataSource[row];
        }
        else{
            dict = zoneDataSource[row];
        }
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    if (!requestReply) {
        NSString *recommendContent = dict[@"recommendContent"];
        if ([recommendContent isMemberOfClass:[NSNull class]] || recommendContent == nil) {
            recommendContent = @"";
        }
        CGFloat labelX = 10;
        CGFloat labelW = SCREENWIDTH - 2 * labelX;
        UIFont *font = [UIFont  systemFontOfSize:15.0];
        CGSize textSize = [MLLinkLabel getViewSizeByString:recommendContent maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
        if (textSize.height < 30) {
            textSize.height = 30;
        }
        return 220 + textSize.height - 30;
    }
    return 150;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
//    HeContestantDetailVC *contantDetailVC = [[HeContestantDetailVC alloc] init];
//    contantDetailVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:contantDetailVC animated:YES];
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
