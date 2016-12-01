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
        [favButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:favButton.frame.size] forState:UIControlStateNormal];
        favButton.titleLabel.font = [UIFont systemFontOfSize:13.5];
        [favButton setTitle:@"锤一位" forState:UIControlStateNormal];
        [favButton.titleLabel setTextColor:[UIColor whiteColor]];
        [favButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        favButton.layer.cornerRadius = 3.0;
        favButton.layer.masksToBounds = YES;
        [favButton addTarget:self action:@selector(favButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:favButton];
        
        
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

- (void)favButtonClick:(id)sender
{
    [self routerEventWithName:@"favButtonClick" userInfo:userInfo];
}

@end
