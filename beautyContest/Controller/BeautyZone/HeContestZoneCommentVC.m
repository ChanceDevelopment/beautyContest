//
//  HeWorkingTaskVC.m
//  huayoutong
//
//  Created by Tony on 16/7/27.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeContestZoneCommentVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestDetailVC.h"
#import "HeBeautyContestTableCell.h"
#import "DropDownListView.h"
#import "HeDistributeContestVC.h"
#import "HeUserJoinCell.h"
#import "HeCommentView.h"
#import "HeZoneCommentCell.h"

#define TextLineHeight 1.2f
#define DELETETAG 100

@interface HeContestZoneCommentVC ()<UITableViewDelegate,UITableViewDataSource,DropDownChooseDataSource,DropDownChooseDelegate,CommentProtocol,UIAlertViewDelegate>
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
@property(strong,nonatomic)IBOutlet UIButton *commentButton;
@property(strong,nonatomic)NSDictionary *prepareDeleteDict;
@property(strong,nonatomic)IBOutlet UIView *commentBGView;

@end

@implementation HeContestZoneCommentVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize chooseArray;
@synthesize searchBar;
@synthesize imageCache;
@synthesize commentButton;
@synthesize contestZoneDict;
@synthesize commentBGView;

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
        label.text = @"赛区评论";
        [label sizeToFit];
        
        self.title = @"赛区评论";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    //加载评论
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
//    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
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
    
    [commentButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commentButton.frame.size] forState:UIControlStateNormal];
    [commentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    commentButton.layer.cornerRadius = 5.0;
    commentButton.layer.masksToBounds = YES;
    commentButton.hidden = YES;
    
    
    
    
}

- (IBAction)commentButtonClick:(id)sender
{
    HeCommentView *commentView = [[HeCommentView alloc] init];
    commentView.commentDelegate = self;
    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    [self creatCommentWithCommentText:commentText];
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
    [self loadBeautyContestShow:YES];
}

- (void)deleteCommentWithDict:(NSDictionary *)commentDict
{
    NSString *commentUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([commentUser isMemberOfClass:[NSNull class]] || commentUser == nil) {
        commentUser = @"";
    }
    NSString *commentId = commentDict[@"commentId"];
    if ([commentId isMemberOfClass:[NSNull class]] || commentId == nil) {
        commentId = @"";
    }
    [self showHudInView:self.view hint:@"删除中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/zone/deleteMyComment.action",BASEURL];
    NSDictionary *params = @{@"commentUser":commentUser,@"commentId":commentId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            //重新加载
            [self loadBeautyContestShow:YES];
            [self showHint:@"删除成功"];
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
- (void)creatCommentWithCommentText:(NSString *)commentCoutent
{
    NSString *commentUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([commentUser isMemberOfClass:[NSNull class]] || commentUser == nil) {
        commentUser = @"";
    }
    NSString *commentZone = contestZoneDict[@"zoneId"];
    if ([commentZone isMemberOfClass:[NSNull class]] || commentZone == nil) {
        commentZone = @"";
    }
    [self showHudInView:self.view hint:@"评论中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/zone/createZoneComment.action",BASEURL];
    NSDictionary *params = @{@"commentUser":commentUser,@"commentZone":commentZone,@"commentCoutent":commentCoutent};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            //重新加载
            pageNo = 0;
            [self loadBeautyContestShow:YES];
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
- (void)routerEventWithName:(NSString *)eventName userInfo:(NSDictionary *)userInfo
{
    if ([eventName isEqualToString:@"deleteComment"]) {
        self.prepareDeleteDict = [[NSDictionary alloc] initWithDictionary:userInfo];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除该评论？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        alert.tag = DELETETAG;
        [alert show];
        
        return;
    }
    [self routerEventWithName:eventName userInfo:userInfo];
}
- (void)loadBeautyContestShow:(BOOL)show
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/getZoneComment.action",BASEURL];
    
    NSString *commentZone = contestZoneDict[@"zoneId"];
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"commentZone":commentZone,@"start":pageNum};
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
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeUserJoinCell";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *zoneDict = nil;
    @try {
        zoneDict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    HeZoneCommentCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeZoneCommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.commentDict = [[NSDictionary alloc] initWithDictionary:zoneDict];
    
    id userNick = [zoneDict objectForKey:@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]]) {
        userNick = @"";
    }
    cell.topicLabel.text = userNick;
    
    NSString *userHeader = [zoneDict objectForKey:@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]]) {
        userHeader = @"";
    }
    if (![userHeader hasPrefix:@"http"]) {
        userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    }
    
    UIImageView *imageview = [imageCache objectForKey:userHeader];
    if (!imageview) {
        [cell.bgImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
        imageview = cell.bgImage;
    }
    cell.bgImage = imageview;
    [cell addSubview:cell.bgImage];
    
    
    id zoneCreatetimeObj = [zoneDict objectForKey:@"commentCreatetime"];
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
    NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"YYYY年MM月dd日 HH:mm"];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@",time];
    
    
    NSString *commentCoutent = [zoneDict objectForKey:@"commentCoutent"];
    if ([commentCoutent isMemberOfClass:[NSNull class]] || commentCoutent == nil) {
        commentCoutent = @"";
    }
    CGFloat marginX = 10;
    CGFloat imageW = 50;
    CGFloat image_labelDistance = 5;
    CGFloat labelW = SCREENWIDTH - 2 * marginX - imageW - image_labelDistance;
    UIFont *font = [UIFont  boldSystemFontOfSize:15.0];
    CGSize textSize = [MLLinkLabel getViewSizeByString:commentCoutent maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
    if (textSize.height < 30) {
        textSize.height = 30;
    }
    CGRect contentFrame = cell.addressLabel.frame;
    contentFrame.size.height = textSize.height;
    cell.addressLabel.frame = contentFrame;
    cell.addressLabel.text = commentCoutent;
    
    NSString *commentUser = zoneDict[@"commentUser"];
    if ([commentUser isMemberOfClass:[NSNull class]]) {
        commentUser = @"";
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([userId isEqualToString:commentUser]) {
        cell.deleteButton.hidden = NO;
    }
    else{
        cell.deleteButton.hidden = YES;
    }
    
    return cell;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    return sectionHeaderView;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return sectionHeaderView.frame.size.height;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    NSString *commentCoutent = [zoneDict objectForKey:@"commentCoutent"];
    if ([commentCoutent isMemberOfClass:[NSNull class]] || commentCoutent == nil) {
        commentCoutent = @"";
    }
    CGFloat marginX = 10;
    CGFloat imageW = 50;
    CGFloat image_labelDistance = 5;
    CGFloat labelW = SCREENWIDTH - 2 * marginX - imageW - image_labelDistance;
    UIFont *font = [UIFont  boldSystemFontOfSize:15.0];
    CGSize textSize = [MLLinkLabel getViewSizeByString:commentCoutent maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
    if (textSize.height < 30) {
        textSize.height = 30;
    }
    
    return 60 + textSize.height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    return;
    HeContestDetailVC *contestDetailVC = [[HeContestDetailVC alloc] init];
    contestDetailVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contestDetailVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // Delete the row from the data source.
        self.prepareDeleteDict = [[NSDictionary alloc] initWithDictionary:dataSource[indexPath.row]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定删除该评论？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
        alert.tag = DELETETAG;
        [alert show];
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == DELETETAG && buttonIndex == 1) {
        [self deleteCommentWithDict:self.prepareDeleteDict];
    }
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
