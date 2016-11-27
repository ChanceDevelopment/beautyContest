//
//  HeAlbumImage.m
//  huayoutong
//
//  Created by HeDongMing on 16/4/23.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeAlbumImage.h"

@implementation HeAlbumImage
@synthesize imageView;
@synthesize selectBox;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:imageView];
        
        CGFloat boxWidth = 25;
        CGFloat boxHeight = boxWidth;
        selectBox = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - boxWidth, 0, boxWidth, boxHeight)];
        [selectBox setBackgroundImage:[UIImage imageNamed:@"album_uncheckBox0000"] forState:UIControlStateNormal];
        [selectBox setBackgroundImage:[UIImage imageNamed:@"album_checkBox"] forState:UIControlStateSelected];
        [selectBox addTarget:self action:@selector(selectButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        selectBox.hidden = YES;
        self.selected = selectBox.selected;
        [self addSubview:selectBox];
        
//        UILongPressGestureRecognizer *longGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//        longGes.minimumPressDuration = 0.3;
//        [self addGestureRecognizer:longGes];
        
    }
    return self;
}

-(void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan){
    
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"选择操作" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除",@"操作", nil];
        [alert show];
    }
    
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        
    
        NSLog(@"mimimimimimi");
    }
    
    else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
    
        NSLog(@"lostllllllll");
        
    }
}

- (void)selectButtonClick:(UIButton *)button
{
    button.selected = !button.selected;
    self.selected = button.selected;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            NSLog(@"取消");
            break;
        }
        case 1:
        {
            NSString *photoID = self.photoID;
            NSNotification *notificaiton = [[NSNotification alloc] initWithName:@"deleteAlbumPhoto" object:self userInfo:@{@"photoID":photoID}];
            [[NSNotificationCenter defaultCenter] postNotification:notificaiton];
            break;
        }
        case 2:
        {
            NSLog(@"操作");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"operateAlbumPhoto" object:self];
            break;
        }
        default:
            break;
    }
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
