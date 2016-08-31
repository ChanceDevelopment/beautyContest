//
//  HeAlbumImage.h
//  huayoutong
//
//  Created by HeDongMing on 16/4/23.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeAlbumImage : UIView<UIAlertViewDelegate>
@property(strong,nonatomic)UIImageView *imageView;
@property(strong,nonatomic)UIButton *selectBox;
@property(strong,nonatomic)NSString *photoID;
@property(assign,nonatomic)BOOL selected;

@end
