//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestDetailVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestRankVC.h"
#import "HeBaseIconTitleTableCell.h"

#define TextLineHeight 1.2f

@interface HeContestDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
    NSInteger myRank;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSDictionary *contestDetailDict;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)IBOutlet UIView *footerView;
@property(strong,nonatomic)NSMutableArray *topManRank; //排名前面的男神
@property(strong,nonatomic)NSMutableArray *topWomanRank; //排名前面的女神

@end

@implementation HeContestDetailVC
@synthesize contestBaseDict;
@synthesize contestDetailDict;
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize iconDataSource;
@synthesize footerView;
@synthesize topManRank;
@synthesize topWomanRank;

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
        label.text = @"赛区详情";
        [label sizeToFit];
        
        self.title = @"赛区详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self getContestDetail];
    [self getMyRank];
    [self getManTopRank];
    [self getWomanRank];
}

- (void)initializaiton
{
    [super initializaiton];
    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward",@""];
    myRank = 0;
    topManRank = [[NSMutableArray alloc] initWithCapacity:0];
    topWomanRank = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index2.jpg"]];
    bgImage.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    distributeItem.target = self;
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    CGFloat buttonX = 10;
    CGFloat buttonY = 5;
    CGFloat buttonH = 40;
    CGFloat buttonW = SCREENWIDTH / 2.0 - 2 * buttonX;
    UIButton *joinButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"参加" image:@"appIcon"];
    joinButton.tag = 1;
    [joinButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:joinButton];
    
    UIButton *commentButton = [Tool getButton:CGRectMake(SCREENWIDTH / 2.0 + buttonX, buttonY, buttonW, buttonH) title:@"评论" image:@"icon_comment"];
    joinButton.tag = 2;
    [commentButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:commentButton];
}

- (void)buttonClick:(UIButton *)button
{

}

- (void)shareButtonClick:(UIButton *)shareButton
{

}

- (void)getContestDetail
{
    NSString *zoneId = contestBaseDict[@"zoneId"];
    if ([zoneId isMemberOfClass:[NSNull class]] || zoneId == nil) {
        zoneId = @"";
    }
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/zone/getZoneInfo.action",BASEURL];
    NSDictionary *params = @{@"zoneId":zoneId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSDictionary *jsonDict = [respondDict objectForKey:@"json"];
            contestDetailDict = [[NSDictionary alloc] initWithDictionary:jsonDict];
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

- (void)getMyRank
{
    NSString *voteZone = contestBaseDict[@"zoneId"];
    if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
        voteZone = @"";
    }
    NSString *voteUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!voteUser) {
        voteUser = @"";
    }
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/getMyZoneRank.action",BASEURL];
    NSDictionary *params = @{@"voteZone":voteZone,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            myRank = [jsonObj integerValue];
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

- (void)getManTopRank
{
    NSString *voteZone = contestBaseDict[@"zoneId"];
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
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
//            [self showHint:data];
        }
    } failure:^(NSError *error){
//        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)getWomanRank
{
    NSString *voteZone = contestBaseDict[@"zoneId"];
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
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            //            [self showHint:data];
        }
    } failure:^(NSError *error){
        //        [self showHint:ERRORREQUESTTIP];
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [iconDataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeBaseIconTitleTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseIconTitleTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseIconTitleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.topicLabel.font = [UIFont  systemFontOfSize:16.0];
    cell.topicLabel.textColor = [UIColor grayColor];
    
    NSString *iconName = iconDataSource[row];
    cell.icon.image = [UIImage imageNamed:iconName];
    switch (row) {
        case 0:
        {
            cell.topicLabel.font = [UIFont  boldSystemFontOfSize:18.0];
            CGRect topFrame = cell.topicLabel.frame;
            topFrame.origin.x = 10;
            topFrame.size.width = SCREENWIDTH - 2 * topFrame.origin.x;
            cell.topicLabel.frame = topFrame;
            cell.topicLabel.textColor = [UIColor blackColor];
            
           
            NSString *zoneTitle = contestDetailDict[@"zoneTitle"];
            if ([zoneTitle isMemberOfClass:[NSNull class]] || zoneTitle == nil) {
                zoneTitle = @"";
            }
            cell.topicLabel.text = zoneTitle;
            break;
        }
        case 1:
        {
            id zoneCreatetimeObj = [contestDetailDict objectForKey:@"zoneCreatetime"];
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
            
            
            id zoneDeathlineObj = [contestDetailDict objectForKey:@"zoneDeathline"];
            if ([zoneDeathlineObj isMemberOfClass:[NSNull class]] || zoneDeathlineObj == nil) {
                NSTimeInterval  timeInterval = [[NSDate date] timeIntervalSince1970];
                zoneDeathlineObj = [NSString stringWithFormat:@"%.0f000",timeInterval];
            }
            long long zoneDeathlinetimestamp = [zoneDeathlineObj longLongValue];
            NSString *zoneDeathlinezoneCreatetime = [NSString stringWithFormat:@"%lld",zoneDeathlinetimestamp];
            if ([zoneDeathlinezoneCreatetime length] > 3) {
                //时间戳
                zoneDeathlinezoneCreatetime = [zoneDeathlinezoneCreatetime substringToIndex:[zoneDeathlinezoneCreatetime length] - 3];
            }
            
            
            NSString *time = [Tool convertTimespToString:[zoneCreatetime longLongValue] dateFormate:@"YYYY年MM月dd日 HH:mm"];
            
            NSString *endtime = [Tool convertTimespToString:[zoneDeathlinezoneCreatetime longLongValue] dateFormate:@"YYYY年MM月dd日 HH:mm"];
            cell.topicLabel.text = [NSString stringWithFormat:@"%@ - %@",time,endtime];
            break;
        }
        case 2:
        {
            NSString *zoneAddress = contestDetailDict[@"zoneAddress"];
            if ([zoneAddress isMemberOfClass:[NSNull class]] || zoneAddress == nil) {
                zoneAddress = @"";
            }
            
            cell.topicLabel.numberOfLines = 2;
            cell.topicLabel.text = zoneAddress;
            break;
        }
        case 3:
        {
            NSString *userNick = contestDetailDict[@"userNick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            cell.topicLabel.text = [NSString stringWithFormat:@"发布者: %@",userNick];
            break;
        }
        case 4:
        {
            id zoneRewardObj = contestDetailDict[@"zoneReward"];
            if ([zoneRewardObj isMemberOfClass:[NSNull class]] || zoneRewardObj == nil) {
                zoneRewardObj = @"";
            }
            float zoneReward = [zoneRewardObj floatValue];
            cell.topicLabel.text = [NSString stringWithFormat:@"奖金: %.2lf元",zoneReward];
            break;
        }
        case 5:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.topicLabel.text = @"我的排名";
            CGRect topFrame = cell.topicLabel.frame;
            topFrame.origin.x = 10;
            topFrame.size.width = SCREENWIDTH - 2 * topFrame.origin.x;
            cell.topicLabel.frame = topFrame;
            cell.topicLabel.textColor = [UIColor blackColor];
            
            UILabel *rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, SCREENWIDTH - 90, cellSize.height)];
            rankLabel.backgroundColor = [UIColor clearColor];
            rankLabel.textColor = [UIColor redColor];
            rankLabel.font = [UIFont systemFontOfSize:15.0];
            rankLabel.text = [NSString stringWithFormat:@"%ld",myRank];
            [cell addSubview:rankLabel];
            
            User *userInfo = [HeSysbsModel getSysModel].user;
            NSString *userHead = userInfo.userHeader;
            userHead = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHead];
            CGFloat imageY = 5;
            CGFloat imageH = cellSize.height - 2 * imageY;
            CGFloat imageW = imageH;
            CGFloat imageX = cellSize.width - imageW - 10;
            UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
            userIcon.image = [UIImage imageNamed:@"userDefalut_icon"];
            userIcon.layer.borderWidth = 1.0;
            userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
            userIcon.layer.masksToBounds = YES;
            userIcon.layer.cornerRadius = imageH / 2.0;
            userIcon.contentMode = UIViewContentModeScaleAspectFill;
            [userIcon sd_setImageWithURL:[NSURL URLWithString:userHead]];
            [cell addSubview:userIcon];
            break;
        }
        default:
            break;
    }
    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (row) {
        case 2:
        {
            NSString *zoneAddress = contestDetailDict[@"zoneAddress"];
            if ([zoneAddress isMemberOfClass:[NSNull class]] || zoneAddress == nil) {
                zoneAddress = @"";
            }
            CGFloat labelW = 0;
            UIFont *font = [UIFont  boldSystemFontOfSize:16.0];
            CGSize textSize = [MLLinkLabel getViewSizeByString:zoneAddress maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
            if (textSize.height < 50) {
                textSize.height = 50;
            }
            return textSize.height + 10;
            break;
        }
        default:
            break;
    }
    
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (row) {
        case 5:
        {
            HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
            contestRankVC.contestDict = [[NSDictionary alloc] initWithDictionary:contestDetailDict];
            contestRankVC.topManRank = [[NSMutableArray alloc] initWithArray:topManRank];
            contestRankVC.topWomanRank = [[NSMutableArray alloc] initWithArray:topWomanRank];
            contestRankVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestRankVC animated:YES];
            break;
        }
        default:
            break;
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
