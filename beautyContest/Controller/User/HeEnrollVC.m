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

@interface HeEnrollVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *acountField;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;
@property(strong,nonatomic)IBOutlet UITextField *nicknameField;
@property(strong,nonatomic)IBOutlet UITextField *verifyField;
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;

@end

@implementation HeEnrollVC
@synthesize acountField;
@synthesize passwordField;
@synthesize nicknameField;
@synthesize verifyField;
@synthesize getCodeButton;
@synthesize commitButton;

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

- (IBAction)getCodeButtonClick:(id)sender
{
    
}

- (IBAction)commitButtonClick:(id)sender
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
            [self loginMethod];
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

- (void)loginMethod
{
    NSString *account = acountField.text;
    NSString *password = passwordField.text;
    
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
            
            [[NSUserDefaults standardUserDefaults] setObject:account forKey:USERACCOUNTKEY];
            [[NSUserDefaults standardUserDefaults] setObject:password forKey:USERPASSWORDKEY];
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
