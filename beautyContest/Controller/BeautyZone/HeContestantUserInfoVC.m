//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestantUserInfoVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "MLLinkLabel.h"
#import "HeCommentView.h"
#import "MJPhotoBrowser.h"
#import "FTPopOverMenu.h"
#import "HeComplaintVC.h"
#import "HeComplaintUserVC.h"
#import "HeNewUserInfoVC.h"
#import "HeRecommendMessageVC.h"

#define TextLineHeight 1.2f
#define BGTAG 100
#define SEXTAG 200
#define VOTETAG 300
#define VOTETAGSUCCESS 301
#define MESSAGETAG 400
#define FOLLOWTAG 500

@interface HeContestantUserInfoVC ()<UITableViewDelegate,UITableViewDataSource,CommentProtocol>
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
@property(strong,nonatomic)NSMutableArray *contestantImageDetailArray;
@property(strong,nonatomic)UIScrollView *myScrollView;

@end

@implementation HeContestantUserInfoVC
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
@synthesize contestantImageDetailArray;
@synthesize myScrollView;
@synthesize userId;

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
        label.text = @"用户详情";
        [label sizeToFit];
        
        self.title = @"用户详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self getContestantDetail];
    [self getContestantHaveVote];
    [self getPaperWall];
    [self getUserPic];
}

- (void)initializaiton
{
    [super initializaiton];
    contestantImageArray = [[NSMutableArray alloc] initWithCapacity:0];
    contestantImageDetailArray = [[NSMutableArray alloc] initWithCapacity:0];
    imageScrollViewHeigh = 80;
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
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
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_can_change_bg_09.jpg"]];
    
    bgImage.tag = BGTAG;
    bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
    bgImage.layer.masksToBounds = YES;
    bgImage.layer.cornerRadius = 5.0;
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat detailImageW = 50;
    CGFloat detailImageH = 50;
    CGFloat detailImageX = (imageW - detailImageW) / 2.0;
    CGFloat detailImageY = (imageH - detailImageH) / 2.0 - 20;
    
    detailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
    detailImage.layer.borderWidth = 1.0;
    detailImage.layer.borderColor = [UIColor whiteColor].CGColor;
    detailImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
    detailImage.layer.cornerRadius = detailImageW / 2.0;
    detailImage.layer.masksToBounds = YES;
    detailImage.contentMode = UIViewContentModeScaleAspectFill;
    [bgImage addSubview:detailImage];
    
    CGFloat buttonW = 50;
    CGFloat buttonH = 20;
    CGFloat buttonX = CGRectGetMaxX(detailImage.frame) + 5;
    CGFloat buttonY = detailImageY + (detailImageH - buttonH) / 2.0;
    
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
    
    CGFloat titleX = 10;
    CGFloat titleH = 25;
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
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:15.0];
    nameLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [bgImage addSubview:nameLabel];
    
    
    CGFloat iconX = CGRectGetMaxX(nameLabel.frame) + 5;
    CGFloat iconW = 20;
    CGFloat iconH = 20;
    CGFloat iconY = titleY + 5;
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_sex_boy"]];
    icon.tag = SEXTAG;
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [bgImage addSubview:icon];
    
//    return;
//    userNoLabel = [[UILabel alloc] init];
//    userNoLabel.textAlignment = NSTextAlignmentLeft;
//    userNoLabel.backgroundColor = [UIColor clearColor];
//    userNoLabel.text = @"选美号:10086";
//    userNoLabel.numberOfLines = 1;
//    userNoLabel.textColor = [UIColor whiteColor];
//    userNoLabel.font = [UIFont systemFontOfSize:13.0];
//    userNoLabel.frame = CGRectMake(iconX + iconW + 5, iconY, 100, iconH);
//    [bgImage addSubview:userNoLabel];
//    
//    CGFloat tiptitleX = (imageW - 2 *titleX) / 2.0;
//    CGFloat tiptitleH = detailImageH / 2.0;
//    CGFloat tiptitleY = detailImageY;
//    CGFloat tiptitleW = (imageW - 2 *titleX) / 2.0 - detailImageW - titleX;
//    
//    supportNumLabel = [[UILabel alloc] init];
//    supportNumLabel.textAlignment = NSTextAlignmentRight;
//    supportNumLabel.backgroundColor = [UIColor clearColor];
//    supportNumLabel.text = @"票数:62";
//    supportNumLabel.numberOfLines = 1;
//    supportNumLabel.textColor = [UIColor whiteColor];
//    supportNumLabel.font = [UIFont systemFontOfSize:11.0];
//    supportNumLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
//    [bgImage addSubview:supportNumLabel];
//    
//    CGFloat userRankX = (imageW - 2 *titleX) / 2.0;
//    CGFloat userRankH = detailImageH / 2.0;
//    CGFloat userRankY = CGRectGetMaxY(supportNumLabel.frame);
//    CGFloat userRankW = (imageW - 2 *titleX) / 2.0 - detailImageW - titleX;
//    
//    userRankLabel = [[UILabel alloc] init];
//    userRankLabel.textAlignment = NSTextAlignmentRight;
//    userRankLabel.backgroundColor = [UIColor clearColor];
//    userRankLabel.text = @"排名:第一名";
//    userRankLabel.numberOfLines = 1;
//    userRankLabel.textColor = [UIColor whiteColor];
//    userRankLabel.font = [UIFont systemFontOfSize:11.0];
//    userRankLabel.frame = CGRectMake(userRankX, userRankY, userRankW, userRankH);
//    [bgImage addSubview:userRankLabel];
    
    
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
    [voteButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor colorWithRed:252.0 / 255.0 green:168.0 / 255.0 blue:46.0 / 255.0 alpha:1.0] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:voteButton];
    
    UIButton *commentButton = [Tool getButton:CGRectMake(SCREENWIDTH / 2.0 + buttonX, buttonY, buttonW, buttonH) title:@"留言" image:@"icon_comment"];
    joinButton.tag = 2;
    [commentButton addTarget:self action:@selector(massageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
//    NSString *userId = contestantBaseDict[@"userId"];
//    if ([userId isMemberOfClass:[NSNull class]]) {
//        userId = @"";
//    }
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
    NSString *messageUserId = contestantBaseDict[@"userId"];
    if (!messageUserId) {
        messageUserId = @"";
    }
    HeRecommendMessageVC *recommendMessageVC = [[HeRecommendMessageVC alloc] init];
    recommendMessageVC.userId = messageUserId;
    recommendMessageVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:recommendMessageVC animated:YES];
    //    HeCommentView *commentView = [[HeCommentView alloc] init];
    //    commentView.commentDelegate = self;
    //    [self presentViewController:commentView animated:YES completion:nil];
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
    NSString *contestantUserId = userId;
    
    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/user/getUserinfo.action",BASEURL];
    if (zoneId == nil) {
        
    }
    NSDictionary *params = @{@"zoneId":zoneId,@"userId":contestantUserId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSDictionary *jsonDict = [respondDict objectForKey:@"json"];
            contestantDetailDict = [[NSDictionary alloc] initWithDictionary:jsonDict];
            contestantBaseDict = [[NSDictionary alloc] initWithDictionary:jsonDict];
            NSString *userNick = [contestantDetailDict objectForKey:@"userNick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            
            CGSize nameSize = [MLLinkLabel getViewSizeByString:userNick maxWidth:200 font:nameLabel.font lineHeight:TextLineHeight lines:0];
            CGRect nameFrame = nameLabel.frame;
            CGFloat titleY = nameFrame.origin.y;
            CGFloat titleH = nameFrame.size.height;
            CGFloat titleW = nameSize.width;
            CGFloat titleX = (nameLabel.superview.frame.size.width - titleW) / 2.0;
            nameLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
            nameLabel.textColor = [UIColor whiteColor];
            nameLabel.text = userNick;
            
            id sexObj = [contestantDetailDict objectForKey:@"userSex"];
            NSInteger userSex = [sexObj integerValue];
            if (userSex == 1) {
                UIImageView *sexIcon = [[sectionHeaderView viewWithTag:BGTAG] viewWithTag:SEXTAG];
                sexIcon.image = [UIImage imageNamed:@"icon_sex_boy"];
                
                CGRect sexFrame = sexIcon.frame;
                sexFrame.origin.x = titleX + titleW + 5;
                sexIcon.frame = sexFrame;
            }
            else{
                UIImageView *sexIcon = [[sectionHeaderView viewWithTag:BGTAG] viewWithTag:SEXTAG];
                sexIcon.image = [UIImage imageNamed:@"icon_sex_girl"];
                
                CGRect sexFrame = sexIcon.frame;
                sexFrame.origin.x = titleX + titleW + 5;
                sexIcon.frame = sexFrame;
            }
            
            
            NSString *userNo = [NSString stringWithFormat:@"%@",contestantDetailDict[@"userDisplayid"]];
            userNoLabel.text = userNo;
            
            NSString *userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,contestantDetailDict[@"userHeader"]];
            if (![userHeader hasPrefix:@"http"]) {
                userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
            }
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
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)getUserPic
{
    NSString *contestantUserId = userId;
    if ([contestantUserId isMemberOfClass:[NSNull class]] || contestantUserId == nil) {
        contestantUserId = @"";
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/paperWall/GetUserPic.action",BASEURL];
    NSDictionary *params = @{@"userId":contestantUserId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,jsonObj];
            UIImageView *imageView = [sectionHeaderView viewWithTag:BGTAG];
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"home_can_change_bg_09.jpg"]];
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
    
//    [self showHudInView:self.view hint:@"加载中..."];
    
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
    
//    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/havedVote.action",BASEURL];
    NSDictionary *params = @{@"voteHost":voteHost,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            if ([jsonObj boolValue]) {
                haveNOVoted = NO;
            }
            else{
                haveNOVoted = YES;
            }
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
    NSString *contestantUserId = userId;
    if ([contestantUserId isMemberOfClass:[NSNull class]] || contestantUserId == nil) {
        contestantUserId = @"";
    }
    
//    [self showHudInView:self.view hint:@"加载中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/paperWall/selectPaperWall.action",BASEURL];
    NSDictionary *params = @{@"userId":contestantUserId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            id jsonObj = [respondDict objectForKey:@"json"];
            NSMutableArray *wallArray = [[NSMutableArray alloc] initWithCapacity:0];
            [contestantImageDetailArray removeAllObjects];
            [contestantImageArray removeAllObjects];
            for (NSDictionary *dict in jsonObj) {
                NSString *wallUrl = dict[@"wallUrl"];
                if ([wallUrl isMemberOfClass:[NSNull class]]) {
                    wallUrl = @"";
                }
                [wallArray addObject:wallUrl];
                [contestantImageDetailArray addObject:dict];
            }
            
            NSArray *subviewArray = myScrollView.subviews;
            for (UIView *subview in subviewArray) {
                [subview removeFromSuperview];
            }
            [contestantImageArray removeAllObjects];
            CGFloat imageDistance = 5;
            CGFloat imageDistanceY = 5;
            CGFloat imageX = 0;
            CGFloat imageY = 0;
            CGFloat imageW = (myScrollView.frame.size.width - 2 * imageDistance) / 3.0;
            CGFloat imageH = imageW;
            
            
            NSInteger index = 0;
            CGFloat contentHeight = 0;
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
                
                contentHeight = CGRectGetMaxY(imageview.frame);
                
                index++;
                
                imageX = imageX + imageW + imageDistance;
                if (index % 3 == 0) {
                    imageX = 0;
                    
                }
                NSInteger column = index / 3.0;
                
                imageY = column * (imageH + imageDistanceY);
                
                imageview.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
                tapGes.numberOfTapsRequired = 1;
                tapGes.numberOfTouchesRequired = 1;
                [imageview addGestureRecognizer:tapGes];
                
            }
            CGRect scrollViewFrame = myScrollView.frame;
            scrollViewFrame.size.height = contentHeight;
            myScrollView.frame = scrollViewFrame;
            myScrollView.contentSize = CGSizeMake(0, contentHeight);
            [tableview reloadData];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [tableview reloadData];
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
    NSString *contestantUserId = contestantBaseDict[@"userId"];
    if ([contestantUserId isMemberOfClass:[NSNull class]] || contestantUserId == nil) {
        contestantUserId = @"";
    }
    
    [self showHudInView:self.view hint:@"关注中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/user/follow.action",BASEURL];
    NSDictionary *params = @{@"userId":contestantUserId,@"hostId":hostId};
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
        [self showHint:@"您已投票"];
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
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/GodVoteUser.action",BASEURL];
    NSDictionary *params = @{@"voteHost":voteHost,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            haveNOVoted = NO;
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
                    return myScrollView.frame.size.height + 2 * myScrollView.frame.origin.y;
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
    if (section == 0 && row == 0) {
        
        HeNewUserInfoVC *userInfoVC = [[HeNewUserInfoVC alloc] init];
        userInfoVC.hidesBottomBarWhenPushed = YES;
        userInfoVC.isScanUser = YES;
        userInfoVC.userInfo = [[User alloc] initUserWithDict:contestantDetailDict];
        [self.navigationController pushViewController:userInfoVC animated:YES];
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
