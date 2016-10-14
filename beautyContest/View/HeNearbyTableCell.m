//
//  HeNearbyTableCell.m
//  beautyContest
//
//  Created by Tony on 16/8/3.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeNearbyTableCell.h"

@implementation HeNearbyTableCell
@synthesize userImage;
@synthesize nameLabel;
@synthesize distanceLabel;
@synthesize signLabel;

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
        CGFloat imageX = 10;
        CGFloat imageY = 15;
        CGFloat imageH = cellsize.height - 2 * imageY;
        CGFloat imageW = imageH;
        
        userImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        userImage.layer.cornerRadius = imageW / 2.0;
        userImage.layer.masksToBounds = YES;
        [self addSubview:userImage];
        
        CGFloat nameLabelX = CGRectGetMaxX(userImage.frame) + 5;
        CGFloat nameLabelY = imageY;
        CGFloat nameLabelW = SCREENWIDTH / 2.0 - 5 - CGRectGetMaxX(userImage.frame);
        CGFloat nameLabelH = imageH / 2.0;
        nameLabel = [[UILabel alloc] init];
        nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH);
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.font = [UIFont systemFontOfSize:15.0];
        nameLabel.text = @"Tony";
        [self addSubview:nameLabel];
        
        distanceLabel = [[UILabel alloc] init];
        distanceLabel.frame = CGRectMake(nameLabelX, nameLabelY + nameLabelH, nameLabelW, nameLabelH);
        distanceLabel.backgroundColor = [UIColor clearColor];
        distanceLabel.textColor = [UIColor grayColor];
        distanceLabel.font = [UIFont systemFontOfSize:15.0];
        distanceLabel.text = @"100米以内";
        [self addSubview:distanceLabel];
        
        CGFloat signLabelX = SCREENWIDTH / 2.0;
        CGFloat signLabelY = imageY;
        CGFloat signLabelH = imageH;
        CGFloat signLabelW = SCREENWIDTH / 2.0 - 5;
        
        signLabel = [[UILabel alloc] init];
        signLabel.numberOfLines = 2;
        signLabel.frame = CGRectMake(signLabelX, signLabelY, signLabelW, signLabelH);
        signLabel.backgroundColor = [UIColor clearColor];
        signLabel.textColor = [UIColor grayColor];
        signLabel.font = [UIFont systemFontOfSize:15.0];
        signLabel.textAlignment = NSTextAlignmentRight;
        signLabel.text = @"致已经逝去的青春，致已经逝去的青春，致已经逝去的青春";
        [self addSubview:signLabel];
        
    }
    return self;
}

@end
