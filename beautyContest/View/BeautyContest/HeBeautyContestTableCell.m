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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
        CGFloat imageX = 10;
        CGFloat imageY = 10;
        CGFloat imageW = SCREENWIDTH - 2 * imageX;
        CGFloat imageH = cellsize.height - 2 * imageY;
        bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index5.jpg"]];
        bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        bgImage.layer.cornerRadius = 5.0;
        bgImage.layer.masksToBounds = YES;
        bgImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:bgImage];
        
        UIView *buttonBG = [[UIView alloc] initWithFrame:CGRectMake(0, cellsize.height - imageH / 2.0, imageW, imageH / 2.0)];
        buttonBG.userInteractionEnabled = YES;
        
        CGFloat rX = 0;
        CGFloat rY = 0;
        CGFloat rW = imageW;
        CGFloat rH = imageH / 2.0;
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = CGRectMake(rX, rY, rW, rH);
        gradient.colors = [NSArray arrayWithObjects:
                           (id)[UIColor clearColor].CGColor,
                           (id)[UIColor blackColor].CGColor,
                           nil];
        [buttonBG.layer insertSublayer:gradient atIndex:0];
        [bgImage addSubview:buttonBG];
        
        UIFont *textFont = [UIFont systemFontOfSize:16.0];
        
        CGFloat titleX = 5;
        CGFloat titleH = 30;
        CGFloat titleY = imageH - titleH - 10;
        CGFloat titleW = 100;
        
        topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = @"主题";
        topicLabel.numberOfLines = 0;
        topicLabel.textColor = [UIColor whiteColor];
        topicLabel.font = textFont;
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [bgImage addSubview:topicLabel];
        
        CGFloat detailImageW = 30;
        CGFloat detailImageH = 30;
        CGFloat detailImageX = imageW - detailImageW - titleX;
        CGFloat detailImageY = imageH - titleH - 10;

        detailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index4.jpg"]];
        detailImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
        detailImage.layer.cornerRadius = detailImageW / 2.0;
        detailImage.layer.masksToBounds = YES;
        detailImage.layer.borderWidth = 1.0;
        detailImage.layer.borderColor = [UIColor whiteColor].CGColor;
        detailImage.contentMode = UIViewContentModeScaleAspectFill;
        [bgImage addSubview:detailImage];
        
        CGFloat tiptitleX = titleX + titleW + 5;
        CGFloat tiptitleH = 30;
        CGFloat tiptitleY = imageH - titleH - 10;
        CGFloat tiptitleW = imageW - tiptitleX - detailImageW - titleX;
        
        tipLabel = [[UILabel alloc] init];
        tipLabel.textAlignment = NSTextAlignmentRight;
        tipLabel.backgroundColor = [UIColor clearColor];
        tipLabel.text = @"$2000/16.08.02";
        tipLabel.numberOfLines = 1;
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.font = [UIFont systemFontOfSize:15.0];
        tipLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
        [bgImage addSubview:tipLabel];
        
        CGPoint tipLabelCenterPoint = tipLabel.center;
        CGPoint detailImageCenterPoint = detailImage.center;
        detailImageCenterPoint.y = tipLabelCenterPoint.y;
        detailImage.center = detailImageCenterPoint;
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
