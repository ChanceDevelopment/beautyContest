//
//  HeModifyPasswordVC.h
//  huobao
//
//  Created by HeDongMing on 14-7-16.
//  Copyright (c) 2014年 何 栋明. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeBaseViewController.h"


@interface HeModifyPasswordVC : HeBaseViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property(strong,nonatomic)IBOutlet UIButton *loginButton;
@property(strong,nonatomic)IBOutlet UITextField *pswTF;
@property(strong,nonatomic)IBOutlet UITextField *cpswTF;
@property(strong,nonatomic)IBOutlet UITextField *commitpswTF;
@property(assign,nonatomic)int loadSucceedFlag;

-(IBAction)loginButtonClick:(id)sender;

@end
