//
//  HeNearbyTableCell.h
//  beautyContest
//
//  Created by Tony on 16/8/3.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeNearbyTableCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *userImage;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *distanceLabel;
@property(strong,nonatomic)UILabel *signLabel;

@end
