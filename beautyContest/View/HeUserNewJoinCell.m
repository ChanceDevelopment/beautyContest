//
//  HeUserNewJoinCell.m
//  beautyContest
//
//  Created by Tony on 2017/1/17.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HeUserNewJoinCell.h"

@implementation HeUserNewJoinCell
@synthesize bgImage;
@synthesize detailImage;
@synthesize topicLabel;
@synthesize tipLabel;
@synthesize bgView;
@synthesize infoView;
@synthesize timeLabel;
@synthesize distributeButton;
@synthesize contestInfo;
@synthesize distanceTimeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        
        
        CGFloat viewX = 10;
        CGFloat viewY = 10;
        CGFloat viewW = SCREENWIDTH - 2 * viewX;
        CGFloat viewH = cellsize.height - 2 * viewY;
        
        bgView = [[UIView alloc] initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
        bgView.backgroundColor = [UIColor whiteColor];
        bgView.layer.cornerRadius = 5.0;
        bgView.layer.masksToBounds = YES;
        [self addSubview:bgView];
        
        CGFloat imageX = 0;
        CGFloat imageY = 70;
        CGFloat imageW = viewW;
        CGFloat imageH = viewH - imageY;
        
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index5.jpg"]];
        bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        bgImage.layer.cornerRadius = 5.0;
        bgImage.layer.masksToBounds = YES;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:bgImage];
        
        CGFloat buttonW = 70;
        CGFloat buttonH = 35;
        CGFloat buttonX = imageW - buttonW;
        CGFloat buttonY = imageH - buttonH;
        
        distributeButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        [distributeButton setTitle:@"再次发布" forState:UIControlStateNormal];
        [distributeButton setBackgroundColor:[UIColor redColor]];
        [distributeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        distributeButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [distributeButton addTarget:self action:@selector(distributeContest:) forControlEvents:UIControlEventTouchUpInside];
        distributeButton.hidden = YES;
        [bgImage addSubview:distributeButton];
        
        CGFloat detailImageW = 40;
        CGFloat detailImageH = 40;
        CGFloat detailImageX = 5;
        CGFloat detailImageY = 5;
        
        detailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index4.jpg"]];
        detailImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
        detailImage.layer.cornerRadius = detailImageW / 2.0;
        detailImage.layer.masksToBounds = YES;
        detailImage.layer.borderWidth = 1.0;
        detailImage.layer.borderColor = [UIColor whiteColor].CGColor;
        detailImage.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:detailImage];
        
        UIFont *textFont = [UIFont systemFontOfSize:16.0];
        CGFloat infoHeight = 50;
        
        CGFloat titleX = CGRectGetMaxX(detailImage.frame) + 5;
        CGFloat titleY = 5;
        CGFloat titleH = infoHeight - 2 * titleY;
        CGFloat titleW = viewW / 2.0 - titleX + 20;
        
        topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = @"主题";
        topicLabel.numberOfLines = 2;
        topicLabel.textColor = [UIColor blackColor];
        topicLabel.font = [UIFont systemFontOfSize:13.5];
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [bgView addSubview:topicLabel];
        
        
        
        CGFloat tiptitleX = CGRectGetMaxX(topicLabel.frame);
        CGFloat tiptitleY = 5;
        CGFloat tiptitleH = (infoHeight - 2 * tiptitleY) / 2.0;
        CGFloat tiptitleW = viewW - CGRectGetMaxX(topicLabel.frame) - 5;
        
        tipLabel = [[UILabel alloc] init];
        tipLabel.textAlignment = NSTextAlignmentRight;
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"￥2000";
        tipLabel.numberOfLines = 1;
        tipLabel.textColor = [UIColor orangeColor];
        tipLabel.font = [UIFont systemFontOfSize:13.5];
        tipLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
        [bgView addSubview:tipLabel];
        
        CGFloat timeX = CGRectGetMaxX(topicLabel.frame);
        CGFloat timeY = CGRectGetMaxY(tipLabel.frame);
        CGFloat timeH = (infoHeight - 2 * tiptitleY) / 2.0;
        CGFloat timeW = viewW - CGRectGetMaxX(topicLabel.frame) - 5;
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016-10-28";
        timeLabel.numberOfLines = 1;
        timeLabel.textColor = [UIColor grayColor];
        timeLabel.font = [UIFont systemFontOfSize:12.0];
        timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
        [bgView addSubview:timeLabel];
        
        timeY = CGRectGetMaxY(timeLabel.frame);
        distanceTimeLabel = [[UILabel alloc] init];
        distanceTimeLabel.textAlignment = NSTextAlignmentRight;
        distanceTimeLabel.backgroundColor = [UIColor clearColor];
        distanceTimeLabel.text = @"7天后赛区截止";
        distanceTimeLabel.numberOfLines = 1;
        distanceTimeLabel.textColor = [UIColor redColor];
        distanceTimeLabel.font = [UIFont systemFontOfSize:12.0];
        distanceTimeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
        [bgView addSubview:distanceTimeLabel];
        
        
    }
    return self;
}

- (void)distributeContest:(UIButton *)button
{
    [self routerEventWithName:@"distributeContestAgain" userInfo:contestInfo];
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
    CGContextSetStrokeColorWithColor(context, ([UIColor clearColor]).CGColor);
    CGContextStrokeRect(context, CGRectMake(0, rect.size.height, rect.size.width, 1));
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

@end
