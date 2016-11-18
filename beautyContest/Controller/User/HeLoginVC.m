//
//  HeLoginVC.m
//  kunyuan
//
//  Created by Tony on 16/6/16.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeLoginVC.h"
#import "HeEnrollVC.h"
#import "UIButton+Bootstrap.h"
#import "User.h"
#import "HeSysbsModel.h"
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>

@interface HeLoginVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *accountField;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UIButton *loginButton;
@property(strong,nonatomic)IBOutlet UIButton *wechatLoginButton;


@end

@implementation HeLoginVC
@synthesize accountField;
@synthesize passwordField;
@synthesize loginButton;
@synthesize wechatLoginButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"登录";
        [label sizeToFit];
        self.title = @"登录";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    UIBarButtonItem *enrollItem = [[UIBarButtonItem alloc] init];
    enrollItem.title = @"注册";
    enrollItem.tintColor = [UIColor whiteColor];
    enrollItem.target = self;
    enrollItem.action = @selector(enrollMethod:);
    self.navigationItem.rightBarButtonItem = enrollItem;
    
    [loginButton dangerStyle];
    loginButton.layer.borderWidth = 0;
    loginButton.layer.borderColor = [UIColor clearColor].CGColor;
    [loginButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:loginButton.frame.size] forState:UIControlStateNormal];
    
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
#pragma mark - 微信登录
    /*
     目前移动应用上德微信登录只提供原生的登录方式，需要用户安装微信客户端才能配合使用。
     对于iOS应用,考虑到iOS应用商店审核指南中的相关规定，建议开发者接入微信登录时，先检测用户手机是否已经安装
     微信客户端(使用sdk中的isWXAppInstall函数),对于未安装的用户隐藏微信 登录按钮，只提供其他登录方式。
     */
    if ([WXApi isWXAppInstalled]) {
        wechatLoginButton.hidden = YES;
    }
    else{
        wechatLoginButton.hidden = YES;
    }
}

//第三方登录
- (IBAction)thirdPartyLogin
{
    //微信第三方登录
    [ShareSDK getUserInfo:SSDKPlatformTypeWechat
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             NSString *nickname = user.nickname;
             NSString *icon = user.icon;
             if ([nickname isMemberOfClass:[NSNull class]] || nickname == nil) {
                 nickname = @"";
             }
             if ([icon isMemberOfClass:[NSNull class]] || icon == nil) {
                 icon = @"";
             }
             NSDictionary *rawData = user.rawData;
             
             NSString *WeiXinId = rawData[@"openid"];
             NSString *userHeader = rawData[@"headimgurl"];
             NSString *userNick = rawData[@"nickname"];
             NSString *userName = @"";
             NSString *userPwd = @"";
             NSString *userSex = [NSString stringWithFormat:@"%@",rawData[@"sex"]];
             
             NSDictionary *wechatLoginParam = @{@"WeiXinId":WeiXinId,@"userHeader":userHeader,@"userNick":userNick,@"userName":userName,@"userPwd":userPwd,@"userSex":userSex};
             
             [self loginWithLoginParams:@{@"WXinfo":[wechatLoginParam JSONString]}];
             
             
        
         }
         
         else
         {
             
             NSLog(@"%@",error);
         }
         
     }];
    
}

- (void)loginWithLoginParams:(NSDictionary *)loginParams
{
    [self showHudInView:self.view hint:@"登录中..."];
    NSString *loginUrl = [NSString stringWithFormat:@"%@user/WXLogin.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:loginUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSString *myuserId = [respondDict objectForKey:@"json"];
            if ([myuserId isMemberOfClass:[NSNull class]]) {
                myuserId = @"";
            }
            NSString *userInfoString = loginParams[@"WXinfo"];
            NSDictionary *wechatDict = [userInfoString objectFromJSONString];
            NSDictionary *userDictInfo = @{@"userState":wechatDict[@"userSex"],@"userId":myuserId};
//            NSInteger userState = [[userDictInfo objectForKey:@"userState"] integerValue];
//            if (userState == 0) {
//                [self showHint:@"当前用户不可用"];
//                return ;
//            }
            NSDictionary *myUserDict = @{@"data":@"success",@"errorCode":@"200",@"json":userDictInfo};
            respondString = [myUserDict JSONString];
            NSString *userDataPath = [Tool getUserDataPath];
            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
            BOOL succeed = [@{@"user":respondString} writeToFile:userFileName atomically:YES];
            if (succeed) {
                NSLog(@"用户资料写入成功");
            }
            User *user = [[User alloc] initUserWithDict:userDictInfo];
            [HeSysbsModel getSysModel].user = user;
            NSString *userId = [HeSysbsModel getSysModel].user.userId;
            if (userId == nil) {
                userId = @"";
            }
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USERACCOUNTKEY];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:USERPASSWORDKEY];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:USERIDKEY];
            User *userInfo = [[User alloc] initUserWithDict:userDictInfo];
            [HeSysbsModel getSysModel].user = userInfo;
            
            //发送自动登陆状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"登录失败!";
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)enrollMethod:(id)sender
{
    HeEnrollVC *enrollVC = [[HeEnrollVC alloc] init];
    enrollVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:enrollVC animated:YES];
}

- (IBAction)loginMethod:(id)sender
{
    if ([accountField isFirstResponder]) {
        [accountField resignFirstResponder];
    }
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    NSString *account = accountField.text;
    NSString *password = passwordField.text;
    if (account == nil || [account isEqualToString:@""]) {
        [self showHint:@"请输入登录手机号"];
        return;
    }
    if (password == nil || [password isEqualToString:@""]) {
        [self showHint:@"请输入用户密码"];
        return;
    }
//    if (![Tool isMobileNumber:account]) {
//        [self showHint:@"请输入正确的手机号"];
//        return;
//    }
    
    [self showHudInView:self.view hint:@"登录中..."];
    NSString *loginUrl = [NSString stringWithFormat:@"%@/user/userLogin.action",BASEURL];
    NSDictionary *loginParams = @{@"userName":account,@"userPwd":password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:loginUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
            NSInteger userState = [[userDictInfo objectForKey:@"userState"] integerValue];
            if (userState == 0) {
                [self showHint:@"当前用户不可用"];
                return ;
            }
            NSString *userDataPath = [Tool getUserDataPath];
            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
            BOOL succeed = [@{@"user":respondString} writeToFile:userFileName atomically:YES];
            if (succeed) {
                NSLog(@"用户资料写入成功");
            }
            User *user = [[User alloc] initUserWithDict:userDictInfo];
            [HeSysbsModel getSysModel].user = user;
            NSString *userId = [HeSysbsModel getSysModel].user.userId;
            if (userId == nil) {
                userId = @"";
            }
            [[NSUserDefaults standardUserDefaults] setObject:account forKey:USERACCOUNTKEY];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:USERPASSWORDKEY];
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:USERIDKEY];
            User *userInfo = [[User alloc] initUserWithDict:userDictInfo];
            [HeSysbsModel getSysModel].user = userInfo;
            
            //发送自动登陆状态通知
            [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@YES];
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"登录失败!";
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (IBAction)findPassword:(id)sender
{
    
}

- (IBAction)quickLogin:(id)sender
{

}

- (IBAction)thirdPartyLogin:(UIButton *)sender
{

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
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
