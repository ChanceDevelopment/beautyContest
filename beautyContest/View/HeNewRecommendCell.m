//
//  HeNewRecommendCell.m
//  beautyContest
//
//  Created by Danertu on 16/10/28.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeNewRecommendCell.h"

@implementation HeNewRecommendCell
@synthesize bgImage;
@synthesize detailImage;
@synthesize topicLabel;
@synthesize tipLabel;
@synthesize bgView;
@synthesize infoView;
@synthesize timeLabel;
@synthesize favButton;
@synthesize commentButton;
@synthesize recommentDict;

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
        CGFloat imageY = 0;
        CGFloat imageW = viewW;
        CGFloat imageH = viewH - 70;
        
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index5.jpg"]];
        bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        bgImage.layer.cornerRadius = 5.0;
        bgImage.layer.masksToBounds = YES;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:bgImage];
        
        CGFloat agreeY = CGRectGetMaxY(bgImage.frame) + 15;
        CGFloat agreeH = 20;
        CGFloat agreeW = 40;
        CGFloat agreeX = viewW - 10 - agreeW;
        favButton = [[UIButton alloc] initWithFrame:CGRectMake(agreeX, agreeY, agreeW, agreeH)];
        [favButton setTitle:@"关注" forState:UIControlStateNormal];
        [favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [favButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:favButton.frame.size] forState:UIControlStateNormal];
        [favButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [favButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        favButton.tag = 1;
        [self.bgView addSubview:favButton];
        [favButton addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat commentY = CGRectGetMaxY(favButton.frame) + 10;
        CGFloat commentH = 20;
        CGFloat commentW = 20;
        CGFloat commentX = viewW - 10 - commentW;
        commentButton = [[UIButton alloc] initWithFrame:CGRectMake(commentX, commentY, commentW, commentH)];
        [commentButton setImage:[UIImage imageNamed:@"icon_message"] forState:UIControlStateNormal];
//        [commentButton setTitle:@"关注" forState:UIControlStateNormal];
//        [commentButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
//        [commentButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
//        [commentButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        commentButton.tag = 2;
        [self.bgView addSubview:commentButton];
        [commentButton addTarget:self action:@selector(commentButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        CGFloat tiptitleX = 10;
        CGFloat tiptitleY = CGRectGetMaxY(bgImage.frame) + 5;
        CGFloat tiptitleH = 30;
        CGFloat tiptitleW = agreeX - tiptitleX - 10;
        
        tipLabel = [[UILabel alloc] init];
//        tipLabel.textAlignment = NSTextAlignmentRight;
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"王琦";
        tipLabel.numberOfLines = 1;
        tipLabel.textColor = [UIColor blackColor];
        tipLabel.font = [UIFont systemFontOfSize:13.5];
        tipLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
        [bgView addSubview:tipLabel];
        
        CGFloat titleX = 10;
        CGFloat titleY = CGRectGetMaxY(tipLabel.frame);
        CGFloat titleH = 30;
        CGFloat titleW = tiptitleW;
        
        topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = @"主题";
        topicLabel.numberOfLines = 1;
        topicLabel.textColor = [UIColor grayColor];
        topicLabel.font = [UIFont systemFontOfSize:13.5];
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [bgView addSubview:topicLabel];
        
        
    }
    return self;
}

- (void)favButtonClick:(UIButton *)button
{
    [self routerEventWithName:@"favButtonClick" userInfo:recommentDict];
    NSLog(@"favButtonClick");
}

- (void)commentButtonClick:(UIButton *)button
{
     [self routerEventWithName:@"commentButtonClick" userInfo:recommentDict];
    NSLog(@"commentButtonClick");
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
