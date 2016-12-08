//
//  HeNearbyVC.m
//  beautyContest
//
//  Created by Tony on 16/8/3.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeRecommendMessageVC.h"
#import "HeUserMessageCell.h"
#import "MLLabel+Size.h"
#import "HeCommentView.h"
#import "UIButton+Bootstrap.h"
#import "HeRecommendMessageCell.h"
#import "HeContestantDetailVC.h"
#import "HeNewUserInfoVC.h"

#define TextLineHeight 1.2f

@interface HeRecommendMessageVC ()<CommentProtocol,UITextFieldDelegate>
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
@property(strong,nonatomic)IBOutlet UIView *commentBGView;

@end

@implementation HeRecommendMessageVC
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
@synthesize userId;
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
        label.text = @"留言";
        [label sizeToFit];
        
        self.title = @"留言";
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
    pageNo = 1;
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
    
    UIBarButtonItem *messageItem = [[UIBarButtonItem alloc] init];
    messageItem.title = @"留言";
    messageItem.target = self;
    messageItem.action = @selector(leaveMessage:);
//    self.navigationItem.rightBarButtonItem = messageItem;
    
    CGFloat buttonW = 60;
    CGFloat buttonY = 8;
    CGFloat buttonH = 50 - 2 * buttonY;
    CGFloat buttonX = SCREENWIDTH - buttonW - 8;
    
    CGFloat commentX = 8;
    CGFloat commentY = 8;
    CGFloat commentH = 50 - 2 * buttonY;
    CGFloat commentW = SCREENWIDTH - 3 * commentX - buttonW;
    UITextField *commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(commentX, commentY, commentW, commentH)];
    commentBGView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    commentTextField.tag = 10000;
    commentTextField.backgroundColor = [UIColor whiteColor];
    commentTextField.font = [UIFont systemFontOfSize:15.0];
    commentTextField.delegate = self;
    commentTextField.layer.borderColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0].CGColor;
    commentTextField.layer.cornerRadius = 5.0;
    commentTextField.placeholder = @"请输入内容";
    commentTextField.layer.masksToBounds = YES;
    [commentBGView addSubview:commentTextField];
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [submitButton setTitle:@"提交" forState:UIControlStateNormal];
    [commentBGView addSubview:submitButton];
    [submitButton dangerStyle];
    [submitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:submitButton.frame.size] forState:UIControlStateNormal];
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitButtonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)submitButtonClick:(UIButton *)button
{
    UITextField *textField = [commentBGView viewWithTag:10000];
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    NSString *commentText = textField.text;
    if (commentText == nil || [commentText isEqualToString:@""]) {
        [self showHint:@"请输入评论内容"];
        return;
    }
    User *userInfo = [HeSysbsModel getSysModel].user;
    [self commentWithText:commentText user:userInfo];
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

- (void)leaveMessage:(UIBarButtonItem *)item
{
    HeCommentView *commentView = [[HeCommentView alloc] init];
    commentView.title = @"留言";
    commentView.commentDelegate = self;
    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    NSString *blogHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (blogHost == nil) {
        blogHost = @"";
    }
    NSString *blogUser = userId;
    NSString *blogContent = [NSString stringWithFormat:@"%@",commentText];
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
            UITextField *commentTextField = [commentBGView viewWithTag:10000];
            commentTextField.text = nil;//清空评论框
            
            [self showHint:data];
            updateOption = 1;
            [self loadUserMessageShow:YES];
//            [self getReplyWithBlogID:replyBlog];
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
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/getMyMessagesForPeople.action",BASEURL];
    NSString *OtherUserid = userId;
    NSString *blogUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!blogUser) {
        blogUser = @"";
    }
    NSNumber *pageNum = [NSNumber numberWithInteger:pageNo];
    NSDictionary *requestMessageParams = @{@"blogUser":blogUser,@"OtherUserid":OtherUserid};
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
            NSInteger index = 0;
            for (NSDictionary *zoneDict in resultArray) {
                [dataSource addObject:zoneDict];
//                NSString *blogId = [NSString stringWithFormat:@"%@",[zoneDict objectForKey:@"blogId"]];
//                [replyIndexDict setObject:[NSNumber numberWithInteger:index] forKey:blogId];
//                [replyShowDict setObject:[NSNumber numberWithBool:YES] forKey:blogId];
//                index++;
//                [self getReplyWithBlogID:blogId];
                
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

- (void)scanUserDetail:(UITapGestureRecognizer *)ges
{
    NSInteger row = ges.view.tag;
    NSDictionary *dict = nil;
    @try {
        dict = [dataSource objectAtIndex:row];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
    NSString *commentUser = dict[@"commentUser"];
    if ([commentUser isMemberOfClass:[NSNull class]] || !commentUser) {
        commentUser = @"";
    }
    NSString *userHeader = dict[@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]] || !userHeader) {
        userHeader = @"";
    }
    NSString *userNick = dict[@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || !userNick) {
        userNick = @"";
    }
    NSDictionary *userDict = @{@"userId":commentUser,@"userHeader":userHeader,@"userNick":userNick};
    HeNewUserInfoVC *userInfoVC = [[HeNewUserInfoVC alloc] init];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    userInfoVC.isScanUser = YES;
    userInfoVC.userInfo = [[User alloc] initUserWithDict:userDict];
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSDictionary *dict = dataSource[section];
//    NSString *blogId = dict[@"blogId"];
//    if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
//        blogId = @"";
//    }
//    BOOL show = [[replyShowDict objectForKey:blogId] boolValue];
//    if (show) {
//        NSArray *replyArray = [replyDict objectForKey:blogId];
//        return 1 + [replyArray count];
//    }
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
//    if (row != 0) {
//        NSString *blogId = dict[@"blogId"];
//        if ([blogId isMemberOfClass:[NSNull class]] || blogId == nil) {
//            blogId = @"";
//        }
//        NSArray *replyArray = [replyDict objectForKey:blogId];
//        dict = [replyArray objectAtIndex:row - 1];
//        
//    }
    HeRecommendMessageCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeRecommendMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
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
    CGRect contentFrame = cell.contentLabel.frame;
    contentFrame.size.height = cellH;
    cell.contentLabel.text = blogContent;
    cell.contentLabel.frame = contentFrame;
    
    NSString *userNick = dict[@"hostNick"];
    
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    cell.userNameLabel.text = userNick;
    
    id blogTimeObj = [dict objectForKey:@"blogTime"];
    
    
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
    
    NSString *blogtimeStr = [Tool convertTimespToString:[blogTime longLongValue] dateFormate:@"yyyy-MM-dd HH:mm"];
    
    cell.timeLabel.text = blogtimeStr;
    
    NSString *myUserId = userId;
    NSString *blogHost = dict[@"blogHost"];
    if ([blogHost isMemberOfClass:[NSNull class]]) {
        blogHost = @"";
    }
    
    NSString *userHeader = [dict objectForKey:@"hostHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]]) {
        userHeader = @"";
    }
    if (![userHeader hasPrefix:@"http"]) {
        userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    }
    
    UIImageView *imageview = [imageCache objectForKey:userHeader];
    if (!imageview) {
        [cell.userIcon sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
        imageview = cell.userIcon;
        
        cell.userIcon.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserDetail:)];
        tapGes.numberOfTapsRequired = 1;
        tapGes.numberOfTouchesRequired = 1;
        cell.userIcon.tag = row;
        [cell.userIcon addGestureRecognizer:tapGes];
    }
    
    cell.userIcon = imageview;
    [cell addSubview:cell.userIcon];
    
    cell.replyLabel.hidden = YES;
    cell.tipLabel.hidden = YES;
    
//    CGRect userNickFrame = cell.userNameLabel.frame;
//    userNickFrame.origin.x = 10;
//    cell.userNameLabel.frame = userNickFrame;
    
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
    return;
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
