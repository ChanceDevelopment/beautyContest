//
//  HeNewRecommendCell.h
//  beautyContest
//
//  Created by Danertu on 16/10/28.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeNewRecommendCell : HeBaseTableViewCell
@property(strong,nonatomic)UIView *bgView;
@property(strong,nonatomic)UIView *infoView;
@property(strong,nonatomic)UIImageView *bgImage;
@property(strong,nonatomic)UIImageView *detailImage;
@property(strong,nonatomic)UILabel *topicLabel;
@property(strong,nonatomic)UILabel *tipLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UIButton *favButton;
@property(strong,nonatomic)UIButton *commentButton;
@property(strong,nonatomic)NSDictionary *recommentDict;

@end
