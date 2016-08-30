//
//  HeFansTableCell.m
//  beautyContest
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeFansTableCell.h"

@implementation HeFansTableCell
@synthesize userHeadImage;
@synthesize nameLabel;
@synthesize signLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier cellSize:(CGSize)cellsize
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier cellSize:cellsize];
    if (self) {
        CGFloat imageX = 10;
        CGFloat imageY = 10;
        CGFloat imageH = cellsize.height - 2 * imageY;
        CGFloat imageW = imageH;
        
        userHeadImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userHeadImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        userHeadImage.layer.masksToBounds = YES;
        userHeadImage.layer.cornerRadius = imageW / 2.0;
        userHeadImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:userHeadImage];
        
        CGFloat labelX = CGRectGetMaxX(userHeadImage.frame) + 10;
        CGFloat labelW = SCREENWIDTH - labelX - imageX;
        CGFloat labelY = imageY;
        CGFloat labelH = imageH / 2.0;
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:nameLabel];
        
        labelY = CGRectGetMaxY(nameLabel.frame);
        signLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, labelW, labelH)];
        signLabel.backgroundColor = [UIColor clearColor];
        signLabel.font = [UIFont systemFontOfSize:15.0];
        signLabel.textColor = [UIColor blackColor];
        signLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:signLabel];
        
        
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
