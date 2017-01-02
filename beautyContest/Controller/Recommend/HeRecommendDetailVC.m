//
//  HeRecommendDetailVC.m
//  beautyContest
//
//  Created by Tony on 16/8/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeRecommendDetailVC.h"
#import "HeBaseIconTitleTableCell.h"
#import "HeCommentView.h"
#import "HeBaseTableViewCell.h"
#import "MJPhotoBrowser.h"
#import "FTPopOverMenu.h"
#import "UIButton+Bootstrap.h"
#import "MLLinkLabel.h"
#import "MLLabel+Size.h"
#import "HeUserInfoVC.h"
#import "HeComplaintVC.h"
#import "HeRecommendMessageVC.h"
#import "HeComplaintUserVC.h"
#import "WMPlayer.h"
#import "HeContestantUserInfoVC.h"

#define TextLineHeight 1.2f
#define BGTAG 100
#define USERHEADTAG 400
#define USERSEXTAG 300
#define USERNAMETAG 200
#define CONTENTTAG 500

@interface HeRecommendDetailVC ()<UITableViewDelegate,UITableViewDataSource,CommentProtocol>
{
    CGFloat imageScrollViewHeigh;
    CGFloat receiveScrollViewHeigh;
    UIImageView *alertBG;
    UIView *dismissView;
}
@property(strong,nonatomic)UIScrollView *photoScrollView;
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)UIButton *voteButton;
@property(strong,nonatomic)IBOutlet UIView *footerview;
@property(strong,nonatomic)NSMutableArray *redPocketArray;
@property(strong,nonatomic)NSArray *paperArray;
@property(strong,nonatomic)NSDictionary *recommendDetailDict;

@property(strong,nonatomic)UIScrollView *userReceivePocketScrollView;
@property(strong,nonatomic)WMPlayer *wmPlayer;

@end

@implementation HeRecommendDetailVC
@synthesize recommendDict;
@synthesize photoScrollView;
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize voteButton;
@synthesize footerview;
@synthesize redPocketArray;
@synthesize paperArray;
@synthesize recommendDetailDict;
@synthesize wmPlayer;

@synthesize userReceivePocketScrollView;

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
        label.text = @"推荐详情";
        [label sizeToFit];
        
        self.title = @"推荐详情";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadRecommendDetail];
    [self getUserPic];
}

- (void)initializaiton
{
    [super initializaiton];
    redPocketArray = [[NSMutableArray alloc] initWithCapacity:0];
    imageScrollViewHeigh = 100;
    receiveScrollViewHeigh = 60;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fullScreenBtnClick:) name:@"fullScreenBtnClickNotice" object:nil];
    
}

-(void)fullScreenBtnClick:(NSNotification *)notice{
    UIButton *fullScreenBtn = (UIButton *)[notice object];
    if (fullScreenBtn.isSelected) {//全屏显示
        [self toFullScreenWithInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
    }else{
        [self toNormal];
    }
}

-(void)toFullScreenWithInterfaceOrientation:(UIInterfaceOrientation )interfaceOrientation{
    [[UIApplication sharedApplication] setStatusBarHidden:YES animated:NO];
    [wmPlayer removeFromSuperview];
//    wmPlayer.transform = CGAffineTransformIdentity;
//    if (interfaceOrientation==UIInterfaceOrientationLandscapeLeft) {
//        wmPlayer.transform = CGAffineTransformMakeRotation(-M_PI_2);
//    }else if(interfaceOrientation==UIInterfaceOrientationLandscapeRight){
//        wmPlayer.transform = CGAffineTransformMakeRotation(M_PI_2);
//    }
    wmPlayer.frame = CGRectMake(0, 0, SCREENWIDTH, SCREENHEIGH);
    wmPlayer.playerLayer.frame =  CGRectMake(0,0, SCREENWIDTH,SCREENHEIGH);
    
//    [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(40);
//        make.top.mas_equalTo(self.view.frame.size.width-40);
//        make.width.mas_equalTo(self.view.frame.size.height);
//    }];
//    
//    [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(wmPlayer).with.offset((-self.view.frame.size.height/2));
//        make.height.mas_equalTo(30);
//        make.width.mas_equalTo(30);
//        make.top.equalTo(wmPlayer).with.offset(5);
//        
//    }];
    [[UIApplication sharedApplication].keyWindow addSubview:wmPlayer];
    wmPlayer.isFullscreen = YES;
    wmPlayer.fullScreenBtn.selected = YES;
    [wmPlayer bringSubviewToFront:wmPlayer.bottomView];
    
}
-(void)toNormal{
    [wmPlayer removeFromSuperview];
    
    CGRect playerFrame = CGRectMake(0, 0, SCREENWIDTH, 150);
    [UIView animateWithDuration:0.5f animations:^{
        wmPlayer.transform = CGAffineTransformIdentity;
        wmPlayer.frame =CGRectMake(playerFrame.origin.x, playerFrame.origin.y, playerFrame.size.width, playerFrame.size.height);
        wmPlayer.playerLayer.frame =  wmPlayer.bounds;
        [tableview.tableFooterView addSubview:wmPlayer];
        [wmPlayer.bottomView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(0);
            make.right.equalTo(wmPlayer).with.offset(0);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(wmPlayer).with.offset(0);
        }];
        [wmPlayer.closeBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(wmPlayer).with.offset(5);
            make.height.mas_equalTo(30);
            make.width.mas_equalTo(30);
            make.top.equalTo(wmPlayer).with.offset(5);
        }];
        
    }completion:^(BOOL finished) {
        wmPlayer.isFullscreen = NO;
        wmPlayer.fullScreenBtn.selected = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO animated:NO];
        
    }];
}

- (void)initView
{
    [super initView];
    
    UIButton *moreButton = [[UIButton alloc] init];
    [moreButton setTitle:@"更多" forState:UIControlStateNormal];
    [moreButton addTarget:self action:@selector(complaintAction:) forControlEvents:UIControlEventTouchUpInside];
    moreButton.frame = CGRectMake(0, 0, 40, 25);
    [moreButton.titleLabel setFont:[UIFont systemFontOfSize:13.5]];
    
    UIBarButtonItem *complaintItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
    self.navigationItem.rightBarButtonItem = complaintItem;
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 210)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comonDefaultImage"]];
    bgImage.layer.masksToBounds = YES;
    bgImage.userInteractionEnabled = YES;
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.tag = BGTAG;
    bgImage.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlargeImage:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [bgImage addGestureRecognizer:tap];
    
    CGFloat userImageW = 50;
    CGFloat userImageH = userImageW;
    CGFloat userImageY = 30;
    CGFloat userImageX = (SCREENWIDTH - userImageW) / 2.0;
    UIImageView *userImage = [[UIImageView alloc] initWithFrame:CGRectMake(userImageX, userImageY, userImageW, userImageH)];
    userImage.tag = USERHEADTAG;
    userImage.image = [UIImage imageNamed:@"userDefalut_icon"];
    userImage.layer.masksToBounds = YES;
    userImage.layer.cornerRadius = userImageW / 2.0;
    userImage.layer.borderWidth = 1.0;
    userImage.layer.borderColor = [UIColor whiteColor].CGColor;
    [sectionHeaderView addSubview:userImage];
    
    UITapGestureRecognizer *scanUserTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUser:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    userImage.userInteractionEnabled = YES;
    sectionHeaderView.userInteractionEnabled = YES;
    [userImage addGestureRecognizer:scanUserTap];
    
    CGFloat sexW = 20;
    CGFloat sexH = 20;
    CGFloat sexX = (SCREENWIDTH - sexW) / 2.0;
    CGFloat sexY = CGRectGetMaxY(userImage.frame) + 5;
    UIImageView *sexIcon = [[UIImageView alloc] initWithFrame:CGRectMake(sexX, sexY, sexW, sexH)];
    sexIcon.image = [UIImage imageNamed:@"icon_sex_boy"];
    sexIcon.tag = USERSEXTAG;
    [sectionHeaderView addSubview:sexIcon];
    
    CGFloat nameX = 0;
    CGFloat nameY = CGRectGetMaxY(sexIcon.frame) + 2;
    CGFloat nameH = 25;
    CGFloat nameW = SCREENWIDTH;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameX, nameY, nameW, nameH)];
    nameLabel.tag = USERNAMETAG;
    nameLabel.font = [UIFont systemFontOfSize:16.0];
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = recommendDict[@"userNick"];
    [sectionHeaderView addSubview:nameLabel];
    
    CGFloat contentX = 0;
    CGFloat contentY = CGRectGetMaxY(nameLabel.frame);
    CGFloat contentH = 25;
    CGFloat contentW = SCREENWIDTH;
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
    contentLabel.tag = CONTENTTAG;
    contentLabel.text = recommendDict[@"recommendContent"];
    contentLabel.font = [UIFont systemFontOfSize:15.0];
    contentLabel.textColor = [UIColor whiteColor];
    contentLabel.textAlignment = NSTextAlignmentCenter;
    contentLabel.backgroundColor = [UIColor clearColor];
    [sectionHeaderView addSubview:contentLabel];
    
    UIView *buttonBG = [[UIView alloc] initWithFrame:CGRectMake(0, bgImage.frame.size.height - 40, SCREENWIDTH, 40)];
    buttonBG.userInteractionEnabled = YES;
    buttonBG.userInteractionEnabled = YES;
    CGFloat rX = 0;
    CGFloat rY = 0;
    CGFloat rW = SCREENWIDTH;
    CGFloat rH = 40;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(rX, rY, rW, rH);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor clearColor].CGColor,
                       (id)[UIColor colorWithWhite:150.0 / 255.0 alpha:0.8].CGColor,
                       nil];
    [buttonBG.layer insertSublayer:gradient atIndex:0];
    [bgImage addSubview:buttonBG];
    
    CGFloat subbuttonX = 0;
    CGFloat subbuttonW = SCREENWIDTH / 2.0;
    CGFloat subbuttonH = 40;
    CGFloat subbuttonY = buttonBG.frame.size.height - subbuttonH;
    UIButton *followButton = [[UIButton alloc] initWithFrame:CGRectMake(subbuttonX, subbuttonY, subbuttonW, subbuttonH)];
    [followButton setTitle:@"+关注" forState:UIControlStateNormal];
    [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    followButton.tag = 1;
    [followButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [followButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBG addSubview:followButton];
    
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(subbuttonX + subbuttonW, subbuttonY, subbuttonW, subbuttonH)];
    [messageButton setTitle:@"留言" forState:UIControlStateNormal];
    [messageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    messageButton.tag = 2;
    [messageButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [messageButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [buttonBG addSubview:messageButton];
    
    UIView *sepLine = [[UIView alloc] initWithFrame:CGRectMake(SCREENWIDTH / 2.0 - 0.5, subbuttonY + (subbuttonH - 30) / 2.0, 1, 30)];
    sepLine.backgroundColor = [UIColor whiteColor];
    [buttonBG addSubview:sepLine];

    
    CGFloat buttonX = 20;
    CGFloat buttonY = 5;
    CGFloat buttonH = 40;
    CGFloat buttonW = SCREENWIDTH - 2 * buttonX;
    voteButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [voteButton setTitle:@"投票领红包" forState:UIControlStateNormal];
    UIImageView *imageIcon = [[UIImageView alloc] initWithFrame:CGRectMake(50, 10, 20, 20)];
    imageIcon.image = [UIImage imageNamed:@"icon_reward"];
    [voteButton addSubview:imageIcon];
    [voteButton.titleLabel setFont:[UIFont systemFontOfSize:16.0]];
    [voteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"投票领红包" image:@"icon_reward"];
    voteButton.tag = 2;
    [voteButton addTarget:self action:@selector(voteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [voteButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor colorWithRed:253.0 / 255.0 green:149.0 / 255.0 blue:38.0 / 255.0 alpha:1.0] withImageSize:voteButton.frame.size] forState:UIControlStateNormal];
    [footerview addSubview:voteButton];
    voteButton.layer.cornerRadius = 5.0;
    voteButton.layer.masksToBounds = YES;
    
    CGFloat receivescrollX = 5;
    CGFloat receivescrollY = 5;
    CGFloat receivescrollW = SCREENWIDTH - 2 * receivescrollX;
    CGFloat receivescrollH = receiveScrollViewHeigh;
    userReceivePocketScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(receivescrollX, receivescrollY, receivescrollW, receivescrollH)];
    
    CGFloat scrollX = 5;
    CGFloat scrollY = 5;
    CGFloat scrollW = SCREENWIDTH - 2 * scrollX;
    CGFloat scrollH = imageScrollViewHeigh;
    photoScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(scrollX, scrollY, scrollW, scrollH)];
    NSString *recommendCover = [recommendDict objectForKey:@"recommendCover"];
    if ([recommendCover isMemberOfClass:[NSNull class]]) {
        recommendCover = @"";
    }
    paperArray = [recommendCover componentsSeparatedByString:@","];
    
    if ([paperArray count] == 0 || [paperArray[0] isEqualToString:@""]) {
        
    }
    else{
        [bgImage sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,paperArray[0]]] placeholderImage:bgImage.image];
    }
}

- (void)addPhotoScrollView
{
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat imageH = photoScrollView.frame.size.height;
    CGFloat imageW = imageH;
    CGFloat imageDistance = 5;
    NSInteger index = 0;
    for (NSString *url in paperArray) {
        NSString *imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        [imageview sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 5.0;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        [photoScrollView addSubview:imageview];
        imageX = imageX + imageW + imageDistance;
        imageview.tag = index + 10000;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanlargeImage:)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        imageview.userInteractionEnabled = YES;
        [imageview addGestureRecognizer:tap];
        index++;
        
    }
    if (imageX > photoScrollView.frame.size.width) {
        photoScrollView.contentSize = CGSizeMake(imageX, 0);
    }
}

- (void)complaintAction:(id)sender
{
    NSArray *menuArray = @[@"举报",@"屏蔽该发布人"];
    [FTPopOverMenu setTintColor:APPDEFAULTORANGE];
    [FTPopOverMenu showForSender:sender
                        withMenu:menuArray
                  imageNameArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           switch (selectedIndex) {
                               case 0:
                               {
                                   //投诉
                                   HeComplaintVC *complaintVC = [[HeComplaintVC alloc] init];
                                   complaintVC.hidesBottomBarWhenPushed = YES;
                                   [self.navigationController pushViewController:complaintVC animated:YES];
                                   break;
                               }
                               case 1:
                               {
                                   //屏蔽用户
                                   [self blockUserButtonClick];
                                   return;
                                   HeComplaintUserVC *complaintVC = [[HeComplaintUserVC alloc] init];
                                   complaintVC.userNick = recommendDict[@"userNick"];
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
    NSString *userId = recommendDict[@"recommendUser"]; //发布人的ID
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
            NSString *userId = recommendDict[@"recommendUser"]; //发布人的ID
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            NSString *userNick = recommendDict[@"userNick"];
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
                NSString *userId = recommendDict[@"recommendUser"]; //发布人的ID
                if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                    userId = @"";
                }
                NSString *userNick = recommendDict[@"userNick"];
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

- (void)scanUser:(UITapGestureRecognizer *)tap
{
    NSString *recommendUser = recommendDict[@"recommendUser"];
    if ([recommendUser isMemberOfClass:[NSNull class]] || recommendUser == nil) {
        recommendUser = @"";
    }
    NSString *userNick = recommendDict[@"userNick"];
    if ([userNick isMemberOfClass:[NSNull class]] || userNick == nil) {
        userNick = @"";
    }
    
    User *user = [[User alloc] init];
    user.userNick = userNick;
    user.userId = recommendUser;
    
    HeUserInfoVC *userInfoVC = [[HeUserInfoVC alloc] init];
    userInfoVC.isScanUser = YES;
    userInfoVC.userInfo = [[User alloc] initUserWithUser:user];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)scanlargeImage:(UITapGestureRecognizer *)tap
{
    NSInteger index = 0;
    NSMutableArray *photos = [NSMutableArray array];
    for (NSString *url in paperArray) {
        NSString *imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageurl];
        
        UIImageView *srcImageView = [photoScrollView viewWithTag:index + 10000];
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

- (void)enlargeImage:(UITapGestureRecognizer *)tap
{
    NSString *zoneCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,paperArray[0]];
    
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

- (void)loadRecommendDetail
{
    NSString *userId = recommendDict[@"recommendUser"];
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = @"";
    }
    NSString *recommendId = recommendDict[@"recommendId"];
    if ([recommendId isMemberOfClass:[NSNull class]]) {
        recommendId = @"";
    }
    [self showHudInView:self.tableview hint:@"加载中..."];
    
    __weak typeof(self) weakSelf = self;
    NSString *requestUrl = [NSString stringWithFormat:@"%@/recommend/recommendUserInfo.action",BASEURL];
    NSDictionary *params = @{@"userId":userId,@"recommendId":recommendId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [weakSelf hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSDictionary *jsonDict = [respondDict objectForKey:@"json"];
            recommendDetailDict = [[NSDictionary alloc] initWithDictionary:jsonDict];
            NSString *receiveUserHeader = [recommendDetailDict objectForKey:@"receiveUserHeader"];
            if([receiveUserHeader isMemberOfClass:[NSNull class]] || receiveUserHeader == nil){
                receiveUserHeader = @"";
            }
            NSArray *receiveUserHeaderArray = [receiveUserHeader componentsSeparatedByString:@","];
            [redPocketArray addObjectsFromArray:receiveUserHeaderArray];
            
            CGFloat imageX = 0;
            CGFloat imageY = 0;
            CGFloat imageH = userReceivePocketScrollView.frame.size.height;
            CGFloat imageW = imageH;
            CGFloat imageDistance = 5;
            NSInteger imageTag = 0;
            for (NSString *url in redPocketArray) {
                if ([url isEqualToString:@""]) {
                    continue;
                }
                NSString *imageurl = url;
                if (![url hasPrefix:@"http"]) {
                    imageurl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,url];
                }
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
                imageview.tag = imageTag;
                imageTag++;
                imageview.layer.masksToBounds = YES;
                imageview.layer.cornerRadius = imageH / 2.0;
                imageview.contentMode = UIViewContentModeScaleAspectFill;
                [imageview sd_setImageWithURL:[NSURL URLWithString:imageurl] placeholderImage:[UIImage imageNamed:@"userDefalut_icon"]];
                [userReceivePocketScrollView addSubview:imageview];
                imageX = imageX + imageW + imageDistance;
                
                UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserDetail:)];
                tapGes.numberOfTapsRequired = 1;
                tapGes.numberOfTouchesRequired = 1;
                imageview.userInteractionEnabled = YES;
                [imageview addGestureRecognizer:tapGes];
                userReceivePocketScrollView.userInteractionEnabled = YES;
            }
            if (imageX > userReceivePocketScrollView.frame.size.width) {
                userReceivePocketScrollView.contentSize = CGSizeMake(imageX, 0);
            }
            [weakSelf addPhotoScrollView];
            [weakSelf updateUserInfo];
            [weakSelf addVideoView];
            [tableview reloadData];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            NSLog(@"errorInfo = %@",data);
        }
    } failure:^(NSError *error){
        [weakSelf showHint:ERRORREQUESTTIP];
    }];
}

- (void)getUserPic
{
    NSString *userId = recommendDict[@"recommendUser"];
    if ([userId isMemberOfClass:[NSNull class]]) {
        userId = @"";
    }
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/paperWall/GetUserPic.action",BASEURL];
    NSDictionary *params = @{@"userId":userId};
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

- (void)addVideoView
{
    NSString *recommendVideo = recommendDetailDict[@"recommendVideo"];
    if ([recommendVideo isMemberOfClass:[NSNull class]] || recommendVideo == nil || [recommendVideo isEqualToString:@""]) {
        recommendVideo = nil;
    }
    if (!recommendVideo) {
        tableview.tableFooterView = nil;
        return;
    }
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 150)];
    tableview.tableFooterView = footerView;
    recommendVideo = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,recommendVideo];
    
    wmPlayer = [[WMPlayer alloc]initWithFrame:footerView.bounds videoURLStr:recommendVideo];
    wmPlayer.closeBtn.hidden = YES;
    [footerView addSubview:wmPlayer];
//    [wmPlayer.player play];
    
    
//    MPMoviePlayerController *moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:[NSURL URLWithString:recommendVideo]];
//    moviePlayer.movieSourceType = MPMediaTypeMovie;
//    moviePlayer.controlStyle = MPMovieControlStyleDefault;
//    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//    moviePlayer.repeatMode = MPMovieRepeatModeNone;
//    moviePlayer.allowsAirPlay = NO;
//    moviePlayer.shouldAutoplay = NO;
//    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//    moviePlayer.view.frame = footerView.bounds;
//    moviePlayer.view.autoresizingMask = (UIViewAutoresizing)(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
//    [moviePlayer prepareToPlay];
//    [footerView addSubview:moviePlayer.view];
    
}

- (void)voteButtonClick:(UIButton *)button
{
    NSString *userId = recommendDict[@"recommendUser"];
    if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
        userId = @"";
    }
    [self godVoteWithUserId:userId];
}

- (void)scanUserDetail:(UITapGestureRecognizer *)tap
{
    NSInteger tag = tap.view.tag;
    id userIdArrayString = recommendDetailDict[@"userId"];
    if ([userIdArrayString isMemberOfClass:[NSNull class]] || userIdArrayString == nil) {
        userIdArrayString = @"";
    }
    NSArray *userIdArray = [userIdArrayString componentsSeparatedByString:@","];
    NSString *userId = nil;
    @try {
        userId = userIdArray[tag];
    } @catch (NSException *exception) {
        userId = nil;
    } @finally {
        
    }
    if (!userId) {
        [self showHint:@"该用户不存在"];
        return;
    }
    HeContestantUserInfoVC *userInfoVC = [[HeContestantUserInfoVC alloc] init];
    userInfoVC.userId = [NSString stringWithFormat:@"%@",userId];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
    
}
- (void)showAlerWithText:(NSString *)text
{
    if (!alertBG) {
        
        dismissView = [[UIView alloc] init];
        dismissView.frame = self.view.bounds;
        dismissView.backgroundColor = [UIColor blackColor];
        dismissView.alpha = 0.7;
        [self.view addSubview:dismissView];
        
        UIImage *alertImage = [UIImage imageNamed:@"icon_red_big"];
        CGFloat imageScale = alertImage.size.width / alertImage.size.height;
        
        
        CGFloat alertW = 200;
        CGFloat alertX = (SCREENWIDTH - alertW) / 2.0;
        CGFloat alertH = alertW / imageScale;
        CGFloat alertY = 50;
        alertBG = [[UIImageView alloc] init];
        alertBG.frame = CGRectMake(alertX, alertY, alertW, alertH);
        alertBG.image = alertImage;
        alertBG.userInteractionEnabled = YES;
        //        alertBG.center = self.view.center;
        [self.view addSubview:alertBG];
        
        UILabel *tipLabel = [[UILabel alloc] init];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.textColor = [UIColor orangeColor];
        tipLabel.font = [UIFont boldSystemFontOfSize:24.0];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.text = text;
        tipLabel.frame = CGRectMake(0, alertH - 60, alertW, 30);
        [alertBG addSubview:tipLabel];
        
        
        UITapGestureRecognizer *disGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
        disGes.numberOfTapsRequired = 1;
        disGes.numberOfTouchesRequired = 1;
        [dismissView addGestureRecognizer:disGes];
    }
    
    dismissView.hidden = NO;
    alertBG.hidden = NO;
    //    [inputField becomeFirstResponder];
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [alertBG.layer addAnimation:popAnimation forKey:nil];
}

- (void)dismiss:(UITapGestureRecognizer *)tap
{
    dismissView.hidden = YES;
    alertBG.hidden = YES;
}

- (void)godVoteWithUserId:(NSString *)userId
{
    NSString *hostId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([hostId isMemberOfClass:[NSNull class]] || hostId == nil) {
        hostId = @"";
    }
    [self showHudInView:self.view hint:@"投票中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/vote/GodVoteUser.action",BASEURL];
    NSDictionary *params = @{@"voteUser":userId,@"voteHost":hostId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"成功投票";
            }
            [self receiveRedPocket];
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
- (void)receiveRedPocket
{
    NSString *receiveId = recommendDetailDict[@"moneyId"];
    if ([receiveId isMemberOfClass:[NSNull class]] || receiveId == nil) {
        receiveId = @"";
        [self showHint:@"推荐者未发放红包或者红包已领取完"];
        return;
    }
    
    NSString *userId = recommendDict[@"recommendUser"];
    if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
        userId = @"";
    }
    
    NSString *hostId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if ([hostId isMemberOfClass:[NSNull class]] || hostId == nil) {
        hostId = @"";
    }
    [self showHudInView:self.view hint:@"领取红包中..."];
    
    NSString *requestUrl = [NSString stringWithFormat:@"%@/recommend/receivered.action",BASEURL];
    NSDictionary *params = @{@"userId":userId,@"hostId":hostId,@"receiveId":receiveId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
//            NSString *data = [respondDict objectForKey:@"data"];
//            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
//                data = @"领取成功";
//            }
            id redPocketNum = respondDict[@"json"];
            if ([redPocketNum isMemberOfClass:[NSNull class]]) {
                redPocketNum = @"";
            }
            if ([redPocketNum integerValue] == 0) {
                [self showHint:@"领取过了"];
                return;
            }
            NSString *data = [NSString stringWithFormat:@"￥%ld",(long)[redPocketNum integerValue]];
            [self showAlerWithText:data];
//            [self showHint:data];
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

- (void)buttonClick:(UIButton *)button
{
    switch (button.tag) {
        case 1:
        {
            NSString *userId = recommendDict[@"recommendUser"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }
            [self followUser:userId];
            break;
        }
        case 2:{
            NSString *userId = recommendDict[@"recommendUser"];
            if ([userId isMemberOfClass:[NSNull class]] || userId == nil) {
                userId = @"";
            }

            HeRecommendMessageVC *recommendMessageVC = [[HeRecommendMessageVC alloc] init];
            recommendMessageVC.userId = [[NSString alloc] initWithFormat:@"%@",userId];
            recommendMessageVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:recommendMessageVC animated:YES];
            
            break;
        }
        default:
            break;
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

- (void)updateUserInfo
{
    UIImageView *userImage = [sectionHeaderView viewWithTag:USERHEADTAG];
    NSString *userHeader = recommendDetailDict[@"userHeader"];
    if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
        userHeader = @"";
    }
    if (![userHeader hasPrefix:@"http"]) {
        userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    }
    [userImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:userImage.image];
    
//    if ([paperArray count] == 0 || [paperArray[0] isEqualToString:@""]) {
//        //如果没有图，用头像替代
//        UIImageView *bgImage = [sectionHeaderView viewWithTag:BGTAG];
//        [bgImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:bgImage.image];
//    }
    
    
    UIImageView *sexIcon = [sectionHeaderView viewWithTag:USERSEXTAG];
    id userSex = recommendDetailDict[@"userSex"];
    if ([userSex isMemberOfClass:[NSNull class]]) {
        userSex = @"";
    }
    if ([userSex integerValue] == 2) {
        sexIcon.image = [UIImage imageNamed:@"icon_sex_girl"];
    }
    else{
        sexIcon.image = [UIImage imageNamed:@"icon_sex_boy"];
    }
    
    NSString *userName = recommendDetailDict[@"userName"];
    if ([userName isMemberOfClass:[NSNull class]] || userName == nil) {
        userName = @"";
    }
    UILabel *nameLabel = [sectionHeaderView viewWithTag:USERNAMETAG];
    nameLabel.text = userName;
}

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser
{
    NSString *blogHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *blogUser = recommendDict[@"recommendUser"];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger section = 0;
    if ([paperArray count] != 0) {
        section++;
    }
    if ([redPocketArray count] != 0) {
        section++;
    }
    
    return section;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeBaseIconTitleTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseIconTitleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    if ([paperArray count] != 0 && section == 0) {
        [cell addSubview:photoScrollView];
    }
    else {
        [cell addSubview:userReceivePocketScrollView];
    }
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if ([paperArray count] != 0 && section == 0) {
        return 2 * photoScrollView.frame.origin.y + imageScrollViewHeigh;
    }
    
    
    return 70;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat heigth = 0;
    
    NSInteger redPocketNum = 0;
    for (id obj in redPocketArray) {
        if ([obj isEqualToString:@""]) {
            continue;
        }
        redPocketNum++;
    }
    
    if (redPocketNum != 0) {
        if ([paperArray count] == 0) {
            heigth = 30;
        }
        else if (section == 1){
            heigth = 30;
        }
    }
    else{
        heigth = 0;
    }
    return heigth;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSInteger redPocketNum = 0;
    for (id obj in redPocketArray) {
        if ([obj isEqualToString:@""]) {
            continue;
        }
        redPocketNum++;
    }
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 30)];
    bgView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:bgView.bounds];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:12.0];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.text = [NSString stringWithFormat:@"  %ld人领取过红包",redPocketNum];
    [bgView addSubview:titleLabel];
    
    if (redPocketNum != 0) {
        if ([paperArray count] == 0) {
            return bgView;
        }
        else if (section == 1){
            return bgView;
        }
    }
    return nil;
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
