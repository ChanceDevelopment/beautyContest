//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestantDetailVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "MLLinkLabel.h"
#import "HeCommentView.h"
#import "MJPhotoBrowser.h"
#import "FTPopOverMenu.h"
#import "HeComplaintVC.h"
#import "HeComplaintUserVC.h"

#define TextLineHeight 1.2f
#define BGTAG 100
#define SEXTAG 200
#define VOTETAG 300
#define VOTETAGSUCCESS 301
#define MESSAGETAG 400
#define FOLLOWTAG 500

@interface HeContestantDetailVC ()<UITableViewDelegate,UITableViewDataSource,CommentProtocol>
{
    BOOL requestReply; //是否已经完成
    NSInteger contestantRank; //排名
    NSInteger voteCount; //投票人数
    BOOL haveNOVoted; //用户是否对参赛者投票
    CGFloat imageScrollViewHeigh;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)IBOutlet UIView *footerView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UIButton *followButton;
@property(strong,nonatomic)UIImageView *detailImage;
@property(strong,nonatomic)UILabel *userNoLabel;
@property(strong,nonatomic)UILabel *userRankLabel;
@property(strong,nonatomic)UILabel *supportNumLabel;
@property(strong,nonatomic)NSDictionary *contestantDetailDict;
@property(strong,nonatomic)NSMutableArray *contestantImageArray;
@property(strong,nonatomic)NSMutableDictionary *contestantImageDict;
@property(strong,nonatomic)UIScrollView *myScrollView;

@end

@implementation HeContestantDetailVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize footerView;
@synthesize nameLabel;
@synthesize followButton;
@synthesize detailImage;
@synthesize userNoLabel;
@synthesize userRankLabel;
@synthesize supportNumLabel;
@synthesize contestantBaseDict;
@synthesize contestZoneDict;
@synthesize contestantDetailDict;
@synthesize contestantImageArray;
@synthesize contestantImageDict;
@synthesize myScrollView;

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
        label.text = @"参赛者详情";
        [label sizeToFit];
        
        self.title = @"参赛者详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self getContestantDetail];
    [self getContestantRank];
    [self getContestantVote];
    [self getContestantHaveVote];
    [self getPaperWall];
}

- (void)initializaiton
{
    [super initializaiton];
    contestantImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    contestantImageDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    imageScrollViewHeigh = 80;
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    UIButton *moreButton = [[UIButton alloc] init];
    [moreButton setTitle:@"投诉" forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(complaintAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.frame = CGRectMake(0, 0, 40, 25);
    [moreButton.titleLabel setFont:[UIFont systemFontOfSize:13.5]];
    
    UIBarButtonItem *complaintItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = complaintItem;
    
    CGFloat headerH = 200;
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerH)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    CGFloat imageX = 10;
    CGFloat imageY = 10;
    CGFloat imageW = SCREENWIDTH - 2 * imageX;
    CGFloat imageH = headerH - 2 * imageY;
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comonDefaultImage.jpg"]];
    NSString *zoneCover = [NSString stringWithFormat:@"%@",[contestZoneDict objectForKey:@"zoneCover"]];
    NSArray *zoneCoverArray = [zoneCover componentsSeparatedByString:@","];
    if (zoneCoverArray) {
        zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,zoneCoverArray[0]];
    }
    [bgImage sd_setImageWithURL:[NSURL URLWithString:zoneCover] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
    
    bgImage.tag = BGTAG;
    bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
    bgImage.layer.masksToBounds = YES;
    bgImage.layer.cornerRadius = 5.0;
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = 10;
    CGFloat titleH = 20;
    CGFloat titleY = imageH - titleH - 50;
    CGFloat titleW = (imageW - 2 *titleX) / 2.0;
    
    NSString *name = @"何栋明";
    
    CGSize nameSize = [MLLinkLabel getViewSizeByString:name maxWidth:200 font:textFont lineHeight:TextLineHeight lines:0];
    titleW = nameSize.width;
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = name;
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = APPDEFAULTORANGE;
    nameLabel.font = textFont;
    nameLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [bgImage addSubview:nameLabel];
    
    CGFloat buttonX = titleX + titleW + 10;
    CGFloat buttonY = titleY;
    CGFloat buttonW = 50;
    CGFloat buttonH = titleH;
    followButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [followButton setTitle:@"关注" forState:UIControlStateNormal];
    [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    followButton.layer.masksToBounds = YES;
    followButton.layer.cornerRadius = 3.0;
    followButton.layer.borderWidth = 1.0;
    [followButton.titleLabel setFont:textFont];
    [followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [followButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:followButton.frame.size] forState:UIControlStateNormal];
    [followButton.titleLabel setFont:[UIFont systemFontOfSize:11.0]];
    followButton.layer.borderColor = APPDEFAULTORANGE.CGColor;
    [bgImage addSubview:followButton];
    
    CGFloat detailImageW = 40;
    CGFloat detailImageH = 40;
    CGFloat detailImageX = imageW - detailImageW - titleX;
    CGFloat detailImageY = CGRectGetMinY(nameLabel.frame);
    
    detailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
    detailImage.layer.borderWidth = 1.0;
    detailImage.layer.borderColor = [UIColor whiteColor].CGColor;
    detailImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
    detailImage.layer.cornerRadius = detailImageW / 2.0;
    detailImage.layer.masksToBounds = YES;
    detailImage.contentMode = UIViewContentModeScaleAspectFill;
    [bgImage addSubview:detailImage];
    
    CGFloat iconX = titleX;
    CGFloat iconW = 20;
    CGFloat iconH = 20;
    CGFloat iconY = CGRectGetMaxY(nameLabel.frame) + 5;
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_sex_boy"]];
    icon.tag = SEXTAG;
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [bgImage addSubview:icon];
    
    userNoLabel = [[UILabel alloc] init];
    userNoLabel.textAlignment = NSTextAlignmentLeft;
    userNoLabel.backgroundColor = [UIColor clearColor];
    userNoLabel.text = @"选美号:10086";
    userNoLabel.numberOfLines = 1;
    userNoLabel.textColor = [UIColor whiteColor];
    userNoLabel.font = [UIFont systemFontOfSize:13.0];
    userNoLabel.frame = CGRectMake(iconX + iconW + 5, iconY, 100, iconH);
    [bgImage addSubview:userNoLabel];
    
    CGFloat tiptitleX = (imageW - 2 *titleX) / 2.0;
    CGFloat tiptitleH = detailImageH / 2.0;
    CGFloat tiptitleY = detailImageY;
    CGFloat tiptitleW = (imageW - 2 *titleX) / 2.0 - detailImageW - titleX;
    
    supportNumLabel = [[UILabel alloc] init];
    supportNumLabel.textAlignment = NSTextAlignmentRight;
    supportNumLabel.backgroundColor = [UIColor clearColor];
    supportNumLabel.text = @"票数:62";
    supportNumLabel.numberOfLines = 1;
    supportNumLabel.textColor = [UIColor whiteColor];
    supportNumLabel.font = [UIFont systemFontOfSize:13.0];
    supportNumLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
    [bgImage addSubview:supportNumLabel];
    
    CGFloat userRankX = (imageW - 2 *titleX) / 2.0;
    CGFloat userRankH = detailImageH / 2.0;
    CGFloat userRankY = CGRectGetMaxY(supportNumLabel.frame);
    CGFloat userRankW = (imageW - 2 *titleX) / 2.0 - detailImageW - titleX;
    
    userRankLabel = [[UILabel alloc] init];
    userRankLabel.textAlignment = NSTextAlignmentRight;
    userRankLabel.backgroundColor = [UIColor clearColor];
    userRankLabel.text = @"排名:第一名";
    userRankLabel.numberOfLines = 1;
    userRankLabel.textColor = [UIColor whiteColor];
    userRankLabel.font = [UIFont systemFontOfSize:13.0];
    userRankLabel.frame = CGRectMake(userRankX, userRankY, userRankW, userRankH);
    [bgImage addSubview:userRankLabel];
    
    
    buttonX = 10;
    buttonY = 5;
    buttonH = 40;
    buttonW = SCREENWIDTH / 2.0 - 2 * buttonX;
    
    UIButton *joinButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"投票" image:@"icon_love"];
    joinButton.tag = VOTETAG;
    [joinButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:joinButton];
    
    
    UIButton *voteButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"谢谢您" image:nil];
    voteButton.hidden = YES;
    voteButton.tag = VOTETAGSUCCESS;
    [voteButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [voteButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:voteButton];
    
    UIButton *commentButton = [Tool getButton:CGRectMake(SCREENWIDTH / 2.0 + buttonX, buttonY, buttonW, buttonH) title:@"留言" image:@"icon_comment"];
    joinButton.tag = 2;
    [commentButton addTarget:self action:@selector(massageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *userId = contestantBaseDict[@"userId"];
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = @"";
    }
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([myUserId isEqualToString:userId]) {
        [commentButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor grayColor] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
        commentButton.enabled = NO;
    }
    else{
        [commentButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    }
    
    [footerView addSubview:commentButton];
    
    
    joinButton.layer.cornerRadius = 3.0;
    joinButton.layer.masksToBounds = YES;
    
    commentButton.layer.cornerRadius = 3.0;
    commentButton.layer.masksToBounds = YES;
    
    CGFloat scrollX = 10;
    CGFloat scrollY = 5;
    CGFloat scrollW = SCREENWIDTH - 2 * scrollX;
    CGFloat scrollH = imageScrollViewHeigh;
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollX, scrollY, scrollW, scrollH)];
    
}

- (void)complaintAction:(id)sender
{
    NSString *userNick = [contestantDetailDict objectForKey:@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    
    HeComplaintUserVC *complaintVC = [[HeComplaintUserVC alloc] init];
    complaintVC.userNick = userNick;
    complaintVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:complaintVC animated:YES];
}

- (void)massageButtonClick:(UIButton *)button
{
    HeCommentView *commentView = [[HeCommentView alloc] init];
    commentView.commentDelegate = self;
    [self presentViewController:commentView animated:YES completion:nil];
}

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    NSString *blogHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *blogUser = contestantBaseDict[@"userId"];
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

- (void)getContestantDetail
{
    NSString *zoneId = contestZoneDict[@"zoneId"];
    if ([zoneId isMemberOfClass:[NSNull class]] || zoneId == nil) {
        zoneId = @"";
    }
    NSString *userId = contestantBaseDict[@"userId"];
    if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
        userId = @"";
    }
    
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/zone/partInUserInfo.action",BASEURL];
    NSDictionary *params = @{@"zoneId":zoneId,@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSDictionary *jsonDict = [respondDict objectForKey:@"json"];
            contestantDetailDict = [[NSDictionary alloc] initWithDictionary:jsonDict];
            NSString *userNick = [contestantDetailDict objectForKey:@"userNick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.text = userNick;
            
            id sexObj = [contestantDetailDict objectForKey:@"userSex"];
            NSInteger userSex = [sexObj integerValue];
            if (userSex == 1) {
                UIImageView *sexIcon = [[sectionHeaderView viewWithTag:BGTAG] viewWithTag:SEXTAG];
                sexIcon.image = [UIImage imageNamed:@"icon_sex_boy"];
            }
            else{
                UIImageView *sexIcon = [[sectionHeaderView viewWithTag:BGTAG] viewWithTag:SEXTAG];
                sexIcon.image = [UIImage imageNamed:@"icon_sex_girl"];
            }
            NSString *userNo = [NSString stringWithFormat:@"%@",contestantDetailDict[@"userDisplayid"]];
            userNoLabel.text = userNo;
            
            NSString *userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,contestantDetailDict[@"userHeader"]];
            [detailImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
            
            [tableview reloadData];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
//            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}
//排名
- (void)getContestantRank
{
    NSString *voteZone = contestZoneDict[@"zoneId"];
    if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
        voteZone = @"";
    }
    NSString *voteUser = contestantBaseDict[@"userId"];
    if ([voteUser isMemberOfClass:[NSNull class]] || voteUser == nil) {
        voteUser = @"";
    }
    
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/getMyZoneRank.action",BASEURL];
    NSDictionary *params = @{@"voteZone":voteZone,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            contestantRank = [jsonObj integerValue];
            userRankLabel.text = [NSString stringWithFormat:@"排名:第%ld名",contestantRank];
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
//投票人
- (void)getContestantVote
{
    NSString *voteZone = contestZoneDict[@"zoneId"];
    if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
        voteZone = @"";
    }
    NSString *voteUser = contestantBaseDict[@"userId"];
    if ([voteUser isMemberOfClass:[NSNull class]] || voteUser == nil) {
        voteUser = @"";
    }
    
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/selectVoteCount.action",BASEURL];
    NSDictionary *params = @{@"voteZone":voteZone,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            voteCount = [jsonObj integerValue];
            supportNumLabel.text = [NSString stringWithFormat:@"票数:%ld票",voteCount];
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
//是否参选
- (void)getContestantHaveVote
{
    NSString *voteHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([voteHost isMemberOfClass:[NSNull class]] || voteHost == nil) {
        voteHost = @"";
    }
    NSString *voteUser = contestantBaseDict[@"userId"];
    if ([voteUser isMemberOfClass:[NSNull class]] || voteUser == nil) {
        voteUser = @"";
    }
    
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/havedVote.action",BASEURL];
    NSDictionary *params = @{@"voteHost":voteHost,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            haveNOVoted = [jsonObj boolValue];
            if (!haveNOVoted) {
                UIButton *button = [footerView viewWithTag:VOTETAG];
                button.hidden = YES;
                button = [footerView viewWithTag:VOTETAGSUCCESS];
                button.hidden = NO;
            }
            else{
                UIButton *button = [footerView viewWithTag:VOTETAG];
                button.hidden = NO;
                button = [footerView viewWithTag:VOTETAGSUCCESS];
                button.hidden = YES;
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
//获取照片墙
- (void)getPaperWall
{
    NSString *userId = contestantBaseDict[@"userId"];
    if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
        userId = @"";
    }
    
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/paperWall/selectPaperWall.action",BASEURL];
    NSDictionary *params = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            contestantImageDict = [[NSMutableDictionary alloc] initWithDictionary:jsonObj];
            NSString *wallUrl = [contestantImageDict objectForKey:@"wallUrl"];
            NSArray *wallArray = [wallUrl componentsSeparatedByString:@","];
            
            NSArray *subviewArray = myScrollView.subviews;
            for (UIView *subview in subviewArray) {
                [subview removeFromSuperview];
            }
            [contestantImageArray removeAllObjects];
            CGFloat imageX = 0;
            CGFloat imageY = 0;
            CGFloat imageH = myScrollView.frame.size.height;
            CGFloat imageW = imageH;
            CGFloat imageDistance = 5;
            NSInteger index = 0;
            for (NSString *url in wallArray) {
                NSString *imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
                [contestantImageArray addObject:imageurl];
                
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
                imageview.layer.masksToBounds = YES;
                imageview.layer.cornerRadius = 5.0;
                imageview.tag = index + 10000;
                imageview.contentMode = UIViewContentModeScaleAspectFill;
                [imageview sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
                [myScrollView addSubview:imageview];
                imageX = imageX + imageW + imageDistance;
                
                imageview.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
                tapGes.numberOfTapsRequired = 1;
                tapGes.numberOfTouchesRequired = 1;
                [imageview addGestureRecognizer:tapGes];
                
                index++;
            }
            if (imageX > myScrollView.frame.size.width) {
                myScrollView.contentSize = CGSizeMake(imageX, 0);
            }
            [tableview reloadData];
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

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
    NSInteger index = 0;
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *url in contestantImageArray) {
        NSString *imageurl = url;
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageurl];
        
        UIImageView *srcImageView = [myScrollView viewWithTag:index + 10000];
        photo.image = srcImageView.image;
        photo.srcImageView = srcImageView;
        [photos addObject:photo];
        index++;
    }
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = tap.view.tag - 10000;
    browser.photos = photos;
    [browser show];
}

- (void)followButtonClick:(UIButton *)button
{
    if (followButton.selected) {
        [self showHint:@"已关注"];
        return;
    }
    NSString *hostId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([hostId isMemberOfClass:[NSNull class]] || hostId == nil) {
        hostId = @"";
    }
    NSString *userId = contestantBaseDict[@"userId"];
    if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
        userId = @"";
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
            [followButton setTitle:@"已关注" forState:UIControlStateNormal];
            followButton.selected = YES;
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
//
- (void)buttonClick:(UIButton *)button
{
    NSLog(@"button = %@",button);
    if (!haveNOVoted) {
        return;
    }
    NSString *voteHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([voteHost isMemberOfClass:[NSNull class]] || voteHost == nil) {
        voteHost = @"";
    }
    NSString *voteUser = contestantBaseDict[@"userId"];
    if ([voteUser isMemberOfClass:[NSNull class]] || voteUser == nil) {
        voteUser = @"";
    }
    NSString *voteZone = contestZoneDict[@"zoneId"];
    if ([voteZone isMemberOfClass:[NSNull class]] || voteZone == nil) {
        voteZone = @"";
    }
    [self showHudInView:self.view hint:@"投票中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/voteUser.action",BASEURL];
    NSDictionary *params = @{@"voteHost":voteHost,@"voteUser":voteUser,@"voteZone":voteZone};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [self showHint:@"投票成功"];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
        {
            if ([contestantImageArray count] == 0) {
                return 1;
            }
            return 2;
            break;
        }
        default:
            break;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeContestantDetailIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        
    }
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    switch (section) {
        case 0:
        {
            cell.textLabel.text = @"个人信息";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.textColor = APPDEFAULTORANGE;
            
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellSize.width - 110, 0, 100, cellSize.height)];
            tipLabel.text = @"发布人可见";
            tipLabel.textColor = [UIColor grayColor];
            tipLabel.textAlignment = NSTextAlignmentRight;
            tipLabel.font = textFont;
            [cell addSubview:tipLabel];
            break;
        }
        case 1:
        {
            switch (row) {
                case 0:
                {
                    NSString *userSign = contestantDetailDict[@"userSign"];
                    if ([userSign isMemberOfClass:[NSNull class]] || userSign == nil) {
                        userSign = @"暂无签名";
                    }
                    cell.textLabel.text = userSign;
                    cell.textLabel.font = textFont;
                    cell.textLabel.textColor = [UIColor grayColor];
                    break;
                }
                case 1:{
                    [cell addSubview:myScrollView];
//                    CGFloat imageNum = 3;
//                    CGFloat imageDistance = 10;
//                    CGFloat imageX = 10;
//                    CGFloat imageY = 10;
//                    CGFloat imageH = cellSize.height - 2 * imageY;
//                    CGFloat imageW = (cellSize.width - 2 * imageX - 20 - (imageNum - 1) * imageDistance) / imageNum;
//                    for (NSInteger index = 0; index < imageNum; index++) {
//                        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index3.jpg"]];
//                        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
//                        imageView.contentMode = UIViewContentModeScaleAspectFill;
//                        imageView.layer.masksToBounds = YES;
//                        imageX = imageX + imageW + imageDistance;
//                        [cell addSubview:imageView];
//                    }
//                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
//                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                }
                default:
                    break;
            }
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
    switch (section) {
        case 1:
        {
            switch (row) {
                case 1:
                {
                    return imageScrollViewHeigh + 2 * myScrollView.frame.origin.y;
                    break;
                }
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
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
