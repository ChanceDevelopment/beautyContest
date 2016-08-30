//
//  HeUserFollowTableCell.h
//  beautyContest
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeUserFollowTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userHeadImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *signLabel;
@property(strong,nonatomic)UIButton *followButton;

@property(strong,nonatomic)NSDictionary *userInfo;

@end
