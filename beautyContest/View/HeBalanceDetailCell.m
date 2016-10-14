//
//  HeBalanceDetailCell.m
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBalanceDetailCell.h"

@implementation HeBalanceDetailCell
@synthesize moneyLabel;
@synthesize contentLabel;
@synthesize timeLabel;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        
        UIFont *bigFont = [UIFont systemFontOfSize:17.0];
        CGFloat contentX = 10;
        CGFloat contentY = 10;
        CGFloat contentW = (SCREENWIDTH - 2 * contentX) / 2.0;
        CGFloat contentH = 30;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentLabel.numberOfLines = 0;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.text = @"abc";
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:contentLabel];
        contentLabel.font = bigFont;
        
        UIFont *smallFont = [UIFont systemFontOfSize:15.0];
        
        CGFloat timeY = contentY;
        CGFloat timeW = (SCREENWIDTH - 2 * contentX) / 2.0;
        CGFloat timeX = SCREENWIDTH - 10 - timeW;
        CGFloat timeH = 30;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:timeLabel];
        timeLabel.font = smallFont;
        
        
        CGFloat userY = CGRectGetMaxY(timeLabel.frame);
        CGFloat userW = (SCREENWIDTH - 2 * contentX) / 2.0;
        CGFloat userX = SCREENWIDTH - userW - contentX;
        CGFloat userH = 30;
        moneyLabel = [[UILabel alloc] initWithFrame:CGRectMake(userX, userY, userW, userH)];
        moneyLabel.textAlignment = NSTextAlignmentRight;
        moneyLabel.backgroundColor = [UIColor clearColor];
        moneyLabel.text = @"-10.00";
        moneyLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:moneyLabel];
        moneyLabel.font = smallFont;
    }
    return self;
}

@end
