//
//  HeBalanceEditVC.m
//  beautyContest
//
//  Created by Tony on 16/10/8.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBalanceEditVC.h"
#import "UIButton+Bootstrap.h"

@interface HeBalanceEditVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *editField;
@property(strong,nonatomic)IBOutlet UIButton *commitButton;
@property(strong,nonatomic)IBOutlet UILabel *tipLabel;

@end

@implementation HeBalanceEditVC
@synthesize banlanceType;
@synthesize editField;
@synthesize commitButton;
@synthesize maxWithDrawMoney;
@synthesize tipLabel;
@synthesize balanceDict;

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
    // Custom initialization
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = APPDEFAULTTITLETEXTFONT;
    label.textColor = APPDEFAULTTITLECOLOR;
    label.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = label;
    
    editField.layer.borderColor = [UIColor grayColor].CGColor;
    editField.layer.borderWidth = 1.0;
    editField.layer.masksToBounds = YES;
    editField.layer.cornerRadius = 5.0;
    
    [commitButton dangerStyle];
    commitButton.layer.borderWidth = 0;
    commitButton.layer.borderColor = [UIColor clearColor].CGColor;
    [commitButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:commitButton.frame.size] forState:UIControlStateNormal];
    
    tipLabel.hidden = YES;
    
    switch (banlanceType) {
        case Balance_Edit_Recharge:
        {
            label.text = @"充值";
            [label sizeToFit];
            self.title = @"充值";
            editField.placeholder = @"建议转入100元以上";
            editField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case Balance_Edit_Withdraw:
        {
            label.text = @"提现";
            [label sizeToFit];
            self.title = @"提现";
            editField.placeholder = [NSString stringWithFormat:@"本次最多可提现%.2f元",maxWithDrawMoney];
            tipLabel.hidden = NO;
            editField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case Balance_Edit_BindAccount:
        {
            NSString *apliPayAccount = [balanceDict objectForKey:@"userAlipay"];
            if ([apliPayAccount isMemberOfClass:[NSNull class]] || apliPayAccount == nil) {
                apliPayAccount = nil;
            }
            label.text = @"绑定账号";
            [label sizeToFit];
            self.title = @"绑定账号";
            editField.placeholder = @"绑定账号";
            editField.text = apliPayAccount;
            break;
        }
        default:
            break;
    }
    
    
}

- (IBAction)commitButtonClick:(id)sender
{
    NSLog(@"commitButtonClick");
    switch (banlanceType) {
        case Balance_Edit_Recharge:
        {
            
            break;
        }
        case Balance_Edit_Withdraw:
        {
            
            break;
        }
        case Balance_Edit_BindAccount:
        {
            NSString *alipayAccount = editField.text;
            if (alipayAccount == nil || [alipayAccount isEqualToString:@""]) {
                [self showHint:@"请输入支付宝账号"];
                return;
            }
            [self modifyAlipayAccount:alipayAccount];
            break;
        }
        default:
            break;
    }
}

//充值
- (void)rechargeMoney:(CGFloat)money
{

}

//提现
- (void)withDrawMoney:(CGFloat)money
{

}

//绑定支付宝账号
- (void)modifyAlipayAccount:(NSString *)account
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/money/bindingAlipay.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    
    NSDictionary *requestMessageParams = @{@"userId":userId,@"userAlipay":account};
    [self showHudInView:self.view hint:@"正在绑定..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        NSString *data = [respondDict objectForKey:@"data"];
        if ([data isMemberOfClass:[NSNull class]] || data == nil) {
            data = ERRORREQUESTTIP;
        }
        [self showHint:data];
        if (statueCode == REQUESTCODE_SUCCEED){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"modifyAlipayAccountSucceed" object:nil];
            [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.2];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)backToLastView
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
