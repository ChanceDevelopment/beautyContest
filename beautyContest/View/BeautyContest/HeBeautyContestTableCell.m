//
//  HeBeautyContestTableCell.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBeautyContestTableCell.h"

@implementation HeBeautyContestTableCell
@synthesize bgImage;
@synthesize detailImage;
@synthesize topicLabel;
@synthesize tipLabel;
@synthesize bgView;
@synthesize infoView;
@synthesize timeLabel;

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
        CGFloat imageY = 50;
        CGFloat imageW = viewW;
        CGFloat imageH = viewH - imageY;
        
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index5.jpg"]];
        bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        bgImage.layer.cornerRadius = 5.0;
        bgImage.layer.masksToBounds = YES;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        [bgView addSubview:bgImage];
        
//        infoView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, viewW, 50)];
//        infoView.backgroundColor = [UIColor whiteColor];
//        infoView.userInteractionEnabled = YES;
        
//        CGFloat rX = 0;
//        CGFloat rY = 0;
//        CGFloat rW = imageW;
//        CGFloat rH = imageH / 2.0;
//        CAGradientLayer *gradient = [CAGradientLayer layer];
//        gradient.frame = CGRectMake(rX, rY, rW, rH);
//        gradient.colors = [NSArray arrayWithObjects:
//                           (id)[UIColor clearColor].CGColor,
//                           (id)[UIColor blackColor].CGColor,
//                           nil];
//        [buttonBG.layer insertSublayer:gradient atIndex:0];
//        [bgImage addSubview:buttonBG];
        
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
        tipLabel.text = @"$2000";
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
        timeLabel.font = [UIFont systemFontOfSize:13.5];
        timeLabel.frame = CGRectMake(timeX, timeY, timeW, timeH);
        [bgView addSubview:timeLabel];
        
//        CGPoint tipLabelCenterPoint = tipLabel.center;
//        CGPoint detailImageCenterPoint = detailImage.center;
//        detailImageCenterPoint.y = tipLabelCenterPoint.y;
//        detailImage.center = detailImageCenterPoint;
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
