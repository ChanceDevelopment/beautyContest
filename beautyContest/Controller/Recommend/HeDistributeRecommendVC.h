//
//  HeDistributeRecommendVC.h
//  beautyContest
//
//  Created by HeDongMing on 16/8/24.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "DeleteImageProtocol.h"

@protocol DistributeProtocol <NSObject>

- (void)distributeSucceed;

@end

@interface HeDistributeRecommendVC : HeBaseViewController<DeleteImageProtocol,UITextViewDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>

@end
