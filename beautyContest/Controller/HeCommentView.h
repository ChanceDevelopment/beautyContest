//
//  HeCommentView.h
//  beautyContest
//
//  Created by Tony on 16/8/25.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeBaseViewController.h"
#import "User.h"

@protocol CommentProtocol <NSObject>

- (void)commentWithText:(NSString *)commentText user:(User *)commentUser;

@end

@interface HeCommentView : HeBaseViewController
@property(assign,nonatomic)id<CommentProtocol>commentDelegate;
@property(assign,nonatomic)NSInteger limitNumber; //限制输入字数


@end
