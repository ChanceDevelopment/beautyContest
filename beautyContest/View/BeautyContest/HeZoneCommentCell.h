//
//  HeZoneCommentCell.h
//  beautyContest
//
//  Created by HeDongMing on 16/8/26.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseTableViewCell.h"

@interface HeZoneCommentCell : HeBaseTableViewCell
@property(strong,nonatomic)UIImageView *bgImage;
@property(strong,nonatomic)UILabel *topicLabel;
@property(strong,nonatomic)UILabel *timeLabel;
@property(strong,nonatomic)UILabel *addressLabel;
@property(strong,nonatomic)UIButton *deleteButton;
@property(strong,nonatomic)NSDictionary *commentDict;

@end
