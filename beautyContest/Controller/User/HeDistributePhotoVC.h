//
//  HeDistributePhotoVC.h
//  huayoutong
//
//  Created by Tony on 16/3/10.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeBaseViewController.h"
#import "HeBaseDistributeVC.h"
//#import "AlbumModel.h"
//#import "UserAlbum.h"

@protocol UploadPhotoProtocol <NSObject>

- (void)uploadPhotoSuccess;

@end

@interface HeDistributePhotoVC : HeBaseDistributeVC
//@property(strong,nonatomic)UserAlbum *albumModel;
@property(assign,nonatomic)id<UploadPhotoProtocol>uploadPhotoDelegate;

@end
