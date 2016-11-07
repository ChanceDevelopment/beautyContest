//
//  HeUserTicketCell.m
//  beautyContest
//
//  Created by HeDongMing on 2016/11/8.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserTicketCell.h"

@implementation HeUserTicketCell
@synthesize userHeadImage;
@synthesize nameLabel;
@synthesize signLabel;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat imageX = 10;
        CGFloat imageY = 20;
        CGFloat imageH = cellsize.height - 2 * imageY;
        CGFloat imageW = imageH;
        
        
        userHeadImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userHeadImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        userHeadImage.layer.masksToBounds = YES;
        userHeadImage.layer.cornerRadius = imageW / 2.0;
        userHeadImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:userHeadImage];
        
        imageY = 5;
        
        CGFloat labelX = CGRectGetMaxX(userHeadImage.frame) + 10;
        CGFloat labelW = SCREENWIDTH - labelX - imageX;
        CGFloat labelY = imageY;
        CGFloat labelH = (cellsize.height - 2 * imageY) / 3.0;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];
        
        labelY = CGRectGetMaxY(nameLabel.frame);
        signLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        signLabel.backgroundColor = [UIColor clearColor];
        signLabel.font = [UIFont systemFontOfSize:15.0];
        signLabel.textColor = [UIColor grayColor];
        signLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:signLabel];
        
        labelY = CGRectGetMaxY(signLabel.frame);
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:15.0];
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:timeLabel];
        
        
        
    }
    return self;
}

@end
