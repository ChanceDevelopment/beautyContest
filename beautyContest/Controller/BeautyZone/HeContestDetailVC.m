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
#import "HeCommentView.h"
#import "HeContestZoneCommentVC.h"
#import "ZJSwitch.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKExtension/SSEShareHelper.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareActionSheetStyle.h>
#import <ShareSDKUI/SSUIShareActionSheetCustomItem.h>
#import <ShareSDK/ShareSDK+Base.h>
#import "HeUserLocatiVC.h"
#import "MJPhotoBrowser.h"
#import "FTPopOverMenu.h"
#import "UIButton+Bootstrap.h"
#import "MLLinkLabel.h"
#import "MLLabel+Size.h"
#import "HeComplaintVC.h"
#import "HeComplaintUserVC.h"

#define TextLineHeight 1.2f
#define BGTAG 100

@interface HeContestDetailVC ()<UITableViewDelegate,UITableViewDataSource,CommentProtocol,UIAlertViewDelegate>
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
@property(strong,nonatomic)NSMutableDictionary *switchDict;
@property(strong,nonatomic)UIScrollView *myScrollView;
@property(strong,nonatomic)NSMutableArray *bannerImageDataSource;

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
@synthesize switchDict;
@synthesize myScrollView;
@synthesize bannerImageDataSource;
@synthesize myzoneId;

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
    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"",@""];
    myRank = 0;
    topManRank = [[NSMutableArray alloc] initWithCapacity:0];
    topWomanRank = [[NSMutableArray alloc] initWithCapacity:0];
    switchDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    if (!contestBaseDict) {
        if (myzoneId) {
            contestBaseDict = @{@"zoneId":myzoneId};
        }
        
    }
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    CGFloat scale = 512 / 297.0;
    CGFloat headerHeight = SCREENWIDTH / scale;
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comonDefaultImage"]];
    bgImage.userInteractionEnabled = YES;
    bgImage.layer.masksToBounds = YES;
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.tag = BGTAG;
    bgImage.frame = CGRectMake(0, 0, SCREENWIDTH, headerHeight);
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeImage:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [bgImage addGestureRecognizer:tap];
    
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(moreItemClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
//    distributeItem.title = @"更多";
//    distributeItem.tintColor = [UIColor whiteColor];
//    distributeItem.target = self;
//    distributeItem.action = @selector(moreItemClick:);
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    CGFloat buttonX = 10;
    CGFloat buttonY = 5;
    CGFloat buttonH = 40;
    CGFloat buttonW = SCREENWIDTH / 2.0 - 2 * buttonX;
    UIButton *joinButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"参加" image:@"icon_join_in"];
    joinButton.tag = 1;
    [joinButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor colorWithRed:252.0 / 255.0 green:168.0 / 255.0 blue:46.0 / 255.0 alpha:1.0] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:joinButton];
    joinButton.layer.cornerRadius = 3.0;
    joinButton.layer.masksToBounds = YES;
    
//    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
//    NSString *userId = contestBaseDict[@"userId"];
//    if ([userId isMemberOfClass:[NSNull class]]) {
//        userId = @"";
//    }
    
    
    UIButton *commentButton = [Tool getButton:CGRectMake(SCREENWIDTH / 2.0 + buttonX, buttonY, buttonW, buttonH) title:@"评论" image:@"icon_comment"];
    joinButton.tag = 2;
    [commentButton addTarget:self action:@selector(massageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:commentButton];
    commentButton.layer.cornerRadius = 3.0;
    commentButton.layer.masksToBounds = YES;
    
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 300)];

}

- (void)moreItemClick:(id)sender
{
    NSArray *menuArray = @[@"分享",@"举报",@"屏蔽该发布人"];
    [FTPopOverMenu setTintColor:APPDEFAULTORANGE];
    [FTPopOverMenu showForSender:sender
                        withMenu:menuArray
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           switch (selectedIndex) {
                               case 0:
                               {
                                   [self shareButtonClick:nil];
                                   break;
                               }
                               case 1:
                               {
                                   //投诉
                                   HeComplaintVC *complaintVC = [[HeComplaintVC alloc] init];
                                   complaintVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:complaintVC animated:YES];
                                   break;
                               }
                               case 2:
                               {
                                   //屏蔽用户
                                   [self blockUserButtonClick];
                                   return;
                                   //投诉
                                   HeComplaintUserVC *complaintVC = [[HeComplaintUserVC alloc] init];
                                   complaintVC.userNick = contestDetailDict[@"userNick"];
                                   complaintVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:complaintVC animated:YES];
                                   break;
                               }
                               default:
                                   break;
                           }
                           
                           
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                       }];
}

//屏蔽用户
- (void)blockUserButtonClick
{
    NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = nil;
    }
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([userId isEqualToString:myUserId]) {
        [self showHint:@"不能屏蔽自己"];
        return;
    }
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"屏蔽该用户之后，他发布的内容将不会出现你的内容列表里面" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            NSLog(@"cancelAction");
        }];
        UIAlertAction *blockAction = [UIAlertAction actionWithTitle:@"屏蔽" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            NSString *userNick = contestDetailDict[@"userNick"];
            if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                userNick = @"";
            }
            NSDictionary *userDict = @{@"userId":userId,@"userNick":userNick};
            [self blockUserWithUser:userDict];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:blockAction];
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"屏蔽该用户之后，他发布的内容将不会出现你的内容列表里面" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"屏蔽", nil];
    alertview.tag = 200;
    [alertview show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 200) {
        switch (buttonIndex) {
            case 1:
            {
                NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
                if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                    userId = @"";
                }
                NSString *userNick = contestDetailDict[@"userNick"];
                if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
                    userNick = @"";
                }
                NSDictionary *userDict = @{@"userId":userId,@"userNick":userNick};
                [self blockUserWithUser:userDict];
                break;
            }
            default:
                break;
        }
    }
    else if (alertView.tag == 300 && buttonIndex == 1){
        [self sendTest];
    }
}

- (void)blockUserWithUser:(NSDictionary *)userDict
{
    NSLog(@"blockUser");
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSMutableArray *tmpArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSString *blockKey = [NSString stringWithFormat:@"%@_%@",BLOCKINGLIST,myUserId];
    NSArray *blockArray = [[NSUserDefaults standardUserDefaults] objectForKey:blockKey];
    if (blockArray != nil) {
        [tmpArray addObjectsFromArray:blockArray];
    }
    [tmpArray addObject:userDict];
    blockArray = [[NSArray alloc] initWithArray:tmpArray];
    [[NSUserDefaults standardUserDefaults] setObject:blockArray forKey:blockKey];
    NSNotification *notification = [NSNotification notificationWithName:@"blockUserSucceed" object:nil userInfo:userDict];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    [self showHint:@"成功屏蔽用户"];
}

- (void)enlargeImage:(UITapGestureRecognizer *)tap
{
    NSString *zoneCover = [NSString stringWithFormat:@"%@",[contestDetailDict objectForKey:@"zoneCover"]];
    NSArray *zoneCoverArray = [zoneCover componentsSeparatedByString:@","];
    if (zoneCoverArray) {
        zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,zoneCoverArray[0]];
    }
    
    UIImageView *srcImageView = (UIImageView *)tap.view;
    NSMutableArray *photos = [NSMutableArray array];
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    MJPhoto *photo = [[MJPhoto alloc] init];
    photo.url = [NSURL URLWithString:zoneCover];
    photo.image = srcImageView.image;
    photo.srcImageView = srcImageView;
    [photos addObject:photo];
    browser.photos = photos;
    [browser show];
}



- (void)massageButtonClick:(UIButton *)button
{
    BOOL zoneTeststate = [[switchDict objectForKey:@"4"] boolValue];
    if (zoneTeststate) {
        [self showHint:@"该赛区已禁止评论"];
        return;
    }
    HeContestZoneCommentVC *commentZoneVC = [[HeContestZoneCommentVC alloc] init];
    commentZoneVC.contestZoneDict = [[NSDictionary alloc] initWithDictionary:contestDetailDict];
    commentZoneVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:commentZoneVC animated:YES];
}


- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    NSLog(@"commentText = %@",commentText);
}

- (void)buttonClick:(UIButton *)button
{
    BOOL zoneTeststate = [[switchDict objectForKey:@"4"] boolValue];
    if (zoneTeststate) {
        if (ISIOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"该赛区需发布人验证才能参加" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                [self sendTest];
            }];
            [alertController addAction:cancelAction];
            [alertController addAction:sureAction];
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"该赛区需发布人验证才能参加" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        alertView.tag = 200;
        [alertView show];
        return;
    }
    NSString *partInUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([partInUser isMemberOfClass:[NSNull class]] || partInUser == nil) {
        partInUser = @"";
    }
    NSString *partInZone = contestDetailDict[@"zoneId"];
    if ([partInZone isMemberOfClass:[NSNull class]] || partInZone == nil) {
        partInZone = @"";
    }
    long long nowTime = [[NSDate date] timeIntervalSince1970];
    NSString *timeSting = [NSString stringWithFormat:@"%lld",nowTime];
    [self showHudInView:self.view hint:@"参加中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/zone/partInZone.action",BASEURL];
    NSDictionary *params = @{@"partInUser":partInUser,@"partInZone":partInZone,@"nowTime":timeSting};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [self showHint:@"成功参加"];
            [self getContestDetail];
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

//发出赛区验证消息
- (void)sendTest
{
    NSString *requestUrl = [NSString stringWithFormat:@"%@/zone/TestZone.action",BASEURL];
    NSString *testuserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([testuserId isMemberOfClass:[NSNull class]] || testuserId == nil) {
        testuserId = @"";
    }
    NSString *zoneuserId = contestDetailDict[@"zoneUser"];
    if ([zoneuserId isMemberOfClass:[NSNull class]] || zoneuserId == nil) {
        zoneuserId = @"";
    }
    NSString *testzoneId = contestDetailDict[@"zoneId"];
    if ([testzoneId isMemberOfClass:[NSNull class]] || testzoneId == nil) {
        testzoneId = @"";
    }
    NSDictionary *params = @{@"testuserId":testuserId,@"zoneuserId":zoneuserId,@"testzoneId":testzoneId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [self showHint:@"发送验证成功，请等待赛区验证"];
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

- (void)shareButtonClick:(UIButton *)shareButton
{
//    http://114.55.226.224:8088/xuanmei/shareZone.action?zoneId=92bcc5d6b58645d9be112d74c140723a&voteUser=73c69cf59b0e4f56badce7de300ac172
    NSString *domain = @"http://114.55.226.224:8088/xuanmei/shareZone.action?";
    NSString *zoneId = contestDetailDict[@"zoneId"];
    NSString *voteUser = contestDetailDict[@"zoneUser"];;
    NSString *shareUrl = [NSString stringWithFormat:@"%@zoneId=%@&voteUser=%@",domain,zoneId,voteUser];
    //    NSString *shareUrl = [columnDict objectForKey:@"url"];
    //    if ([shareUrl isMemberOfClass:[NSNull class]] || shareUrl == nil || [shareUrl isEqualToString:@""]) {
    //        shareUrl = [columnDict objectForKey:@"url_new"];
    //        if ([shareUrl isMemberOfClass:[NSNull class]] || shareUrl == nil || [shareUrl isEqualToString:@""]){
    //            shareUrl = @"http://modify.modiauto.com.cn/";
    //        }
    //
    //    }
    
    //    NSString *shareUrl = [columnDict objectForKey:@"url"];    //分享的链接地址
    //    if ([shareUrl isMemberOfClass:[NSNull class]] || shareUrl == nil) {
    //        shareUrl = @"";
    //    }
    NSString *shareContent = @"选美榜-颜值榜期待您的加入";
    
    NSString *shareTitleStr = @"选美榜-颜值榜";
    NSString *imagePath = nil;
    
    NSArray* imageArray = nil;
    if ([imagePath isMemberOfClass:[NSNull class]] || imagePath == nil || [imagePath isEqualToString:@""]) {
        imagePath =[[NSBundle mainBundle] pathForResource:@"appIcon"  ofType:@"png"];
    }
    imageArray = @[imagePath];
    
    
    NSArray *sharePlatFormArray = @[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline),@(SSDKPlatformSubTypeQQFriend),@(SSDKPlatformSubTypeQZone)];
    
    shareUrl = [shareUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    //1、创建分享参数（必要）
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:shareContent
                                     images:imageArray
                                        url:[NSURL URLWithString:shareUrl]
                                      title:shareTitleStr
                                       type:SSDKContentTypeWebPage];
    //2、分享
    [ShareSDK showShareActionSheet:nil
                             items:sharePlatFormArray
                       shareParams:shareParams
               onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                   switch (state) {
                           
                       case SSDKResponseStateBegin:
                       {
                           
                           break;
                       }
                       case SSDKResponseStateSuccess:
                       {
                           break;
                       }
                       case SSDKResponseStateFail:
                       {
                           if (platformType == SSDKPlatformTypeSMS && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、短信应用没有设置帐号；2、设备不支持短信应用；3、短信应用在iOS 7以上才能发送带附件的短信。"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else if(platformType == SSDKPlatformTypeMail && [error code] == 201)
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:@"失败原因可能是：1、邮件应用没有设置帐号；2、设备不支持邮件应用；"
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           else
                           {
                               break;
                           }
                           break;
                       }
                       case SSDKResponseStateCancel:
                       {
                           break;
                       }
                       default:
                           break;
                   }
                   
                   
               }];
}

- (void)zjSwitchChange:(ZJSwitch *)zjSwitch
{
    NSInteger tag = zjSwitch.tag;
    NSString *key = [NSString stringWithFormat:@"%ld",tag];
    NSNumber *number = [NSNumber numberWithBool:zjSwitch.on];
    NSDictionary *params = nil;
    NSString *requestUrl = nil;
    NSString *zoneId = contestBaseDict[@"zoneId"];
    if ([zoneId isMemberOfClass:[NSNull class]] || zoneId == nil) {
        zoneId = @"";
    }
    if (tag == 3) {
        requestUrl = [NSString stringWithFormat:@"%@/zone/limitComment.action",BASEURL];
        params = @{@"zoneId":zoneId,@"zoneComment":number};
    }
    else{
        requestUrl = [NSString stringWithFormat:@"%@/zone/updateTestState.action",BASEURL];
        params = @{@"zoneId":zoneId,@"testState":number};
    }
    
    [self showHudInView:self.view hint:@"修改中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            if (tag == 3) {
                [switchDict setObject:number forKey:@"3"];
            }
            else{
                [switchDict setObject:number forKey:@"4"];
            }
            
            id zoneTeststate = switchDict[@"4"];
            NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]]) {
                userId = nil;
            }
            
            if ([zoneTeststate boolValue]) {
                //如果赛区需要验证
                if ([myUserId isEqualToString:userId]) {
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"icon_pay_password",@"icon_glory",@""];
                }
                else{
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green"];
                }
            }
            else{
                if ([myUserId isEqualToString:userId]) {
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"icon_pay_password",@"icon_glory",@""];
                }
                else{
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"icon_glory",@""];
                }
            }
            
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

- (void)getContestDetail
{
    NSString *zoneId = contestBaseDict[@"zoneId"];
    if ([zoneId isMemberOfClass:[NSNull class]] || zoneId == nil) {
        zoneId = @"";
    }
    [self showHudInView:self.tableview hint:@"加载中..."];
    
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
            NSString *zoneCover = [NSString stringWithFormat:@"%@",[contestDetailDict objectForKey:@"zoneCover"]];
            NSArray *zoneCoverArray = [zoneCover componentsSeparatedByString:@","];
            if (zoneCoverArray) {
                zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,zoneCoverArray[0]];
            }
            [bannerImageDataSource removeAllObjects];
            if ([zoneCoverArray count] > 1) {
                for (NSInteger index = 1; index < [zoneCoverArray count]; index++) {
                    NSString *imageURL = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,zoneCoverArray[index]];
                    [bannerImageDataSource addObject:imageURL];
                }
            }
            UIImageView *imageview = [sectionHeaderView viewWithTag:BGTAG];
            [imageview sd_setImageWithURL:[NSURL URLWithString:zoneCover] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
            
            id zoneComment = contestDetailDict[@"zoneComment"];
            if ([zoneComment isMemberOfClass:[NSNull class]]) {
                zoneComment = @"";
            }
            id zoneTeststate = contestDetailDict[@"zoneTeststate"];
            if ([zoneTeststate isMemberOfClass:[NSNull class]]) {
                zoneTeststate = @"";
            }
            [switchDict setObject:[NSNumber numberWithBool:[zoneComment boolValue]] forKey:@"3"];
            [switchDict setObject:[NSNumber numberWithBool:[zoneTeststate boolValue]] forKey:@"4"];
            
            NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]]) {
                userId = nil;
            }
            NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            //1.赛区的需要验证时，不能评论，且不能访问排行榜以及奖金榜
            //2.赛区的不需要验证时，能评论，且能访问排行榜以及奖金榜
            if ([zoneTeststate boolValue]) {
                //如果赛区需要验证
                if ([myUserId isEqualToString:userId]) {
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"icon_pay_password",@"icon_glory",@""];
                }
                else{
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green"];
                }
            }
            else{
                if ([myUserId isEqualToString:userId]) {
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"icon_pay_password",@"icon_glory",@""];
                }
                else{
                    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_puter",@"icon_reward_green",@"icon_glory",@""];
                }
            }
            
            
            
            CGFloat imageX = 5;
            CGFloat imageY = 5;
            CGFloat imageH = 200 - 2 * imageY;
            CGFloat imageW = 150;
            for (NSInteger index = 0; index < [bannerImageDataSource count]; index++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:bannerImageDataSource[index]] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
                imageView.layer.cornerRadius = 5.0;
                imageView.tag = index + 10000;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                imageView.layer.masksToBounds = YES;
                [myScrollView addSubview:imageView];
                imageX = imageX + imageW + 5;
                
                imageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
                tapGes.numberOfTapsRequired = 1;
                tapGes.numberOfTouchesRequired = 1;
                [imageView addGestureRecognizer:tapGes];
                
            }
            myScrollView.contentSize = CGSizeMake(imageX, 0);
            if ([bannerImageDataSource count] > 0) {
                UIView *myfooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, myScrollView.frame.size.height)];
                myfooterView.backgroundColor = [UIColor whiteColor];
                [myfooterView addSubview:myScrollView];
                
                tableview.tableFooterView = myfooterView;
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
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
    NSInteger index = 0;
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *url in bannerImageDataSource) {
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
//            [self showHint:data];
        }
    } failure:^(NSError *error){
//        [self showHint:ERRORREQUESTTIP];
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
            cell.topicLabel.text = [NSString stringWithFormat:@"截止于 %@",endtime];
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
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
            NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]]) {
                userId = nil;
            }
            NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            if (![myUserId isEqualToString:userId]){
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.topicLabel.text = @"光荣榜";
            }
            else{
                cell.topicLabel.text = @"我要验证";
                CGFloat zjSwitchW = 50;
                CGFloat zjSwitchH = 30;
                CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
                CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
                ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
                zjSwitch.on = [[switchDict objectForKey:@"4"] boolValue];
                [zjSwitch addTarget:self action:@selector(zjSwitchChange:) forControlEvents:UIControlEventValueChanged];
                zjSwitch.tag = 4;
                [cell addSubview:zjSwitch];
                
//                cell.topicLabel.text = @"赛区评论";
//                CGFloat zjSwitchW = 50;
//                CGFloat zjSwitchH = 30;
//                CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
//                CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
//                ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
//                zjSwitch.on = [[switchDict objectForKey:@"3"] boolValue];
//                [zjSwitch addTarget:self action:@selector(zjSwitchChange:) forControlEvents:UIControlEventValueChanged];
//                zjSwitch.tag = 3;
//                [cell addSubview:zjSwitch];
            }
            
            break;
        }
        case 6:{
            NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]]) {
                userId = nil;
            }
            NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            if (![myUserId isEqualToString:userId]){
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
                if (myRank == 0) {
                    rankLabel.text = @"未参赛";
                }
                
                User *userInfo = [HeSysbsModel getSysModel].user;
                NSString *userHead = userInfo.userHeader;
                if (![userHead hasPrefix:@"http"]) {
                    userHead = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHead];
                }
                CGFloat imageY = 5;
                CGFloat imageH = cellSize.height - 2 * imageY;
                CGFloat imageW = imageH;
                CGFloat imageX = cellSize.width - imageW - 35;
                UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
                userIcon.image = [UIImage imageNamed:@"userDefalut_icon"];
                userIcon.layer.borderWidth = 1.0;
                userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
                userIcon.layer.masksToBounds = YES;
                userIcon.layer.cornerRadius = imageH / 2.0;
                userIcon.contentMode = UIViewContentModeScaleAspectFill;
                [userIcon sd_setImageWithURL:[NSURL URLWithString:userHead] placeholderImage:userIcon.image];
                [cell addSubview:userIcon];
                if (myRank == 0) {
                    userIcon.hidden = YES;
                }
                
                break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.topicLabel.text = @"光荣榜";
//            cell.topicLabel.text = @"我要验证";
//            CGFloat zjSwitchW = 50;
//            CGFloat zjSwitchH = 30;
//            CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
//            CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
//            ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
//            zjSwitch.on = [[switchDict objectForKey:@"4"] boolValue];
//            [zjSwitch addTarget:self action:@selector(zjSwitchChange:) forControlEvents:UIControlEventValueChanged];
//            zjSwitch.tag = 4;
//            [cell addSubview:zjSwitch];
            break;
        }
//        case 7:{
//            cell.selectionStyle = UITableViewCellSelectionStyleGray;
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.topicLabel.text = @"光荣榜";
//            break;
//        }
        case 7:{
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
            if (![userHead hasPrefix:@"http"]) {
                userHead = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHead];
            }
            CGFloat imageY = 5;
            CGFloat imageH = cellSize.height - 2 * imageY;
            CGFloat imageW = imageH;
            CGFloat imageX = cellSize.width - imageW - 35;
            UIImageView *userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
            userIcon.image = [UIImage imageNamed:@"userDefalut_icon"];
            userIcon.layer.borderWidth = 1.0;
            userIcon.layer.borderColor = [UIColor whiteColor].CGColor;
            userIcon.layer.masksToBounds = YES;
            userIcon.layer.cornerRadius = imageH / 2.0;
            userIcon.contentMode = UIViewContentModeScaleAspectFill;
            [userIcon sd_setImageWithURL:[NSURL URLWithString:userHead] placeholderImage:userIcon.image];
            [cell addSubview:userIcon];
            if (myRank == 0) {
                rankLabel.text = @"未参赛";
                userIcon.hidden = YES;
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
    NSString *userId = contestDetailDict[@"userId"]; //发布人的ID
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = nil;
    }
    if (row == 2) {
        NSString *zoneLocationX = contestDetailDict[@"zoneLocationX"];
        if ([zoneLocationX isMemberOfClass:[NSNull class]] || zoneLocationX == nil) {
            zoneLocationX = @"";
        }
        NSString *zoneLocationY = contestDetailDict[@"zoneLocationY"];
        if ([zoneLocationY isMemberOfClass:[NSNull class]] || zoneLocationY == nil) {
            zoneLocationY = @"";
        }
        NSDictionary *locationDict = @{@"zoneLocationX":zoneLocationX,@"zoneLocationY":zoneLocationY};
        HeUserLocatiVC *userLocationVC = [[HeUserLocatiVC alloc] init];
        userLocationVC.userLocationDict = [[NSDictionary alloc] initWithDictionary:locationDict];
        userLocationVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:userLocationVC animated:YES];
        return;
    }
    NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (![myUserId isEqualToString:userId]){
        if (row == 5) {
            //光荣榜
            HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
            contestRankVC.contestDict = [[NSDictionary alloc] initWithDictionary:contestDetailDict];
            contestRankVC.topManRank = [[NSMutableArray alloc] initWithArray:topManRank];
            contestRankVC.topWomanRank = [[NSMutableArray alloc] initWithArray:topWomanRank];
            contestRankVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestRankVC animated:YES];
        }
        else if (row == 6){
            //我的排名
            HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
            contestRankVC.contestDict = [[NSDictionary alloc] initWithDictionary:contestDetailDict];
            contestRankVC.topManRank = [[NSMutableArray alloc] initWithArray:topManRank];
            contestRankVC.isUserRank = YES;
            contestRankVC.topWomanRank = [[NSMutableArray alloc] initWithArray:topWomanRank];
            contestRankVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestRankVC animated:YES];
        }
    }
    else{
        if (row == 6) {
            //光荣榜
            HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
            contestRankVC.contestDict = [[NSDictionary alloc] initWithDictionary:contestDetailDict];
            contestRankVC.topManRank = [[NSMutableArray alloc] initWithArray:topManRank];
            contestRankVC.topWomanRank = [[NSMutableArray alloc] initWithArray:topWomanRank];
            contestRankVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestRankVC animated:YES];
        }
        else if (row == 7){
            //我的排名
            HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
            contestRankVC.contestDict = [[NSDictionary alloc] initWithDictionary:contestDetailDict];
            contestRankVC.isUserRank = YES;
            contestRankVC.topManRank = [[NSMutableArray alloc] initWithArray:topManRank];
            contestRankVC.topWomanRank = [[NSMutableArray alloc] initWithArray:topWomanRank];
            contestRankVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestRankVC animated:YES];
        }
    }
    
    
}

- (void)backItemClick:(id)sender
{
    if (myzoneId) {
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
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
