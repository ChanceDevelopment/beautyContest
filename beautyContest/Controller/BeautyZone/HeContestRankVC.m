//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestRankVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestantDetailVC.h"
#import "HeContestantTableCell.h"

#define TextLineHeight 1.2f

@interface HeContestRankVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeContestRankVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize topManRank;
@synthesize topWomanRank;
@synthesize contestDict;
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
        label.text = @"光荣榜";
        [label sizeToFit];
        
        self.title = @"光荣榜";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    if ([topWomanRank count] == 0) {
        [self getWomanRank];
    }
}

- (void)initializaiton
{
    [super initializaiton];
    if (!topManRank) {
        topManRank = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!topWomanRank) {
        topWomanRank = [[NSMutableArray alloc] initWithCapacity:0];
    }
    imageCache = [[NSCache alloc] init];
    dataSource = [[NSMutableArray alloc] initWithArray:topManRank];
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
    
    NSArray *buttonArray = @[@"女神",@"男神"];
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

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"favButtonClick"]) {
        NSString *userId = userInfo[@"userId"];
        if (userId == nil) {
            userId = @"";
        }
        NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
        if (![myUserId isEqualToString:userId]) {
            return;
        }
        NSString *voteZone = contestDict[@"zoneId"];
        if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
            voteZone = @"";
        }
        NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/flopOne.action",BASEURL];
        NSDictionary *params = @{@"selectedZone":voteZone,@"selectedUser":userId};
        [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
            [self hideHud];
            NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
            NSDictionary *respondDict = [respondString objectFromJSONString];
            NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
            
            if (statueCode == REQUESTCODE_SUCCEED){
                [self showHint:@"成功锤一位"];
            }
            else{
                NSString *data = [respondDict objectForKey:@"data"];
                if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                    data = ERRORREQUESTTIP;
                }
                [self showHint:data];
            }
        } failure:^(NSError *error){
            [self showHint:ERRORREQUESTTIP];
        }];
        return;
    }
    [super routerEventWithName:eventName userInfo:userInfo];
}

- (void)getManTopRank
{
    [self showHudInView:self.view hint:@"加载中..."];
    NSString *voteZone = contestDict[@"zoneId"];
    if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
        voteZone = @"";
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/getZoneManTop6.action",BASEURL];
    NSDictionary *params = @{@"voteZone":voteZone};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            if ([jsonObj isKindOfClass:[NSArray class]]) {
                [topManRank removeAllObjects];
                for (NSDictionary *dict in jsonObj) {
                    [topManRank addObject:dict];
                }
            }
            dataSource = [[NSMutableArray alloc] initWithArray:topManRank];
            [tableview reloadData];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)getWomanRank
{
    [self showHudInView:self.view hint:@"加载中..."];
    NSString *voteZone = contestDict[@"zoneId"];
    if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
        voteZone = @"";
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/getZoneWomanTop6.action",BASEURL];
    NSDictionary *params = @{@"voteZone":voteZone};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            if ([jsonObj isKindOfClass:[NSArray class]]) {
                [topWomanRank removeAllObjects];
                for (NSDictionary *dict in jsonObj) {
                    [topWomanRank addObject:dict];
                }
            }
            dataSource = [[NSMutableArray alloc] initWithArray:topWomanRank];
            [tableview reloadData];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
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
    if (button.tag == 100 && [topManRank count] == 0) {
        [self getWomanRank];
    }
    else if (button.tag == 101 && [topWomanRank count] == 0){
        [self getManTopRank];
    }
    else if (button.tag == 100){
        dataSource = [[NSMutableArray alloc] initWithArray:topManRank];
        [tableview reloadData];
    }
    else if (button.tag == 101){
        dataSource = [[NSMutableArray alloc] initWithArray:topWomanRank];
        [tableview reloadData];
    }
}

- (void)loadRankingDataShow:(BOOL)show
{

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
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeContestantTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeContestantTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeContestantTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    cell.userInfo = [[NSDictionary alloc] initWithDictionary:dict];
    
    NSString *userHeader = dict[@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
        userHeader = @"";
    }
    if (![userHeader hasPrefix:@"http"]) {
        userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    }
    
    UIImageView *imageview = [imageCache objectForKey:userHeader];
    if (!imageview) {
        [cell.userImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
        imageview = cell.userImage;
    }
    cell.userImage = imageview;
    [cell addSubview:cell.userImage];
    
    NSString *userNick = dict[@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.nameLabel.text = userNick;
    
    NSString *infoProfession = dict[@"infoProfession"];
    if ([infoProfession isMemberOfClass:[NSNull class]] || infoProfession == nil) {
        infoProfession = @"";
    }
    cell.distanceLabel.text = infoProfession;
    
    NSString *userId = contestDict[@"userId"];
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = @"";
    }
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (![myUserId isEqualToString:userId]) {
        //按钮不能显示在非发布用户的页面中
        cell.favButton.hidden = YES;
    }
    else{
        cell.favButton.hidden = NO;
    }
    cell.favButton.hidden = YES;
    
    id prizeMoneyObj = dict[@"prizeMoney"];
    if ([prizeMoneyObj isMemberOfClass:[NSNull class]]) {
        prizeMoneyObj = @"";
    }
    CGFloat prizeMoney = [prizeMoneyObj floatValue];
    if (prizeMoney < 0.1) {
        cell.prizeMoneyLabel.text = @"￥0";
    }
    else{
        cell.prizeMoneyLabel.text = [NSString stringWithFormat:@"%.2f",prizeMoney];
    }
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
    return 70;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *dict = nil;
    @try {
        dict = dataSource[row];
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
    
    HeContestantDetailVC *contantDetailVC = [[HeContestantDetailVC alloc] init];
    contantDetailVC.contestantBaseDict = [[NSDictionary alloc] initWithDictionary:dict];
    contantDetailVC.contestZoneDict = [[NSDictionary alloc] initWithDictionary:contestDict];
    contantDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contantDetailVC animated:YES];
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
