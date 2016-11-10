//
//  HeEditUserInfoVC.h
//  beautyContest
//
//  Created by HeDongMing on 16/9/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"

@interface HeEditUserInfoVC : HeBaseViewController<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property(strong,nonatomic)User *userInfo;

@end
