//
//  HeBeautyContestTableCell.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeZoneCommentCell.h"

@implementation HeZoneCommentCell
@synthesize bgImage;
@synthesize topicLabel;
@synthesize addressLabel;
@synthesize timeLabel;
@synthesize deleteButton;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
//        self.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        CGFloat imageX = 10;
        CGFloat imageY = 10;
        CGFloat imageW = 50;
        CGFloat imageH = imageW;
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index5.jpg"]];
        bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        bgImage.layer.cornerRadius = imageW / 2.0;
        bgImage.layer.masksToBounds = YES;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgImage];
        
        
        UIFont *textFont = [UIFont systemFontOfSize:14.0];
        
        CGFloat titleX = CGRectGetMaxX(bgImage.frame) + 5;
        CGFloat titleH = 20;
        CGFloat titleY = imageY;
        CGFloat titleW = SCREENWIDTH - titleX - 10;
        
        topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = @"姓名";
        topicLabel.numberOfLines = 0;
        topicLabel.textColor = APPDEFAULTORANGE;
        topicLabel.font = textFont;
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [self addSubview:topicLabel];
        
        
        
        CGFloat tiptitleX = titleX;
        CGFloat tiptitleH = 20;
        CGFloat tiptitleY = CGRectGetMaxY(topicLabel.frame);
        CGFloat tiptitleW = SCREENWIDTH - titleX - 10;
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016.08.02";
        timeLabel.numberOfLines = 1;
        timeLabel.textColor = APPDEFAULTORANGE;
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
        [self addSubview:timeLabel];
        
        CGFloat addressX = titleX;
        CGFloat addressH = 30;
        CGFloat addressY = CGRectGetMaxY(timeLabel.frame);
        CGFloat addressW = SCREENWIDTH - titleX - 10;
        
        addressLabel = [[UILabel alloc] init];
        addressLabel.textAlignment = NSTextAlignmentLeft;
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.text = @"广东珠海";
        addressLabel.numberOfLines = 0;
        addressLabel.textColor = APPDEFAULTORANGE;
        addressLabel.font = [UIFont systemFontOfSize:15.0];
        addressLabel.frame = CGRectMake(addressX, addressY, addressW, addressH);
        [self addSubview:addressLabel];
        
        CGFloat buttonY = imageY;
        CGFloat buttonW = 20;
        CGFloat buttonH = 30;
        UIImage *deleteImage = [UIImage imageNamed:@"icon_delete"];
        if (deleteImage) {
            buttonH = deleteImage.size.height * buttonW / deleteImage.size.width;
        }
        CGFloat buttonX = SCREENWIDTH - 10 - buttonW;
        deleteButton = [[UIButton alloc] init];
        deleteButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [deleteButton setBackgroundImage:deleteImage forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:deleteButton];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)deleteButtonClick:(UIButton *)button
{
    [self routerEventWithName:@"deleteComment" userInfo:_commentDict];
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
    CGContextSetStrokeColorWithColor(context, ([UIColor grayColor]).CGColor);
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
