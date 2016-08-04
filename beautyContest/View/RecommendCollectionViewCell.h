//
//  RecommendCollectionViewCell.h
//  Wendao
//
//  Created by lanou3g on 15/10/22.
//  Copyright (c) 2015年 Jyp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recommend.h"
@interface RecommendCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic)UIImageView *MyImage;
@property (nonatomic,strong)UILabel * myTitle;

@property (nonatomic,strong)Recommend * model;

@property (nonatomic,strong)NSData * data;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com