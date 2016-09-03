//
//  HeUserContestCell.m
//  beautyContest
//
//  Created by Tony on 16/9/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserContestCell.h"

@implementation HeUserContestCell
@synthesize imageview;
@synthesize contentLabel;
@synthesize timeLabel;
@synthesize addressLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat imageX = 10;
        CGFloat imageY = 10;
        CGFloat imageW = SCREENWIDTH - 2 * imageX;
        CGFloat imageH = cellsize.height - 2 * imageY;
        imageview = [[UIImageView alloc] initWithFrame:CGRectMake(imageX, imageY, imageW, imageH)];
        imageview.image = [UIImage imageNamed:@"comonDefaultImage"];
        imageview.layer.masksToBounds = YES;
        imageview.layer.cornerRadius = 5.0;
        imageview.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:imageview];
        
        CGFloat contentX = 5;
        CGFloat contentY = 10;
        CGFloat contentW = imageW - 2 * contentX;
        CGFloat contentH = 40;
        contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentX, contentY, contentW, contentH)];
        contentLabel.backgroundColor = [UIColor clearColor];
        contentLabel.font = [UIFont systemFontOfSize:20.0];
        contentLabel.text = @"";
        contentLabel.textColor = [UIColor whiteColor];
        [imageview addSubview:contentLabel];
        
        CGFloat timeX = 5;
        CGFloat timeY = CGRectGetMaxY(contentLabel.frame);
        CGFloat timeW = imageW - 2 * timeX;
        CGFloat timeH = 40;
        timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeX, timeY, timeW, timeH)];
        timeLabel.numberOfLines = 2;
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = [UIFont systemFontOfSize:15.0];
        timeLabel.text = @"";
        timeLabel.textColor = [UIColor whiteColor];
        [imageview addSubview:timeLabel];
        
        CGFloat addressX = 5;
        CGFloat addressY = CGRectGetMaxY(timeLabel.frame);
        CGFloat addressW = imageW - 2 * timeX;
        CGFloat addressH = 30;
        addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(addressX, addressY, addressW, addressH)];
        addressLabel.backgroundColor = [UIColor clearColor];
        addressLabel.font = [UIFont systemFontOfSize:15.0];
        addressLabel.text = @"";
        addressLabel.textColor = [UIColor whiteColor];
        [imageview addSubview:addressLabel];
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
