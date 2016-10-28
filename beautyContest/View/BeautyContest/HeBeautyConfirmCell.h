//
//  HeBeautyConfirmCell.h
//  beautyContest
//
//  Created by HeDongMing on 2016/10/25.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeBeautyConfirmCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *contentLabel;
@property(strong,nonatomic)UIButton *agreeButton;
@property(strong,nonatomic)UIButton *rejectButton;
@property(strong,nonatomic)NSDictionary *confirmDict;
@property(strong,nonatomic)UILabel *stateLabel;

@end
