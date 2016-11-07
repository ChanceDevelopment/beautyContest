//
//  HeUserTicketCell.h
//  beautyContest
//
//  Created by HeDongMing on 2016/11/8.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeUserTicketCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userHeadImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *signLabel;
@property(strong,nonatomic)UILabel *timeLabel;

@end
