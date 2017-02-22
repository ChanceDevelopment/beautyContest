//
//  HePhotoScanVC.m
//  beautyContest
//
//  Created by Tony on 2017/2/22.
//  Copyright © 2017年 iMac. All rights reserved.
//

#import "HePhotoScanVC.h"
#import "WBImageBrowserView.h"

@interface HePhotoScanVC ()<WBImageBrowserViewDelegate>
{
    WBImageBrowserView *pictureBrowserView;
}

@end

@implementation HePhotoScanVC
@synthesize photoArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat newVcH;
    CGFloat newVcW;
    
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        // 横屏
        newVcH = [UIScreen mainScreen].bounds.size.width;
        newVcW = [UIScreen mainScreen].bounds.size.height;
    } else {
        // 竖屏
        newVcW = [UIScreen mainScreen].bounds.size.width ;
        newVcH = [UIScreen mainScreen].bounds.size.height;
    }
    
    self.view.frame = CGRectMake(0, 0, newVcW, newVcH);
    pictureBrowserView.orientation = self.interfaceOrientation;
    
}

- (void)initializaiton
{
    [super initializaiton];
}

//支持旋转
-(BOOL)shouldAutorotate{
    return YES;
}

//支持的方向 因为界面A我们只需要支持竖屏
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (void)initView
{
    [super initView];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    
//    [WBImageBrowserView clearImagesCache];
    
    NSMutableArray *listAM = [[NSMutableArray alloc] initWithArray:photoArray];
    
    pictureBrowserView = [WBImageBrowserView pictureBrowsweViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)
                                                                delegate:self
                                                        browserInfoArray:listAM];
    pictureBrowserView.delegate = self;
    pictureBrowserView.orientation = self.interfaceOrientation;
    pictureBrowserView.viewController = self;
    pictureBrowserView.startIndex = self.currentIndex;  //开始索引
    [pictureBrowserView showInView:[UIApplication sharedApplication].delegate.window];
}

- (void)dismisShow
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
