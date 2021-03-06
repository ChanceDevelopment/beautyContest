//
//  HeTabBarVC.m
//  huayoutong
//
//  Created by HeDongMing on 16/3/2.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeTabBarVC.h"
#import "RDVTabBarItem.h"
#import "RDVTabBar.h"
#import "RDVTabBarController.h"
#import "HeSysbsModel.h"
#import "HeNewRecommendVC.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>

@interface HeTabBarVC ()
@property(strong,nonatomic)NSTimer *myTimer;

@end

@implementation HeTabBarVC
@synthesize userVC;
@synthesize beautyZoneVC;
@synthesize recommendVC;
@synthesize discoverVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self getUserInfo];
    [self getUserFans];
    [self getUserTicket];
    [self getUserFollow];
    //获取用户可操作的相册，在相册中需要用到
    [self getUserAlbum];
    //获取活动的类型还有地点
    [self getActivityTypeAddress];
    [self autoLogin];
    [self setupSubviews];
    _myTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(loadConfirmData) userInfo:nil repeats:YES];
    [_myTimer fire];
}

- (void)loadConfirmData
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/TestZoneQueInfo.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestParamDict = @{@"userId":userId};
   
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestParamDict success:^(AFHTTPRequestOperation* operation,id response){
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            
            NSArray *resultArray = [respondDict objectForKey:@"json"];
            if ([resultArray isMemberOfClass:[NSNull class]]) {
                return;
            }
            NSInteger waitingConfirmNum = 0;
            for (NSDictionary *zoneDict in resultArray) {
                id testState = zoneDict[@"testState"];
                if ([testState integerValue] == 0) {
                    waitingConfirmNum++;
                }
                [HeSysbsModel getSysModel].waitingConfirmNum = waitingConfirmNum;
                [[UIApplication sharedApplication] setApplicationIconBadgeNumber:waitingConfirmNum];
            }
            
        }
       
    } failure:^(NSError *error){
//        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)getUserFans
{
    NSString *getUserFansUrl = [NSString stringWithFormat:@"%@/user/getFansNum.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (userId == nil) {
        userId = @"";
    }
    NSDictionary *params = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserFansUrl params:params  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            id fansNumObj = [respondDict objectForKey:@"json"];
            if ([fansNumObj isMemberOfClass:[NSNull class]]) {
                fansNumObj = @"";
            }
            [HeSysbsModel getSysModel].fansNum = [fansNumObj integerValue];
            NSLog(@"%ld",[HeSysbsModel getSysModel].fansNum);
        }
        
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}



- (void)getUserTicket
{
    NSString *getUserTicketUrl = [NSString stringWithFormat:@"%@/vote/selectVoteCount.action",BASEURL];
    NSString *voteUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    
    if (voteUser == nil) {
        voteUser = @"";
    }
    NSDictionary *params = @{@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserTicketUrl params:params  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            id fansNumObj = [respondDict objectForKey:@"json"];
            if ([fansNumObj isMemberOfClass:[NSNull class]]) {
                fansNumObj = @"";
            }
            [HeSysbsModel getSysModel].ticketNum = [fansNumObj integerValue];
            
        }
        
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}
- (void)getUserFollow
{
    NSString *getUserFollowUrl = [NSString stringWithFormat:@"%@/user/getFollowNum.action",BASEURL];
    NSString *hostId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (hostId == nil) {
        hostId = @"";
    }
    NSDictionary *params = @{@"hostId":hostId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserFollowUrl params:params  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            id fansNumObj = [respondDict objectForKey:@"json"];
            if ([fansNumObj isMemberOfClass:[NSNull class]]) {
                fansNumObj = @"";
            }
            [HeSysbsModel getSysModel].followNum = [fansNumObj integerValue];
            
        }
        
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}
//后台自动登录
- (void)autoLogin
{
    
}

- (void)clearInfo
{
    
}

//获取用户的信息
- (void)getUserInfo
{
    NSString *getUserInfoUrl = [NSString stringWithFormat:@"%@/user/getUserinfo.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (userId == nil) {
        userId = @"";
    }
    NSDictionary *loginParams = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserInfoUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
            NSString *userDataPath = [Tool getUserDataPath];
            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
            BOOL succeed = [@{@"user":respondString} writeToFile:userFileName atomically:YES];
            if (succeed) {
                NSLog(@"用户资料写入成功");
            }
            User *user = [[User alloc] initUserWithDict:userDictInfo];
            NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            if (userId == nil) {
                userId = @"";
            }
            user.userId = userId;
            
            BOOL isthirdPartyLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isthirdPartyLogin"] boolValue];
            NSDictionary *thirdPartyDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"thirdPartyData"];
            
            if (isthirdPartyLogin) {
                NSString *userHeader = user.userHeader;
                if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil || [userHeader isEqualToString:@""]) {
                    userHeader = thirdPartyDict[@"userHeader"];
                }
                user.userHeader = userHeader;
                NSString *userNick = user.userNick;
                if (userNick == nil || [userNick isEqualToString:@""]) {
                    userNick = thirdPartyDict[@"userNick"];
                }
                user.userNick = userNick;
            }
            
            [HeSysbsModel getSysModel].user = [[User alloc] initUserWithUser:user];
        }
        else{
            NSString *userDataPath = [Tool getUserDataPath];
            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
            NSDictionary *respondDict = [[NSDictionary alloc] initWithContentsOfFile:userFileName];
            if (respondDict) {
                NSString *myresponseString = [respondDict objectForKey:@"user"];
                NSDictionary *respondDict = [myresponseString objectFromJSONString];
                NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
                User *user = [[User alloc] initUserWithDict:userDictInfo];
                NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
                if (userId == nil) {
                    userId = @"";
                }
                user.userId = userId;
                BOOL isthirdPartyLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isthirdPartyLogin"] boolValue];
                NSDictionary *thirdPartyDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"thirdPartyData"];
                if (isthirdPartyLogin) {
                    NSString *userHeader = user.userHeader;
                    if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil || [userHeader isEqualToString:@""]) {
                        userHeader = thirdPartyDict[@"userHeader"];
                    }
                    user.userHeader = userHeader;
                    NSString *userNick = user.userNick;
                    if (userNick == nil || [userNick isEqualToString:@""]) {
                        userNick = thirdPartyDict[@"userNick"];
                    }
                    user.userNick = userNick;
                }
                [HeSysbsModel getSysModel].user = [[User alloc] initUserWithUser:user];
            }
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
    
}

- (void)getUserAlbum
{
    
}

- (void)getActivityTypeAddress
{
    
}

//设置根控制器的四个子控制器
- (void)setupSubviews
{
    beautyZoneVC = [[HeBeautyZoneVC alloc] init];
    CustomNavigationController *beautyZoneNav = [[CustomNavigationController alloc] initWithRootViewController:beautyZoneVC];
    
    recommendVC = [[HeNewRecommendVC alloc] init];
    CustomNavigationController *recommendNav = [[CustomNavigationController alloc] initWithRootViewController:recommendVC];
    
    discoverVC = [[HeDiscoverVC alloc] init];
    CustomNavigationController *discoverNav = [[CustomNavigationController alloc] initWithRootViewController:discoverVC];
    
    userVC = [[HeUserVC alloc] init];
    CustomNavigationController *userNav = [[CustomNavigationController alloc]
                                           initWithRootViewController:userVC];
    
    [self setViewControllers:@[beautyZoneNav,recommendNav,discoverNav,userNav]];
    [self customizeTabBarForController];
}

//设置底部的tabbar
- (void)customizeTabBarForController{
    //    tabbar_normal_background   tabbar_selected_background
    UIImage *finishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    UIImage *unfinishedImage = [UIImage imageNamed:@"tabbar_normal_background"];
    NSArray *tabBarItemImages = @[@"tabar_beautyZone_icon", @"tabar_recommend_icon", @"tabar_discover_icon", @"tabar_user_icon"];
    
    NSInteger index = 0;
    for (RDVTabBarItem *item in [[self tabBar] items]) {
        [item setBackgroundSelectedImage:finishedImage withUnselectedImage:unfinishedImage];
        UIImage *selectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_active",
                                                      [tabBarItemImages objectAtIndex:index]]];
        UIImage *unselectedimage = [UIImage imageNamed:[NSString stringWithFormat:@"%@_normal",
                                                        [tabBarItemImages objectAtIndex:index]]];
        [item setFinishedSelectedImage:selectedimage withFinishedUnselectedImage:unselectedimage];
        
        index++;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        //后台自动登录失败，退出登录
        [self clearInfo];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    if ([_myTimer isValid]) {
        [_myTimer invalidate];
    }
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
