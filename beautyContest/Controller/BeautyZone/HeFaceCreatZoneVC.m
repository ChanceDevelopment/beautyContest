//
//  HeFaceCreatZoneVC.m
//  beautyContest
//
//  Created by Danertu on 16/10/26.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeFaceCreatZoneVC.h"

@interface HeFaceCreatZoneVC ()
@property(strong,nonatomic)NSMutableArray *dataSource;

@end

@implementation HeFaceCreatZoneVC
@synthesize zonePassword;
@synthesize dataSource;

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
        label.text = @"面对面建赛区";
        [label sizeToFit];
        
        self.title = @"面对面建赛区";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
}

- (void)backItemClick:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)loadJoinZoneUser
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/TestZoneQueInfo.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestParamDict = @{@"userId":userId};
    [self showHudInView:self.view hint:@"获取中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestParamDict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [dataSource removeAllObjects];
            
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
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
