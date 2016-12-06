//
//  HeUserMessageCell.m
//  beautyContest
//
//  Created by Tony on 16/10/13.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeMyMessageCell.h"

@implementation HeMyMessageCell
@synthesize messageDict;
@synthesize userNameLabel;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize tipLabel;
@synthesize replyLabel;
@synthesize userIcon;

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
        UIFont *smallFont = [UIFont systemFontOfSize:13.0];
        
        CGFloat tipX = 10;
        CGFloat tipY = 5;
        CGFloat tipW = 40;
        CGFloat tipH = 30;
        tipLabel = [[MLLinkLabel alloc] initWithFrame:CGRectMake(tipX, tipY, tipW, tipH)];
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"留言给";
        tipLabel.textColor = [UIColor grayColor];
//        [self.contentView addSubview:tipLabel];
        tipLabel.font = smallFont;
        
        CGFloat userIconX = 10;
        CGFloat userIconY = 10;
        CGFloat userIconW = 30;
        CGFloat userIconH = 30;
        
        userIcon = [[UIImageView alloc] initWithFrame:CGRectMake(userIconX, userIconY, userIconW, userIconH)];
        userIcon.layer.masksToBounds = YES;
        userIcon.layer.cornerRadius = userIconW / 2.0;
        userIcon.contentMode = UIViewContentModeScaleAspectFill;
        userIcon.image = [UIImage imageNamed:@"userDefalut_icon"];
        [self.contentView addSubview:userIcon];
        
        CGFloat userX = CGRectGetMaxX(userIcon.frame) + 5;
        CGFloat userY = tipY;
        CGFloat userW = 150;
        CGFloat userH = tipH;
        userNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(userX, userY, userW, userH)];
        userNameLabel.backgroundColor = [UIColor clearColor];
        userNameLabel.text = @"李四";
        userNameLabel.textColor = APPDEFAULTORANGE;
        [self.contentView addSubview:userNameLabel];
        userNameLabel.font = smallFont;
        
        
        
        CGFloat timeY = tipY;
        CGFloat timeW = 150;
        CGFloat timeX = SCREENWIDTH - 10 - timeW;
        CGFloat timeH = tipH;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016";
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:timeLabel];
        timeLabel.font = smallFont;
        
        UIFont *bigFont = [UIFont systemFontOfSize:15.0];
        CGFloat contentX = userX;
        CGFloat contentY = CGRectGetMaxY(tipLabel.frame);
        CGFloat contentW = SCREENWIDTH - 10 - 50;
        CGFloat contentH = tipH;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentLabel.numberOfLines = 0;
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.text = @"abc";
        contentLabel.textAlignment = NSTextAlignmentLeft;
        contentLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:contentLabel];
        contentLabel.font = bigFont;
        
        CGFloat messageIconW = 12;
        CGFloat messageIconH = 12;
        CGFloat messageIconX = 0;
        CGFloat messageIconY = 0;
        UIImageView *messageIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_message_black"]];
        messageIcon.frame = CGRectMake(messageIconX, messageIconY, messageIconW, messageIconH);
        
        CGFloat replyH = messageIconH;
        CGFloat replyY = cellsize.height - messageIconH - 10;
        CGFloat replyW = 45;
        CGFloat replyX = SCREENWIDTH - replyW - 10;
        
        replyLabel = [[UILabel alloc] initWithFrame:CGRectMake(replyX, replyY, replyW, replyH)];
        replyLabel.backgroundColor = [UIColor clearColor];
        replyLabel.text = @"回复";
        replyLabel.font = [UIFont systemFontOfSize:13.5];
        replyLabel.textAlignment = NSTextAlignmentRight;
        replyLabel.textColor = [UIColor grayColor];
        [self.contentView addSubview:replyLabel];
        replyLabel.font = smallFont;
        
        [replyLabel addSubview:messageIcon];
        self.userInteractionEnabled = YES;
        replyLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *replyTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(replyMessage:)];
        replyTap.numberOfTapsRequired = 1;
        replyTap.numberOfTouchesRequired = 1;
        [replyLabel addGestureRecognizer:replyTap];
    }
    
    return self;
}

- (void)replyMessage:(UITapGestureRecognizer *)tap
{
    [super routerEventWithName:@"replyMessage" userInfo:messageDict];
}

- (void)drawRect:(CGRect)rect
{
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    //上分割线，
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, -1, rect.size.width, 1));
    
    //下分割线
    CGContextSetStrokeColorWithColor(context, ([UIColor colorWithRed:237.0 / 255.0 green:237.0 / 255.0 blue:237.0 / 255.0 alpha:1.0]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

@end
