//
//  HeFaceCreatZoneVC.m
//  beautyContest
//
//  Created by Danertu on 16/10/26.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeFaceCreatZoneVC.h"
#import "HeDistributeContestVC.h"

#define MAX_column  4
#define MAX_row 3

@interface HeFaceCreatZoneVC ()
@property(strong,nonatomic)NSMutableArray *dataSource;
@property(strong,nonatomic)IBOutlet UIButton *creatButton;
@property(strong,nonatomic)IBOutlet UIScrollView *scrollView;
@property(strong,nonatomic)IBOutlet UILabel *passwordLabel;

@end

@implementation HeFaceCreatZoneVC
@synthesize zonePassword;
@synthesize dataSource;
@synthesize creatButton;
@synthesize scrollView;
@synthesize passwordLabel;


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
    [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadJoinZoneUser) userInfo:nil repeats:YES];
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
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/selTemporaryUserInfo.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSString *userpassword = [[NSString alloc] initWithString:zonePassword];
    NSDictionary *requestParamDict = @{@"userid":userId,@"userpassword":userpassword};
//    [self showHudInView:self.view hint:@"获取中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestParamDict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [dataSource removeAllObjects];
        }
        id jsonArray = respondDict[@"json"];
        if ([jsonArray isMemberOfClass:[NSNull class]]) {
            return;
        }
        dataSource = [[NSMutableArray alloc] initWithArray:jsonArray];
        [self updateScrollView];
        
    } failure:^(NSError *error){
//        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)updateScrollView
{
    NSArray *subArray = scrollView.subviews;
    for (UIView *subview in subArray) {
        [subview removeFromSuperview];
    }

    CGFloat buttonH = 70;
    CGFloat buttonW = 70;
    
    CGFloat buttonHDis = (SCREENWIDTH - 20 - MAX_column * buttonW) / (MAX_column - 1);
    CGFloat buttonVDis = 10;
    
    int row = [Tool getRowNumWithTotalNum:[dataSource count]];
    int column = [Tool getColumnNumWithTotalNum:[dataSource count]];
    
    CGFloat distributeX = scrollView.frame.origin.x;
    CGFloat distributeY = scrollView.frame.origin.y;
    CGFloat distributeW = scrollView.frame.size.width;
    CGFloat distributeH = 0;
    
    for (int i = 0; i < row; i++) {
        if ((i + 1) * MAX_column <= [dataSource count]) {
            column = MAX_column;
        }
        else{
            column = [dataSource count] % MAX_column;
        }
        for (int j = 0; j < column; j++) {
            
            CGFloat buttonX = (buttonW + buttonHDis) * j + 10;
            CGFloat buttonY = (buttonH + buttonVDis) * i;
            
            NSInteger picIndex = i * MAX_column + j;
            NSDictionary *dict = [dataSource objectAtIndex:picIndex];
            NSString *userHeader = dict[@"userHeader"];
            if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil) {
                userHeader = @"";
            }
            if (![userHeader hasPrefix:@"http"]) {
                userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
            }
            UIImageView *asynImage = [[UIImageView alloc] init];
            [asynImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
//            asynImage.tag = picIndex;
            asynImage.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            asynImage.layer.borderColor = [UIColor clearColor].CGColor;
            asynImage.layer.borderWidth = 0;
            asynImage.layer.masksToBounds = YES;
            asynImage.contentMode = UIViewContentModeScaleAspectFill;
            asynImage.userInteractionEnabled = YES;
            
            [scrollView addSubview:asynImage];
            
            distributeH = CGRectGetMaxY(asynImage.frame);
        }
    }
    scrollView.contentSize = CGSizeMake(0, distributeH + 10);
}

- (IBAction)creatBeautyZoneWithPassword:(id)sender
{
    HeDistributeContestVC *distributeContestVC = [[HeDistributeContestVC alloc] init];
    distributeContestVC.zonePassword = [[NSString alloc] initWithString:zonePassword];
    distributeContestVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:distributeContestVC animated:YES];
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
