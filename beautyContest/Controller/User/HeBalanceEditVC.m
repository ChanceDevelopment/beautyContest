//
//  HeBalanceEditVC.m
//  beautyContest
//
//  Created by Tony on 16/10/8.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBalanceEditVC.h"

@interface HeBalanceEditVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *editField;

@end

@implementation HeBalanceEditVC
@synthesize banlanceType;
@synthesize editField;


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
    editField.layer.masksToBounds = YES;
    editField.layer.cornerRadius = 3.0;
    
    switch (banlanceType) {
        case Balance_Edit_Recharge:
        {
            label.text = @"充值";
            [label sizeToFit];
            self.title = @"充值";
            editField.placeholder = @"充值";
            editField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case Balance_Edit_Withdraw:
        {
            label.text = @"提现";
            [label sizeToFit];
            self.title = @"提现";
            editField.placeholder = @"提现";
            editField.keyboardType = UIKeyboardTypeNumberPad;
            break;
        }
        case Balance_Edit_BindAccount:
        {
            label.text = @"绑定账号";
            [label sizeToFit];
            self.title = @"绑定账号";
            editField.placeholder = @"绑定账号";
            break;
        }
        default:
            break;
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
