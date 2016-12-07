//
//  HeNewUserInfoVC.h
//  beautyContest
//
//  Created by Tony on 2016/12/7.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "User.h"

@interface HeNewUserInfoVC : HeBaseViewController
@property(strong,nonatomic)User *userInfo;
@property(assign,nonatomic)BOOL isScanUser;

@end
