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

#define TextLineHeight 1.2f

@interface HeBeautyZoneVC ()<UITableViewDelegate,UITableViewDataSource,DropDownChooseDataSource,DropDownChooseDelegate>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;
@property(strong,nonatomic)NSMutableArray *chooseArray;

@end

@implementation HeBeautyZoneVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize chooseArray;

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
    //加载我的提问
    [self loadBeautyContestShow:YES];
}

- (void)initializaiton
{
    [super initializaiton];
    requestReply = NO;
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    pageNo = 1;
    updateOption = 1;
    
    chooseArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    //距离数据
    NSArray *distanceArray = @[@"100米以内",@"1000米以内",@"其他"];
    //地点数据
    NSArray *hotArray = @[@"历史最热",@"本周最热",@"本月最热"];
    //时间数据
    NSArray *timeArray = @[@"一周内",@"一个月内",@"三个月内"];
    
    
    chooseArray = [NSMutableArray arrayWithArray:@[
                                                   distanceArray,
                                                   hotArray,
                                                   timeArray
                                                   ]];
    
    
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
    
    NSArray *defaultArray = @[@"距离",@"热度",@"赏金"];
    DropDownListView *timedropDownView = [[DropDownListView alloc] initWithFrame:CGRectMake(0,0, SCREENWIDTH, sectionHeaderView.frame.size.height) dataSource:self delegate:self defaultTitleArray:defaultArray];
    if (!ISIOS7) {
        timedropDownView.frame = CGRectMake(0,0, SCREENWIDTH, sectionHeaderView.frame.size.height);
    }
    timedropDownView.tag = 1;
    timedropDownView.mSuperView = self.view;
    
    [sectionHeaderView addSubview:timedropDownView];
    
//    NSArray *buttonArray = @[@"未完成",@"已完成"];
//    for (NSInteger index = 0; index < [buttonArray count]; index++) {
//        CGFloat buttonW = SCREENWIDTH / [buttonArray count];
//        CGFloat buttonH = sectionHeaderView.frame.size.height;
//        CGFloat buttonX = index * buttonW;
//        CGFloat buttonY = 0;
//        CGRect buttonFrame = CGRectMake(buttonX , buttonY, buttonW, buttonH);
//        UIButton *button = [self buttonWithTitle:buttonArray[index] frame:buttonFrame];
//        button.tag = index + 100;
//        if (index == 0) {
//            button.selected = YES;
//        }
//        [sectionHeaderView addSubview:button];
//    }
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

- (void)loadBeautyContestShow:(BOOL)show
{
    NSString *requestWorkingTaskPath = @"";
    
    NSString *keyword = @"";
    NSString *userId = @"f7117f0c38274805013827cb797e00d7";
    NSString *t_token = @"222111632317cff566e0870830870811892d845d4c0c6fd06a15804815910c4426a2";
    NSString *t_version	= @"169";
    NSString *timestamp	= @"7c6e8381d8cdc0fa";
    NSNumber *isFinish = [NSNumber numberWithInt:0];
    if (requestReply) {
        isFinish = [NSNumber numberWithInt:0];
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"keyword":keyword,@"userId":userId,@"t_token":t_token,@"t_version":t_version,@"timestamp":timestamp,@"pageNo":pageNum,@"isFinish":isFinish};
    if (show) {
        [Waiting show];
    }
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        
        if (show) {
            [Waiting dismiss];
        }
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger totalCount = [[respondDict objectForKey:@"totalCount"] integerValue];
        NSInteger totalPages = [[respondDict objectForKey:@"totalPages"] integerValue];
        NSInteger statueCode = [[respondDict objectForKey:@"code"] integerValue];
        
        if (totalCount != 0){
            if (updateOption == 1) {
                [dataSource removeAllObjects];
            }
            NSArray *resultArray = [respondDict objectForKey:@"result"];
            for (NSDictionary *taskDict in resultArray) {
                [dataSource addObject:taskDict];
            }
            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            [self.tableview reloadData];
        }
        else{
            if (updateOption == 2) {
                pageNo--;
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
    switch (section) {
        case 0:
        {
            
            break;
        }
        case 1:{
            
            break;
        }
        case 2:{
            
            break;
        }
        default:
            break;
    };
    pageNo = 1;//选择以后相当于刷新
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
    
    static NSString *cellIndentifier = @"HeBeautyContestTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *workTaskDict = nil;
    @try {
        workTaskDict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    HeBeautyContestTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBeautyContestTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(5, (cellSize.height - 3) / 2.0, 3, 3)];
    circleView.backgroundColor = [UIColor colorWithRed:164.0 / 255.0 green:57 / 255.0 blue:5.0 / 255.0 alpha:1.0];
    circleView.layer.cornerRadius = 1.5;
    circleView.layer.masksToBounds = YES;
    [cell.contentView addSubview:circleView];
    
    CGFloat titleX = CGRectGetMaxX(circleView.frame) + 5;
    CGFloat titleY = 10;
    CGFloat titleW = SCREENWIDTH - titleX - 20;
    CGFloat titleH = 0;
    
    NSString *title = [workTaskDict objectForKey:@"title"];
    if ([title isMemberOfClass:[NSNull class]] || title == nil) {
        title = @"";
    }
    titleH = [MLLinkLabel getViewSizeByString:title maxWidth:titleW font:textFont lineHeight:TextLineHeight lines:0].height;
    if (titleH < 30) {
        titleH = 30;
    }
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.text = title;
    titleLabel.numberOfLines = 0;
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.font = textFont;
    titleLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [cell.contentView addSubview:titleLabel];
    
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
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    NSDictionary *taskDict = [dataSource objectAtIndex:row];
    NSString *title = [taskDict objectForKey:@"title"];
    if ([title isMemberOfClass:[NSNull class]] || title == nil) {
        title = @"";
    }
    CGFloat titleW = SCREENWIDTH - 33;
    CGFloat titleH = [MLLinkLabel getViewSizeByString:title maxWidth:titleW font:textFont lineHeight:TextLineHeight lines:0].height;
    if (titleH < 30) {
        titleH = 30;
    }
    CGFloat margin = 10;
    
    return titleH + 2 * margin;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *taskDict = [dataSource objectAtIndex:row];
    
    HeContestDetailVC *contestDetailVC = [[HeContestDetailVC alloc] init];
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
