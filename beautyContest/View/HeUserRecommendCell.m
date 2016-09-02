//
//  HeUserRecommendCell.m
//  beautyContest
//
//  Created by Tony on 16/9/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserRecommendCell.h"

@implementation HeUserRecommendCell
@synthesize imageview;
@synthesize contentLabel;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat imageX = 10;
        CGFloat imageY = 10;
        CGFloat imageW = SCREENWIDTH - 2 * imageX;
        CGFloat imageH = imageW * BESTSCALE;
        imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        imageview.image = [UIImage imageNamed:@"comonDefaultImage"];
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 5.0;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageview];
        
        CGFloat contentX = 10;
        CGFloat contentY = CGRectGetMaxY(imageview.frame);
        CGFloat contentW = SCREENWIDTH - 2 * contentX;
        CGFloat contentH = 30;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:15.0];
        contentLabel.text = @"";
        contentLabel.textColor = [UIColor blackColor];
        [self addSubview:contentLabel];
        
        CGFloat timeX = 10;
        CGFloat timeY = CGRectGetMaxY(contentLabel.frame);
        CGFloat timeW = SCREENWIDTH - 2 * timeX;
        CGFloat timeH = 30;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:12.0];
        timeLabel.text = @"";
        timeLabel.textColor = [UIColor grayColor];
        [self addSubview:timeLabel];
        
        
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
