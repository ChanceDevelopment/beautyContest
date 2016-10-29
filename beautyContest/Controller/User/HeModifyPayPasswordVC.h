//
//  HeModifyPayPasswordVC.h
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HeBaseViewController.h"


@interface HeModifyPayPasswordVC : HeBaseViewController<UITextFieldDelegate,UIAlertViewDelegate>

@property(strong,nonatomic)IBOutlet UIButton *loginButton;
@property(strong,nonatomic)IBOutlet UITextField *pswTF;
@property(strong,nonatomic)IBOutlet UITextField *cpswTF;
@property(strong,nonatomic)IBOutlet UITextField *commitpswTF;
@property(assign,nonatomic)int loadSucceedFlag;
@property(strong,nonatomic)NSDictionary *balanceDict;

-(IBAction)loginButtonClick:(id)sender;

@end
