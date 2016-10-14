//
//  HeUserReplyCell.h
//  beautyContest
//
//  Created by Tony on 16/10/14.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeUserReplyCell : HeBaseTableViewCell
@property(strong,nonatomic)NSDictionary *replyDict;
@property(strong,nonatomic)UILabel *userNameLabel;
@property(strong,nonatomic)UILabel *contentLabel;
@property(strong,nonatomic)UILabel *timeLabel;

@end
