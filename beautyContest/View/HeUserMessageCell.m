//
//  HeUserMessageCell.m
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserMessageCell.h"

@implementation HeUserMessageCell
@synthesize userNameLabel;
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
        UIFont *smallFont = [UIFont systemFontOfSize:16.0];
        
        CGFloat tipX = 10;
        CGFloat tipY = 10;
        CGFloat tipW = 30;
        CGFloat tipH = 30;
        UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipX, tipY, tipW, tipH)];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"留言给";
        tipLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:tipLabel];
        tipLabel.font = smallFont;
        
        CGFloat userX = CGRectGetMaxX(tipLabel.frame) + 5;
        CGFloat userY = tipY;
        CGFloat userW = 150;
        CGFloat userH = tipH;
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(userX, userY, userW, userH)];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.text = @"李四";
        userNameLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:userNameLabel];
        userNameLabel.font = smallFont;
        
        
        CGFloat timeY = tipY;
        CGFloat timeW = 100;
        CGFloat timeX = SCREENWIDTH - 10 - timeW;
        CGFloat timeH = tipH;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:timeLabel];
        timeLabel.font = smallFont;
        
        UIFont *bigFont = [UIFont systemFontOfSize:18.0];
        CGFloat contentX = CGRectGetMaxX(tipLabel.frame) + 5;
        CGFloat contentY = tipY;
        CGFloat contentW = 100;
        CGFloat contentH = tipH;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentLabel.numberOfLines = 0;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.text = @"abc";
        contentLabel.textAlignment = NSTextAlignmentRight;
        contentLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:contentLabel];
        contentLabel.font = bigFont;
        
    }
    
    return self;
}

@end
