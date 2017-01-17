//
//  HeUserNewJoinCell.h
//  beautyContest
//
//  Created by Tony on 2017/1/17.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeUserNewJoinCell : HeBaseTableViewCell
@property(strong,nonatomic)UIView *bgView;
@property(strong,nonatomic)UIView *infoView;
@property(strong,nonatomic)UIImageView *bgImage;
@property(strong,nonatomic)UIImageView *detailImage;
@property(strong,nonatomic)UILabel *topicLabel;
@property(strong,nonatomic)UILabel *tipLabel;
@property(strong,nonatomic)UILabel *timeLabel;

@property(strong,nonatomic)UILabel *distanceTimeLabel;

@property(strong,nonatomic)UIButton *distributeButton;
@property(strong,nonatomic)NSDictionary *contestInfo;

@end
