//
//  HeUserFollowTableCell.m
//  beautyContest
//
//  Created by Tony on 16/8/29.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserFollowTableCell.h"

@implementation HeUserFollowTableCell
@synthesize userHeadImage;
@synthesize nameLabel;
@synthesize signLabel;
@synthesize followButton;
@synthesize userInfo;

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
        
        CGFloat buttonH = 30;
        CGFloat buttonW = 60;
        CGFloat buttonX = SCREENWIDTH - 10 - buttonW;
        CGFloat buttonY = (cellsize.height - buttonH) / 2.0;
        followButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        [followButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:followButton.frame.size] forState:UIControlStateNormal];
        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        followButton.layer.cornerRadius = 3.0;
        followButton.layer.masksToBounds = YES;
        [followButton.titleLabel setFont:[UIFont systemFontOfSize:13.0]];
        [followButton setTitle:@"取消关注" forState:UIControlStateNormal];
        [followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:followButton];
    }
    return self;
}

- (void)followButtonClick:(UIButton *)button
{
    [self routerEventWithName:@"cancelFollow" userInfo:userInfo];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
