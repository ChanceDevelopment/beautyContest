//
//  HeUserMessageCell.h
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"
#import "MLLinkLabel.h"

@interface HeUserMessageCell : HeBaseTableViewCell
@property(strong,nonatomic)NSDictionary *messageDict;
@property(strong,nonatomic)UILabel *userNameLabel;
@property(strong,nonatomic)UILabel *contentLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)MLLinkLabel *tipLabel;
@property(strong,nonatomic)UILabel *replyLabel;

@end
