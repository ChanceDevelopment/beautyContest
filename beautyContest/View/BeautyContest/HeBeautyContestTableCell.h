//
//  HeBeautyContestTableCell.h
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeBeautyContestTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UIView *bgView;
@property(strong,nonatomic)UIView *infoView;
@property(strong,nonatomic)UIImageView *bgImage;
@property(strong,nonatomic)UIImageView *detailImage;
@property(strong,nonatomic)UILabel *topicLabel;
@property(strong,nonatomic)UILabel *tipLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UIButton *distributeButton;
@property(strong,nonatomic)NSDictionary *contestInfo;

@end
