//
//  HeForgetPayPasswordVC.m
//  beautyContest
//
//  Created by Tony on 2017/2/21.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeForgetPayPasswordVC.h"
#import "UIButton+countDown.h"

@interface HeForgetPayPasswordVC ()<UITextFieldDelegate,UIAlertViewDelegate>
@property(strong,nonatomic)IBOutlet UIButton *getCodeButton;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;
@property(strong,nonatomic)IBOutlet UITextField *verifyField;
@property(strong,nonatomic)IBOutlet UIButton *modifyPasswordButton;
@property(strong,nonatomic)IBOutlet UITextField *passwordField;

@property(strong,nonatomic)IBOutlet UILabel *tipLabel;

@end

@implementation HeForgetPayPasswordVC
@synthesize getCodeButton;
@synthesize commitButton;
@synthesize verifyField;
@synthesize modifyPasswordButton;
@synthesize passwordField;
@synthesize tipLabel;

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
        label.text = @"支付密码";
        [label sizeToFit];
        
        self.title = @"支付密码";
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
    commitButton.layer.cornerRadius = 3.0;
    modifyPasswordButton.layer.cornerRadius = 3.0;
}

- (void)initView
{
    [super initView];
    
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (phone == nil) {
        phone = @"";
    }
    tipLabel.text = [NSString stringWithFormat:@"请将注册手机号 %@ 收到的验证码填写到下面输入框中",phone];
}

- (IBAction)modifyPassword:(id)sender
{
    if ([passwordField isFirstResponder]) {
        [passwordField resignFirstResponder];
    }
    NSString *passWord = passwordField.text;
    if ([passWord isEqualToString:@""] || passWord == nil) {
        [self showHint:@"请输入密码"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (phone == nil) {
        phone = @"";
    }
    NSDictionary * params  = @{@"userId":userId,@"newPayPswd":passWord};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/money/ResetPaysetPassword.action",BASEURL];
    [self showHudInView:self.view hint:@"重置中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"支付密码重置成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (IBAction)getCodeButtonClick:(id)sender
{
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (phone == nil) {
        phone = @"";
    }
    
    [sender startWithTime:60 title:@"获取验证码" countDownTitle:@"s" mainColor:[UIColor whiteColor] countColor:[UIColor whiteColor]];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary * params  = @{@"userId":userId};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/user/sendSmsWithdrawalsPassword.action",BASEURL];
    [self showHudInView:self.view hint:@"发送中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self showHint:@"验证码发送成功"];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (IBAction)verifyCode:(id)sender
{
    if ([verifyField isFirstResponder]) {
        [verifyField resignFirstResponder];
    }
    NSString *phone = [[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY];
    if (phone == nil) {
        phone = @"";
    }
    NSString *code = verifyField.text;
    if ([code isEqualToString:@""] || code == nil) {
        [self showHint:@"请输入验证码"];
        return;
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *Passwordcode = code;
    NSDictionary * params  = @{@"withdrawalsCode":Passwordcode};
    NSString *requestUrl = [NSString stringWithFormat:@"%@/money/ResetPaymentPasswordComparison.action",BASEURL];
    [self showHudInView:self.view hint:@"验证中..."];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestUrl params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [NSDictionary dictionaryWithDictionary:[respondString objectFromJSONString]];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            commitButton.hidden = YES;
            modifyPasswordButton.hidden = NO;
            
            verifyField.hidden = YES;
            passwordField.hidden = NO;
            
            tipLabel.hidden = YES;
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError* err){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
