//
//  HeDistributeContestVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/8/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeDistributeContestVC.h"

@interface HeDistributeContestVC ()

@end

@implementation HeDistributeContestVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = APPDEFAULTTITLETEXTFONT;
        label.textColor = APPDEFAULTTITLECOLOR;
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"发布赛区";
        [label sizeToFit];
        
        self.title = @"发布赛区";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
}

- (void)initView
{
    [super initView];
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] init];
    distributeItem.title = @"发布";
    distributeItem.target = self;
    distributeItem.action = @selector(distributeContest:);
    self.navigationItem.rightBarButtonItem = distributeItem;
}

- (void)distributeContest:(UIBarButtonItem *)barItem
{
    NSLog(@"distributeContest");
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
