//
//  HeNearbyVC.m
//  beautyContest
//
//  Created by Tony on 16/8/3.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserMessageVC.h"
#import "HeUserMessageCell.h"
#import "MLLabel+Size.h"
#import "HeCommentView.h"
#import "HeMyMessageCell.h"
#import "HeContestantUserInfoVC.h"

#define TextLineHeight 1.2f

@interface HeUserMessageVC ()<CommentProtocol>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)EGORefreshTableHeaderView *refreshHeaderView;
@property(strong,nonatomic)EGORefreshTableFootView *refreshFooterView;
@property(assign,nonatomic)NSInteger pageNo;
@property(strong,nonatomic)NSCache *imageCache;
@property(strong,nonatomic)NSMutableDictionary *replyDict;
@property(strong,nonatomic)NSMutableDictionary *replyIndexDict;
@property(strong,nonatomic)NSMutableDictionary *replyShowDict;

@property(strong,nonatomic)NSDictionary *currentReplyDict;

@end

@implementation HeUserMessageVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize refreshFooterView;
@synthesize refreshHeaderView;
@synthesize pageNo;
@synthesize imageCache;
@synthesize replyDict;
@synthesize replyIndexDict;
@synthesize replyShowDict;
@synthesize currentReplyDict;

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
        label.text = @"我的留言";
        [label sizeToFit];
        
        self.title = @"我的留言";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadUserMessageShow:NO];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    replyDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    pageNo = 0;
    updateOption = 1;
    imageCache = [[NSCache alloc] init];
    replyIndexDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    replyShowDict = [[NSMutableDictionary alloc] initWithCapacity:0];
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
}

- (void)showTableWithBlogId:(NSString *)blogId
{
    NSInteger index = [[replyIndexDict objectForKey:blogId] integerValue];
    BOOL show = [[replyShowDict objectForKey:blogId] boolValue];
    [replyShowDict setObject:[NSNumber numberWithBool:!show] forKey:blogId];
    //话题
    NSDictionary *dict = dataSource[index];
    //话题的相关对话
    NSArray *replyArray = [replyDict objectForKey:blogId];
    
    [tableview reloadData];
    
}

- (void)replyUserWithUserId:(NSString *)userId
{
    HeCommentView *commentView = [[HeCommentView alloc] init];
    commentView.commentDelegate = self;
    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    NSString *replyHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *replyBlog = currentReplyDict[@"blogId"];
    NSString *replyContent = commentText;
    if (replyContent == nil) {
        replyContent = @"";
    }
    [self showHudInView:self.view hint:@"回复中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/user/reply.action",BASEURL];
    NSDictionary *params = @{@"replyHost":replyHost,@"replyBlog":replyBlog,@"replyContent":replyContent};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"回复成功";
            }
            [self showHint:data];
            [self getReplyWithBlogID:replyBlog];
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
    if ([eventName isEqualToString:@"showReplyMessage"]) {
        NSLog(@"showReplyMessage");
        NSString *blogId = userInfo[@"blogId"];
        if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
            blogId = @"";
        }
    }
    else if ([eventName isEqualToString:@"scanUserDetail"]){
        NSString *userId = userInfo[@"blogHost"];
        if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
            userId = userInfo[@"replyHost"];
        }
        if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
            userId = @"";
        }
        HeContestantUserInfoVC *userInfoVC = [[HeContestantUserInfoVC alloc] init];
        userInfoVC.userId = [NSString stringWithFormat:@"%@",userId];
        userInfoVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userInfoVC animated:YES];
    }
    else if ([eventName isEqualToString:@"replyMessage"]){
        NSString *blogId = userInfo[@"blogId"];
        if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
            blogId = @"";
        }
        currentReplyDict = [[NSDictionary alloc] initWithDictionary:userInfo];
        [self replyUserWithUserId:blogId];
    }
    else{
        [super routerEventWithName:eventName userInfo:userInfo];
    }
}

- (void)loadUserMessageShow:(BOOL)show
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/getMessaageForReplyList.action",BASEURL];
    ///user/getMyMessagesList.action 留言
    ///user/getMessageReply.action  回复
    NSString *blogUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!blogUser) {
        blogUser = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"userId":blogUser,@"number":pageNum};
    
    [self showHudInView:self.tableview hint:@"正在获取..."];
    
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
                [replyIndexDict removeAllObjects];
            }
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                [self showHint:@"更多加载完毕"];
                return ;
            }
            NSInteger index = 0;
            for (NSDictionary *zoneDict in resultArray) {
                [dataSource addObject:zoneDict];
                NSString *blogId = [NSString stringWithFormat:@"%@",[zoneDict objectForKey:@"blogId"]];
                [replyIndexDict setObject:[NSNumber numberWithInteger:index] forKey:blogId];
                [replyShowDict setObject:[NSNumber numberWithBool:NO] forKey:blogId];
                index++;
                [self getReplyWithBlogID:blogId];
                
            }
            [self performSelector:@selector(addFooterView) withObject:nil afterDelay:0.5];
            [self.tableview reloadData];
        }
        else{
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if (updateOption == 2 && [resultArray count] == 0) {
                pageNo = [dataSource count];
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

- (void)getReplyWithBlogID:(NSString *)blogId
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/getMessageReply.action",BASEURL];
    ///user/getMyMessagesList.action 留言
    ///user/getMessageReply.action  回复
    NSDictionary *requestMessageParams = @{@"blogId":blogId};
    
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            [replyDict setObject:resultArray forKey:blogId];
        }
        [tableview reloadData];
        
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
    [self loadUserMessageShow:NO];
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
    NSDictionary *dict = dataSource[section];
    NSString *blogId = dict[@"blogId"];
    if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
        blogId = @"";
    }
    BOOL show = [[replyShowDict objectForKey:blogId] boolValue];
    if (show) {
        NSArray *replyArray = [replyDict objectForKey:blogId];
        return 1 + [replyArray count];
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeNearbyTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:section];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    if (row != 0) {
        NSString *blogId = dict[@"blogId"];
        if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
            blogId = @"";
        }
        NSArray *replyArray = [replyDict objectForKey:blogId];
        dict = [replyArray objectAtIndex:row - 1];
        
    }
    HeMyMessageCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeMyMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    
    NSString *blogContent = dict[@"blogContent"];
    if (row != 0) {
        blogContent = dict[@"replyContent"];
        CGRect contentFrame = cell.contentLabel.frame;
        contentFrame.origin.x = 15;
        contentFrame.size.width = contentFrame.size.width + 10;
        cell.contentLabel.frame = contentFrame;
    }
    if ([blogContent isMemberOfClass:[NSNull class]] || blogContent == nil) {
        blogContent = @"";
    }
    CGFloat maxWith = SCREENWIDTH - 20;
    UIFont *textFont = [UIFont systemFontOfSize:18.0];
    CGSize nameSize = [MLLinkLabel getViewSizeByString:blogContent maxWidth:maxWith font:textFont lineHeight:TextLineHeight lines:0];
    CGFloat cellH = 30;
    if (nameSize.height > cellH) {
        cellH = nameSize.height;
    }
    CGRect contentFrame = cell.contentLabel.frame;
    contentFrame.size.height = cellH;
    cell.contentLabel.text = blogContent;
    cell.contentLabel.frame = contentFrame;
    
    NSString *hostHeader = dict[@"hostHeader"];
    if (row != 0) {
        hostHeader = dict[@"userHeader"];
    }
    if ([hostHeader isMemberOfClass:[NSNull class]]) {
        hostHeader = @"";
    }
    NSString *imageKey = [NSString stringWithFormat:@"%@_%@_%ld_%ld",hostHeader,dict[@"blogId"],row,section];
    UIImageView *userIcon = [imageCache objectForKey:imageKey];
    if (!userIcon) {
        NSString *imageUrl = hostHeader;
        if (![imageUrl hasPrefix:@"http"]) {
            imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,hostHeader];
        }
        cell.userIcon.tag = 100;
        [cell.userIcon sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userIcon = cell.userIcon;
        [imageCache setObject:userIcon forKey:imageKey];
    }
    [cell.userIcon removeFromSuperview];
    cell.userIcon = userIcon;
    [cell.contentView addSubview:userIcon];
    if (row != 0) {
        CGRect userIconFrame = cell.userIcon.frame;
        userIconFrame.size.height = 20;
        userIconFrame.size.width = 20;
        userIconFrame.origin.x = 15;
        cell.userIcon.frame = userIconFrame;
        cell.userIcon.layer.cornerRadius = userIconFrame.size.width / 2.0;
        cell.userIcon.layer.masksToBounds = YES;
    }
    
    NSString *userNick = dict[@"hostNick"];
    if (row != 0) {
//        userNick = dict[@"userNick"];
//        cell.tipLabel.text = nil;
//        CGRect tipFrame = cell.tipLabel.frame;
//        tipFrame.origin.x = tipFrame.origin.x + 10;
//        cell.tipLabel.frame = tipFrame;
//        
//        NSString *tipString = @"我回复";
//        NSString *subString = @"我";
//        NSMutableAttributedString *hintString = [[NSMutableAttributedString alloc]initWithString:tipString];
//        //获取要调整颜色的文字位置,调整颜色
//        NSRange range1 = [[hintString string]rangeOfString:subString];
//        [hintString addAttribute:NSForegroundColorAttributeName value:APPDEFAULTORANGE range:range1];
//        cell.tipLabel.attributedText = hintString;
//        
//        CGRect userNameFrame = cell.userNameLabel.frame;
//        userNameFrame.origin.x = userNameFrame.origin.x + 10;
//        userNameFrame.size.width = userNameFrame.size.width - 10;
//        cell.userNameLabel.frame = userNameFrame;
    }
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.userNameLabel.text = userNick;
    
    id blogTimeObj = [dict objectForKey:@"blogTime"];
    if (row != 0) {
        blogTimeObj = dict[@"replyTime"];
    }
    
    if ([blogTimeObj isMemberOfClass:[NSNull class]] || blogTimeObj == nil) {
        NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
        blogTimeObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
    }
    long long timestamp = [blogTimeObj longLongValue];
    NSString *blogTime = [NSString stringWithFormat:@"%lld",timestamp];
    if ([blogTime length] > 3) {
        //时间戳
        blogTime = [blogTime substringToIndex:[blogTime length] - 3];
    }
    
    NSString *blogtimeStr = [Tool convertTimespToString:[blogTime longLongValue] dateFormate:@"yyyy-MM-dd"];
    
    cell.timeLabel.text = blogtimeStr;
    
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *blogHost = dict[@"blogHost"];
    if ([blogHost isMemberOfClass:[NSNull class]]) {
        blogHost = @"";
    }
    if (row == 0) {
        if (![myUserId isEqualToString:blogHost]) {
            //如果是别人留言给用户
//            NSString *hostNick = dict[@"hostNick"];
//            if ([hostNick isMemberOfClass:[NSNull class]] || hostNick == nil) {
//                hostNick = @"";
//            }
//            cell.userNameLabel.text = hostNick;
//            
//            cell.tipLabel.hidden = YES;
//            CGRect userNameFrame = cell.userNameLabel.frame;
//            userNameFrame.origin.x = 10;
//            cell.userNameLabel.frame = userNameFrame;
            cell.replyLabel.hidden = NO;
        }
        else{
            cell.replyLabel.hidden = YES;
        }
    }
    else{
        blogHost = dict[@"replyHost"];
        if (![myUserId isEqualToString:blogHost]){
            cell.replyLabel.hidden = NO;
        }
        else{
            cell.replyLabel.hidden = YES;
        }
    }
    
    cell.messageDict = [[NSDictionary alloc] initWithDictionary:dict];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:section];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    
    NSString *blogContent = dict[@"blogContent"];
    if ([blogContent isMemberOfClass:[NSNull class]] || blogContent == nil) {
        blogContent = @"";
    }
    CGFloat maxWith = SCREENWIDTH - 20;
    UIFont *textFont = [UIFont systemFontOfSize:18.0];
    CGSize nameSize = [MLLinkLabel getViewSizeByString:blogContent maxWidth:maxWith font:textFont lineHeight:TextLineHeight lines:0];
    CGFloat cellH = 30;
    if (nameSize.height > cellH) {
        cellH = nameSize.height;
    }
    
    return cellH + 40;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:section];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    NSString *blogId = dict[@"blogId"];
    if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
        blogId = @"";
    }
    NSArray *replyArray = [replyDict objectForKey:@"blogId"];
    if (replyArray && [replyArray count] > 0) {
        
    }
        
    if (row == 0) {
        [self showTableWithBlogId:blogId];
    }
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
