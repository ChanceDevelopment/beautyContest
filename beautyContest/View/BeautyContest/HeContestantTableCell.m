//
//  HeContestantTableCell.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestantTableCell.h"
#import "UIButton+Bootstrap.h"

@implementation HeContestantTableCell
@synthesize userImage;
@synthesize nameLabel;
@synthesize distanceLabel;
@synthesize signLabel;
@synthesize favButton;
@synthesize userInfo;
@synthesize prizeMoneyLabel;
@synthesize rankLabel;
@synthesize noFavButton;

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
        
        CGFloat rankLabelX = 5;
        CGFloat rankLabelY = 0;
        CGFloat rankLabelW = 30;
        CGFloat rankLabelH = cellsize.height;
        rankLabel = [[UILabel alloc] init];
        rankLabel.frame = CGRectMake(rankLabelX, rankLabelY, rankLabelW, rankLabelH);
        rankLabel.backgroundColor = [UIColor clearColor];
        rankLabel.textColor = [UIColor blackColor];
        rankLabel.font = [UIFont systemFontOfSize:15.0];
        rankLabel.text = @"Tony";
        rankLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:rankLabel];
        
        
        CGFloat imageX = 40;
        CGFloat imageY = 15;
        CGFloat imageH = cellsize.height - 2 * imageY;
        CGFloat imageW = imageH;
        
        userImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
        userImage.layer.masksToBounds = YES;
        userImage.layer.cornerRadius = imageW / 2.0;
        userImage.contentMode = UIViewContentModeScaleAspectFill;
        userImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
        [self addSubview:userImage];
        
        CGFloat nameLabelX = CGRectGetMaxX(userImage.frame) + 5;
        CGFloat nameLabelY = imageY;
        CGFloat nameLabelW = SCREENWIDTH - imageX - CGRectGetMaxX(userImage.frame);
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
        distanceLabel.text = @"承势网络 CEO";
        [self addSubview:distanceLabel];
        
        CGFloat favW = 60;
        CGFloat favH = 25;
        CGFloat favX = SCREENWIDTH - favW - 10;
        CGFloat favY = (cellsize.height - favH) / 2.0;
        
        favButton = [[UIButton alloc] init];
        favButton.frame = CGRectMake(favX, favY, favW, favH);
        [favButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor colorWithRed:245 / 255.0 green:154 / 255.0 blue:42 / 255.0 alpha:1] withImageSize:favButton.frame.size] forState:UIControlStateNormal];
        favButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
        [favButton setTitle:@"顶一位" forState:UIControlStateNormal];
        [favButton.titleLabel setTextColor:[UIColor whiteColor]];
        [favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        favButton.layer.cornerRadius = 3.0;
        favButton.layer.masksToBounds = YES;
        favButton.tag = 1;
        [favButton addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:favButton];
        
        noFavButton = [[UIButton alloc] init];
        noFavButton.frame = CGRectMake(favX, favY, favW, favH);
        [noFavButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor colorWithRed:245 / 255.0 green:154 / 255.0 blue:42 / 255.0 alpha:1] withImageSize:favButton.frame.size] forState:UIControlStateNormal];
        noFavButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
        [noFavButton setTitle:@"踩一位" forState:UIControlStateNormal];
        [noFavButton.titleLabel setTextColor:[UIColor whiteColor]];
        noFavButton.tag = 2;
        [noFavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        noFavButton.layer.cornerRadius = 3.0;
        noFavButton.layer.masksToBounds = YES;
        [noFavButton addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        noFavButton.hidden = YES;
        [self addSubview:noFavButton];
        
        
        CGFloat prizeMoneyY = 0;
        CGFloat prizeMoneyW = 70;
        CGFloat prizeMoneyX = SCREENWIDTH - prizeMoneyW - 10;
        CGFloat prizeMoneyH = cellsize.height;
        prizeMoneyLabel = [[UILabel alloc] init];
        prizeMoneyLabel.frame = CGRectMake(prizeMoneyX, prizeMoneyY, prizeMoneyW, prizeMoneyH);
        prizeMoneyLabel.textAlignment = NSTextAlignmentRight;
        prizeMoneyLabel.backgroundColor = [UIColor clearColor];
        prizeMoneyLabel.textColor = [UIColor grayColor];
        prizeMoneyLabel.font = [UIFont systemFontOfSize:17.0];
        prizeMoneyLabel.text = @"";
        [self addSubview:prizeMoneyLabel];
        
    }
    return self;
}

- (void)favButtonClick:(UIButton *)sender
{
    if (sender.tag == 1) {
        //顶一位
        [self routerEventWithName:@"favButtonClick" userInfo:userInfo];
    }
    else{
        [self routerEventWithName:@"notfavButtonClick" userInfo:userInfo];
    }
    
}

@end
