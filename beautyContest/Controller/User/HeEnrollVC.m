//
//  HeEnrollVC.m
//  kunyuan
//
//  Created by HeDongMing on 16/6/16.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeEnrollVC.h"
#import "UIButton+Bootstrap.h"
#import "User.h"
#import "UIButton+Bootstrap.h"
#import <SMS_SDK/SMSSDK.h>
#import "BrowserView.h"

@interface HeEnrollVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *acountField;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UITextField *nicknameField;
@property(strong,nonatomic)IBOutlet UITextField *verifyField;
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;
@property(strong,nonatomic)IBOutlet UILabel *protocolLabel;

@end

@implementation HeEnrollVC
@synthesize acountField;
@synthesize passwordField;
@synthesize nicknameField;
@synthesize verifyField;
@synthesize getCodeButton;
@synthesize commitButton;
@synthesize protocolLabel;

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
        label.text = @"注册";
        [label sizeToFit];
        self.title = @"注册";
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
    
    [getCodeButton dangerStyle];
    getCodeButton.layer.borderWidth = 0;
    getCodeButton.layer.borderColor = [UIColor clearColor].CGColor;
    [getCodeButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:getCodeButton.frame.size] forState:UIControlStateNormal];
    [getCodeButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
    
    [commitButton dangerStyle];
    commitButton.layer.borderWidth = 0;
    commitButton.layer.borderColor = [UIColor clearColor].CGColor;
    [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
    
    UIView *accountView = [[UIView alloc]init];
    accountView.frame = CGRectMake(10, 10, 20, 20);
    [acountField setLeftView:accountView];
    acountField.layer.borderColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0].CGColor;
    acountField.layer.cornerRadius = 5.0;
    acountField.layer.masksToBounds = YES;
    acountField.layer.borderWidth = 1.0;
    
    UIView *nicknameView = [[UIView alloc]init];
    nicknameView.frame = CGRectMake(10, 10, 20, 20);
    [nicknameField setLeftView:nicknameView];
    nicknameField.layer.borderColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0].CGColor;
    nicknameField.layer.cornerRadius = 5.0;
    nicknameField.layer.masksToBounds = YES;
    nicknameField.layer.borderWidth = 1.0;
    
    UIView *passwordView = [[UIView alloc]init];
    passwordView.frame = CGRectMake(10, 10, 20, 20);
    [passwordField setLeftView:passwordView];
    passwordField.layer.borderColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0].CGColor;
    passwordField.layer.cornerRadius = 5.0;
    passwordField.layer.masksToBounds = YES;
    passwordField.layer.borderWidth = 1.0;
}

//取消输入
- (IBAction)cancelInputTap:(id)sender
{
    if ([acountField isFirstResponder]) {
        [acountField resignFirstResponder];
    }
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    if ([nicknameField isFirstResponder]) {
        [nicknameField resignFirstResponder];
    }
}

- (IBAction)getCodeButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *userPhone = acountField.text;
    if ((userPhone == nil || [userPhone isEqualToString:@""])) {
        [self showHint:@"请输入手机号"];
        return;
    }
    if (![Tool isMobileNumber:userPhone]) {
        [self showHint:@"请输入正确的手机号"];
        return;
    }
    
//    [self myTimer];
//    return;
    //获取注册手机号的验证码
    NSString *zone = @"86"; //区域号
    NSString *phoneNumber = acountField.text;
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber
                                   zone:zone
                       customIdentifier:nil
                                 result:^(NSError *error)
     {
         [self hideHud];
         if (!error)
         {
             [self showHint:@"验证码已发送，请注意查收!"];
         }
         else
         {
             NSString *errorString = [NSString stringWithFormat:@"错误描述：%@",[error.userInfo objectForKey:@"getVerificationCode"]];
             [self showHint:errorString];
         }
     }];
}

- (IBAction)userProtocol:(id)sender
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"userProtocol" ofType:@"html"];
    BrowserView *browserView = [[BrowserView alloc] initWithURL:path];
    browserView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:browserView animated:YES];
}

- (IBAction)commitButtonClick:(id)sender
{
    [self cancelInputTap:nil];
    NSString *userPhone = acountField.text;
    NSString *verifyCode = nicknameField.text;
    if (userPhone == nil || [userPhone isEqualToString:@""]) {
        [self showHint:@"请输入注册手机号"];
        return;
    }
    if (![Tool isMobileNumber:userPhone]) {
        [self showHint:@"输入的手机号格式有误"];
        return;
    }
    if (verifyCode == nil || [verifyCode isEqualToString:@""]) {
        [self showHint:@"请输入手机验证码"];
        return;
    }
    //用户输入的手机验证码
    //    [self showHudInView:self.view hint:@"验证中..."];
    NSString *zone = @"86"; //区域号
    
    [SMSSDK commitVerificationCode:verifyCode phoneNumber:userPhone zone:zone result:^(SMSSDKUserInfo *userInfo, NSError *error) {
        [self hideHud];
        if (error) {
            [self showHint:@"验证码有误"];
        }
        else{
            //验证码验证成功
            [self registerUser];
        }
    }];
}

- (void)registerUser
{
    NSString *account = acountField.text;
    NSString *password = passwordField.text;
    NSString *userNick = nicknameField.text;
    if ([acountField isFirstResponder]) {
        [acountField resignFirstResponder];
    }
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    if ([nicknameField isFirstResponder]) {
        [nicknameField resignFirstResponder];
    }
    if (account == nil || [account isEqualToString:@""]) {
        [self showHint:@"请输入注册手机号"];
        return;
    }
    if (account == nil || [account isEqualToString:@""]) {
        [self showHint:@"请输入用户昵称"];
        return;
    }
    if (password == nil || [password isEqualToString:@""]) {
        [self showHint:@"请输入用户密码"];
        return;
    }
    if (![Tool isMobileNumber:account]) {
        [self showHint:@"请输入正确的手机号"];
        return;
    }
    
    [self showHudInView:self.view hint:@"注册中..."];
    NSString *enrollUrl = [NSString stringWithFormat:@"%@/user/createNewUser.action",BASEURL];
    NSDictionary *loginParams = @{@"userName":account,@"userPwd":password,@"userNick":userNick};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:enrollUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        //        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self showHint:@"注册成功"];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.3];
        }
        else{
            [self hideHud];
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"注册失败!";
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//我的倒计时
-(void)myTimer
{
    __block int timeout = 60; //倒计时时间
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout<=0){ //倒计时结束，关闭
            dispatch_source_cancel(_timer);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [getCodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                getCodeButton.layer.borderColor = [[UIColor colorWithRed:214.0/255.0 green:155.0/255.0 blue:157.0/255.0 alpha:1.0] CGColor];
                
                [getCodeButton setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
                getCodeButton.layer.borderColor = [[UIColor colorWithRed:214.0/255.0 green:155.0/255.0 blue:157.0/255.0 alpha:1.0] CGColor];
                
                [getCodeButton setTitleColor:[UIColor redColor] forState:UIControlStateSelected];
                getCodeButton.layer.borderColor = [[UIColor colorWithRed:214.0/255.0 green:155.0/255.0 blue:157.0/255.0 alpha:1.0] CGColor];
                
                self.getCodeButton.enabled = YES;
                [self.getCodeButton setTitle:@"重  发" forState:UIControlStateNormal];
            });
        }else{
            self.getCodeButton.enabled = NO;
            
            int seconds = timeout % 60;
            if (seconds == 0) {
                seconds = 60;
            }
            NSString *strTime = [NSString stringWithFormat:@"%d秒",seconds];
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                [self.getCodeButton setTitle:strTime forState:UIControlStateNormal];
                [self.getCodeButton setTitle:strTime forState:UIControlStateHighlighted];
                [self.getCodeButton setTitle:strTime forState:UIControlStateSelected];
                [self.getCodeButton setTitle:strTime forState:UIControlStateDisabled];
                
//                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
//                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
//                
//                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
//                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
//                
//                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
//                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
//                
//                [getCodeButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//                getCodeButton.layer.borderColor = [[UIColor grayColor] CGColor];
                
            });
            timeout--;
            
        }
    });
    dispatch_resume(_timer);
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
