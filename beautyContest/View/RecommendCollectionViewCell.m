//
//  RecommendCollectionViewCell.m
//  Wendao
//
//  Created by lanou3g on 15/10/22.
//  Copyright (c) 2015年 Jyp. All rights reserved.
//

#import "RecommendCollectionViewCell.h"
#import "UIImage+MultiFormat.h"
#import "UIImageView+WebCache.h"
@implementation RecommendCollectionViewCell

- (void)setModel:(Recommend *)model
{
    [self.MyImage sd_setImageWithURL:[NSURL URLWithString:model.headline_img] placeholderImage:[UIImage imageNamed:@"index1.jpg"]];
   
    
        
}


- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        _MyImage = [[UIImageView alloc]init];
        [self.contentView addSubview:_MyImage];
        
    }
    return self;
}

// 自定义Layout
-(void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    _MyImage.frame = CGRectMake(0, 0, layoutAttributes.frame.size.width, layoutAttributes.frame.size.height);
    
}








//- (void)prepareForReuse
//{
//    [super prepareForReuse];
//    
//    self.MyImage.image = nil;
//    
//    self.MyImage.frame = self.contentView.bounds;
//}
//


@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com