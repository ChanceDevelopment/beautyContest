//
//  HeNewRecommendVC.m
//  beautyContest
//
//  Created by Danertu on 16/10/28.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeNewRecommendVC.h"
#import "HeNewRecommendCell.h"
#import "HeRecommendDetailVC.h"
#import "HeDistributeRecommendVC.h"
#import "HeCommentView.h"

@interface HeNewRecommendVC ()<CommentProtocol>
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

@property(strong,nonatomic)NSDictionary *currentSelectRecommend;

@end

@implementation HeNewRecommendVC
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
@synthesize currentSelectRecommend;

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
    [self loadBeautyContestShow:YES];
}

- (void)initializaiton
{
    [super initializaiton];
    updateOption = 1;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNo = 0;
    imageCache = [[NSCache alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateRecommend:) name:@"updateRecommend" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(blockUserSucceed:) name:@"blockUserSucceed" object:nil];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [Tool setExtraCellLineHidden:tableview];
    [self pullUpUpdate];
    
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(distributeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    distributeItem.target = self;
    self.navigationItem.rightBarButtonItem = distributeItem;
}

- (void)distributeButtonClick:(id)sender
{
    HeDistributeRecommendVC *distributeVC = [[HeDistributeRecommendVC alloc] init];
    distributeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:distributeVC animated:YES];
}

- (void)updateRecommend:(NSNotification *)notification
{
    [self loadBeautyContestShow:NO];
}

- (void)blockUserSucceed:(NSNotification *)notificaition
{
    NSDictionary *userInfo = notificaition.userInfo;
    NSString *userId = userInfo[@"userId"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSDictionary *zoneDict in dataSource) {
        NSString *zoneUserId = zoneDict[@"recommendUser"];
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

- (void)loadBeautyContestShow:(BOOL)show
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/recommend/showwaterfallflow.action",BASEURL];
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"pageNum":pageNum};
    
    [self showHudInView:self.tableview hint:@"获取中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
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
                    NSString *zoneUserId = zoneDict[@"recommendUser"];
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
            if (updateOption == 2 && [resultArray count] == 0) {
                pageNo--;
                return;
            }
        }
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"favButtonClick"]) {
        NSLog(@"favButtonClick  userInfo = %@",userInfo);
        currentSelectRecommend = [[NSDictionary alloc] initWithDictionary:userInfo];
        NSString *recommendUser = userInfo[@"recommendUser"];
        [self followUser:recommendUser];
    }
    else if ([eventName isEqualToString:@"commentButtonClick"]){
        currentSelectRecommend = [[NSDictionary alloc] initWithDictionary:userInfo];
        NSString *recommendUser = userInfo[@"recommendUser"];
        [self commentWithUserId:recommendUser];
        NSLog(@"commentButtonClick userInfo = %@",userInfo);
    }
    else{
        [super routerEventWithName:eventName userInfo:userInfo];
    }
}

- (void)followUser:(NSString *)userId
{
    NSString *hostId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([hostId isMemberOfClass:[NSNull class]] || hostId == nil) {
        hostId = @"";
    }
    
    
    [self showHudInView:self.view hint:@"关注中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/user/follow.action",BASEURL];
    NSDictionary *params = @{@"userId":userId,@"hostId":hostId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"成功关注";
            }
            [self showHint:data];
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

- (void)commentWithUserId:(NSString *)userId
{
    NSString *hostId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([hostId isMemberOfClass:[NSNull class]] || hostId == nil) {
        hostId = @"";
    }
    HeCommentView *commentView = [[HeCommentView alloc] init];
    commentView.title = @"留言";
    commentView.commentDelegate = self;
    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    NSString *blogHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *blogUser = currentSelectRecommend[@"recommendUser"];
    if ([blogUser isMemberOfClass:[NSNull class]] || blogUser == nil) {
        blogUser = @"";
    }
    NSString *blogContent = commentText;
    if (blogContent == nil) {
        blogContent = @"";
    }
    [self showHudInView:self.view hint:@"留言中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/user/message.action",BASEURL];
    NSDictionary *params = @{@"blogHost":blogHost,@"blogUser":blogUser,@"blogContent":blogContent};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"留言成功";
            }
            [self showHint:data];
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
    NSInteger section = indexPath.section;
    static NSString *cellIndentifier = @"HeNewRecommendCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *zoneDict = nil;
    @try {
        zoneDict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    HeNewRecommendCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeNewRecommendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    id recommendContent = [zoneDict objectForKey:@"recommendContent"];
    if ([recommendContent isMemberOfClass:[NSNull class]]) {
        recommendContent = @"";
    }
    cell.recommentDict = [[NSDictionary alloc] initWithDictionary:zoneDict];
    cell.topicLabel.text = recommendContent;
    
    
    NSString *zoneCover = [zoneDict objectForKey:@"backgroundPic"];
    if ([zoneCover isMemberOfClass:[NSNull class]]) {
        zoneCover = @"";
    }
    NSString *zoneCoverKey = [NSString stringWithFormat:@"zoneCover_%@_%ld_%ld",zoneCover,section,row];
    
    NSArray *zoneCoverArray = [zoneCover componentsSeparatedByString:@","];
    zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,[zoneCoverArray firstObject]];
    UIImageView *imageview = [imageCache objectForKey:zoneCoverKey];
    if (!imageview) {
        [cell.bgImage sd_setImageWithURL:[NSURL URLWithString:zoneCover] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
        imageview = cell.bgImage;
        [imageCache setObject:imageview forKey:zoneCoverKey];
    }
    cell.bgImage = imageview;
    [cell.bgView addSubview:cell.bgImage];
    
    
    NSString *userHeader = [zoneDict objectForKey:@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]]) {
        userHeader = @"";
    }
    NSString *userHeaderKey = [NSString stringWithFormat:@"userHeader_%@_%ld_%ld",userHeader,section,row];
    
    userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    UIImageView *userHeaderImage = [imageCache objectForKey:userHeaderKey];
    if (!userHeaderImage) {
        [cell.detailImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userHeaderImage = cell.detailImage;
        [imageCache setObject:userHeaderImage forKey:userHeaderKey];
    }
    cell.detailImage = userHeaderImage;
    [cell.bgView addSubview:cell.detailImage];
    
    id userNick = [zoneDict objectForKey:@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]]) {
        userNick = @"";
    }
    cell.tipLabel.text = userNick;
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *recommendUserId = zoneDict[@"recommendUser"];
    if ([recommendUserId isMemberOfClass:[NSNull class]]) {
        recommendUserId = nil;
    }
    if ([userId isEqualToString:recommendUserId]) {
        cell.commentButton.hidden = YES;
        cell.favButton.hidden = YES;
    }
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat viewX = 10;
    CGFloat viewY = 10;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = viewW + 2 * viewY + 70;
    
    return viewH;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *recommendDict = nil;
    @try {
        recommendDict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    HeRecommendDetailVC *recommendVC = [[HeRecommendDetailVC alloc] init];
    recommendVC.recommendDict = [[NSDictionary alloc] initWithDictionary:recommendDict];
    recommendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommendVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updateRecommend" object:nil];
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
