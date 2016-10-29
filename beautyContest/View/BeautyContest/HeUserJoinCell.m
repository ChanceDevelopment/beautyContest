//
//  HeBeautyContestTableCell.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserJoinCell.h"

@implementation HeUserJoinCell
@synthesize bgImage;
@synthesize topicLabel;
@synthesize addressLabel;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        CGFloat imageX = 10;
        CGFloat imageY = 10;
        CGFloat imageW = SCREENWIDTH - 2 * imageX;
        CGFloat imageH = cellsize.height - 2 * imageY;
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comonDefaultImage"]];
        bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        bgImage.layer.cornerRadius = 5.0;
        bgImage.layer.masksToBounds = YES;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgImage];
        
        
        UIFont *textFont = [UIFont systemFontOfSize:18.0];
        
        CGFloat titleX = 5;
        CGFloat titleH = 30;
        CGFloat titleY = 10;
        CGFloat titleW = SCREENWIDTH - 2 * titleX;
        
        topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = @"主题";
        topicLabel.numberOfLines = 0;
        topicLabel.textColor = [UIColor whiteColor];
        topicLabel.font = textFont;
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [bgImage addSubview:topicLabel];
        
        
        
        CGFloat tiptitleX = 5;
        CGFloat tiptitleH = 30;
        CGFloat tiptitleY = CGRectGetMaxY(topicLabel.frame) + 10;
        CGFloat tiptitleW = SCREENWIDTH - 2 * titleX;
        
        timeLabel = [[UILabel alloc] init];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.text = @"2016.08.02";
        timeLabel.numberOfLines = 1;
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont systemFontOfSize:13.0];
        timeLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
        [bgImage addSubview:timeLabel];
        
        CGFloat addressX = 5;
        CGFloat addressH = 30;
        CGFloat addressY = CGRectGetMaxY(timeLabel.frame) + 10;
        CGFloat addressW = SCREENWIDTH - 2 * titleX;
        
        addressLabel = [[UILabel alloc] init];
        addressLabel.textAlignment = NSTextAlignmentLeft;
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.text = @"广东珠海";
        addressLabel.numberOfLines = 1;
        addressLabel.textColor = [UIColor whiteColor];
        addressLabel.font = [UIFont systemFontOfSize:15.0];
        addressLabel.frame = CGRectMake(addressX, addressY, addressW, addressH);
        [bgImage addSubview:addressLabel];
        
        
    }
    return self;
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
