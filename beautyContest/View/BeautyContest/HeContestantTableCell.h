//
//  HeContestantTableCell.h
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"


@interface HeContestantTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UILabel *rankLabel;
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *distanceLabel;
@property(strong,nonatomic)UILabel *signLabel;
@property(strong,nonatomic)UIButton *favButton;
@property(strong,nonatomic)UIButton *noFavButton;

@property(strong,nonatomic)UILabel *prizeMoneyLabel;

@property(strong,nonatomic)NSDictionary *userInfo;

@end
