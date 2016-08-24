//
//  HeSettingVC.m
//  carTune
//
//  Created by HeDongMing on 16/6/28.
//  Copyright © 2016年 Jitsun. All rights reserved.
//

#import "HeSettingVC.h"
#import "HeBaseTableViewCell.h"
#import "ZJSwitch.h"
#import "BrowserView.h"
#import "UIButton+WebCache.h"
#import "UIButton+Bootstrap.h"

@interface HeSettingVC ()<UIAlertViewDelegate>
@property(strong,nonatomic)IBOutlet UITableView *settingTable;
@property(strong,nonatomic)NSArray *dataSource;

@end

@implementation HeSettingVC
@synthesize settingTable;
@synthesize dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"设置";
        [label sizeToFit];
        self.title = @"设置";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = YES;
}
- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@[@"消息提醒"],@[@"手机搜索",@"选美号搜索"],@[@"版本信息",@"关于"]];
}

- (void)initView
{
    [super initView];
    [Tool setExtraCellLineHidden:settingTable];
    settingTable.backgroundView = nil;
    settingTable.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    
    CGFloat buttonX = 20;
    CGFloat buttonY = 10;
    CGFloat buttonW = SCREENWIDTH - 2 * buttonX;
    CGFloat buttonH = 40;
    
    UIButton *logOutButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [logOutButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [logOutButton dangerStyle];
    logOutButton.layer.borderWidth = 0;
    logOutButton.layer.borderColor = [UIColor clearColor].CGColor;
    [logOutButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:logOutButton.frame.size] forState:UIControlStateNormal];
    [logOutButton addTarget:self action:@selector(logOutButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *footerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, buttonH + 2 * buttonY)];
    footerview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    footerview.userInteractionEnabled = YES;
    [footerview addSubview:logOutButton];
    settingTable.tableFooterView = footerview;
}

- (void)logOutButtonClick:(UIButton *)button
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"确定退出登录?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 100;
    [alert show];
}

- (void)loginOut
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERACCOUNTKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERPASSWORDKEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERIDKEY];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNOTIFICATION_LOGINCHANGE object:@NO];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    return;
    [self showHudInView:self.view hint:@"正在注销..."];
    NSString *logoutUrl = [NSString stringWithFormat:@"%@/user/quit.action",BASEURL];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:logoutUrl params:nil success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        id result = [respondDict objectForKey:@"success"];
        if ([result isMemberOfClass:[NSNull class]] || result == nil) {
            result = @"";
        }
        if ([result isKindOfClass:[NSString class]]) {
            if ([result compare:@"true" options:NSCaseInsensitiveSearch] != NSOrderedSame) {
                [self showHint:@"注销用户失败，请稍后再试!"];
                return;
            }
        }
        else{
            if (![result boolValue]) {
                [self showHint:@"注销用户失败，请稍后再试!"];
                return;
            }
        }
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERACCOUNTKEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERPASSWORDKEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:USERIDKEY];
        NSNotification *notification = [[NSNotification alloc] initWithName:@"loginSucceed" object:self userInfo:@{LOGINKEY:@NO}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100 && buttonIndex == 1) {
        [self loginOut];
    }
}

- (void)switchChange:(ZJSwitch *)switchController
{
    NSLog(@"switchController = %@",switchController);
    NSString *notificaitonKey = [NSString stringWithFormat:@"%@notificaiton",[[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY]];
    id notificaiotn = [NSNumber numberWithBool:switchController.on];
    [[NSUserDefaults standardUserDefaults] setObject:notificaiotn forKey:notificaitonKey];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [dataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    CGSize cellsize = [tableView rectForRowAtIndexPath:indexPath].size;
    CGFloat cellH = cellsize.height;
    
    static NSString *cellIndentifier = @"HeSettingTabelViewCell";
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = dataSource[section][row];
    switch (section) {
        case 0:
        {
        }
        case 1:
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            ZJSwitch *switchControl = [[ZJSwitch alloc] init];
            switchControl.frame = CGRectMake(cellsize.width - 62, (cellH - 25.0)/2.0, 44, 25);
            [switchControl addTarget:self action:@selector(switchChange:) forControlEvents:UIControlEventValueChanged];
            NSString *notificaitonKey = [NSString stringWithFormat:@"%@notificaiton",[[NSUserDefaults standardUserDefaults] objectForKey:USERACCOUNTKEY]];
            id notificaiotn = [[NSUserDefaults standardUserDefaults] objectForKey:notificaitonKey];
            if (!notificaiotn) {
                notificaiotn = [NSNumber numberWithBool:YES];
                [[NSUserDefaults standardUserDefaults] setObject:notificaiotn forKey:notificaitonKey];
            }
            switchControl.on = [notificaiotn boolValue];
            [cell.contentView addSubview:switchControl];
            
            break;
        }
        
        default:
            break;
    }
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    
}


- (void)clearImg:(id)sender
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *folderPath = [NSHomeDirectory() stringByAppendingString:@"/tmp"];
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        
        BOOL result = [manager removeItemAtPath:fileAbsolutePath error:nil];
        if (result) {
            NSLog(@"remove %@ succeed",fileAbsolutePath);
        }
        else{
            NSLog(@"remove %@ faild",fileAbsolutePath);
        }
        
    }
    
    NSString *libraryfolderPath = [NSHomeDirectory() stringByAppendingString:@"/Library"];
    //    libraryfolderPath = [[NSString alloc] initWithFormat:@"libraryfolderPath = %@",libraryfolderPath];
    
    NSString* LibraryfileName = [libraryfolderPath stringByAppendingPathComponent:@"EaseMobLog"];
    childFilesEnumerator = [[manager subpathsAtPath:LibraryfileName] objectEnumerator];
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [LibraryfileName stringByAppendingPathComponent:fileName];
        
        BOOL result = [manager removeItemAtPath:fileAbsolutePath error:nil];
        if (result) {
            NSLog(@"remove EaseMobLog succeed");
        }
        else{
            NSLog(@"remove EaseMobLog faild");
        }
        
    }
    
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesPath = [path objectAtIndex:0];
    childFilesEnumerator = [[manager subpathsAtPath:cachesPath] objectEnumerator];
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [cachesPath stringByAppendingPathComponent:fileName];
        NSRange range = [fileAbsolutePath rangeOfString:@"umeng"];
        
        if (range.length == 0) {
            BOOL result = [manager removeItemAtPath:fileAbsolutePath error:nil];
            if (result) {
                NSLog(@"remove caches succeed");
            }
            else{
                NSLog(@"remove caches faild");
            }
        }
        
    }
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
