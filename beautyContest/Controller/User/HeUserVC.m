//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeSettingVC.h"
#import "HeSysbsModel.h"
#import "MLLinkLabel.h"
#import "HeUserJoinVC.h"
#import "HeUserDistributeVC.h"
#import "HeUserAlbumVC.h"
#import "HeMyFansVC.h"
#import "HeUserFollowVC.h"
#import "HeUserFinanceVC.h"
#import "HeUserInfoVC.h"
#import "HeMyTicketVC.h"

#define TextLineHeight 1.2f
#define SEXTAG 1000

@interface HeUserVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UILabel *addressLabel;
@property(strong,nonatomic)UIImageView *userBGImage;
@property(strong,nonatomic)User *userInfo;

@end

@implementation HeUserVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize iconDataSource;
@synthesize userBGImage;
@synthesize nameLabel;
@synthesize addressLabel;
@synthesize userInfo;

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
        label.text = @"我的";
        [label sizeToFit];
        
        self.title = @"我的";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@[@"我的相册",@"我的发布",@"我的参与",@"我的资金"],@[@"设置"]];
    iconDataSource = @[@[@"icon_album",@"icon_put",@"icon_participation",@"icon_reward"],@[@"icon_setting"]];
    userInfo = [[User alloc] initUserWithUser:[HeSysbsModel getSysModel].user];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"updateUserInfo" object:nil];
}

- (void)initView
{
    [super initView];
    self.navigationController.navigationBarHidden = YES;
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    CGFloat headerH = 200;
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerH)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
    tableview.tableHeaderView = sectionHeaderView;
    
    userBGImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_can_change_bg_09.jpg"]];
    userBGImage.layer.masksToBounds = YES;
    userBGImage.contentMode = UIViewContentModeScaleAspectFill;
    userBGImage.frame = CGRectMake(0, 0, SCREENWIDTH, headerH);
    [sectionHeaderView addSubview:userBGImage];
    
    UIFont *textFont = [UIFont systemFontOfSize:20.0];
    
    CGFloat nameLabelX = 0;
    CGFloat nameLabelY = 0;
    CGFloat nameLabelH = 40;
    CGFloat nameLabelW = SCREENWIDTH;
    nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = userInfo.userNick;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = textFont;
    nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH);
    [sectionHeaderView addSubview:nameLabel];
    nameLabel.center = userBGImage.center;
    CGRect nameFrame = nameLabel.frame;
    nameFrame.origin.y = nameFrame.origin.y - 20;
    nameLabel.frame = nameFrame;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserInfo:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    nameLabel.userInteractionEnabled = YES;
    sectionHeaderView.userInteractionEnabled = YES;
    userBGImage.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap];
    
    CGSize textSize = [MLLinkLabel getViewSizeByString:nameLabel.text maxWidth:nameLabel.frame.size.width font:nameLabel.font lineHeight:TextLineHeight lines:0];
    UIImageView *sexIcon = [[UIImageView alloc] init];
    if (userInfo.userSex == 1) {
        sexIcon.image = [UIImage imageNamed:@"icon_sex_boy"];
    }
    else{
        sexIcon.image = [UIImage imageNamed:@"icon_sex_girl"];
    }
    CGFloat imageX = SCREENWIDTH / 2.0 + textSize.width / 2.0 + 5;
    CGFloat imageW = 20;
    CGFloat imageH = 20;
    CGFloat imageY = nameFrame.origin.y + (nameLabelH - imageH) / 2.0;
    sexIcon.frame = CGRectMake(imageX, imageY, imageW, imageH);
    sexIcon.tag = SEXTAG;
    [sectionHeaderView addSubview:sexIcon];
    
    CGFloat addressLabelX = 0;
    CGFloat addressLabelY = CGRectGetMaxY(nameLabel.frame);
    CGFloat addressLabelH = 40;
    CGFloat addressLabelW = SCREENWIDTH;
    addressLabel = [[UILabel alloc] init];
    addressLabel.textAlignment = NSTextAlignmentLeft;
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = userInfo.userAddress;
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.textColor = [UIColor whiteColor];
    addressLabel.font = textFont;
    addressLabel.frame = CGRectMake(addressLabelX, addressLabelY, addressLabelW, addressLabelH);
    [sectionHeaderView addSubview:addressLabel];
 
    
    UIView *buttonBG = [[UIView alloc] initWithFrame:CGRectMake(0, headerH - 40, SCREENWIDTH, 40)];
    buttonBG.userInteractionEnabled = YES;
//    buttonBG.backgroundColor = [UIColor whiteColor];
    
    CGFloat rX = 0;
    CGFloat rY = 0;
    CGFloat rW = SCREENWIDTH;
    CGFloat rH = 40;
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = CGRectMake(rX, rY, rW, rH);
    gradient.colors = [NSArray arrayWithObjects:
                       (id)[UIColor clearColor].CGColor,
                       (id)[UIColor blackColor].CGColor,
                       nil];
    [buttonBG.layer insertSublayer:gradient atIndex:0];
    
    [sectionHeaderView addSubview:buttonBG];
    NSArray *buttonArray = @[@"粉丝",@"票数",@"关注"];
    NSArray *titleArray = @[[NSString stringWithFormat:@"%ld",[HeSysbsModel getSysModel].fansNum],[NSString stringWithFormat:@"%ld",[HeSysbsModel getSysModel].ticketNum],[NSString stringWithFormat:@"%ld",[HeSysbsModel getSysModel].followNum]];
    for (NSInteger index = 0; index < [buttonArray count]; index++) {
        CGFloat buttonW = SCREENWIDTH / [buttonArray count];
        CGFloat buttonH = 40;
        CGFloat buttonX = index * buttonW;
        CGFloat buttonY = 0;
        CGRect buttonFrame = CGRectMake(buttonX , buttonY, buttonW, buttonH);
        
        UIButton *button = [self buttonWithTitle:buttonArray[index] frame:buttonFrame];
        button.tag = index + 100;
        if (index == 0) {
            button.selected = YES;
        }
        UILabel *label = [button viewWithTag:200];
        label.text = titleArray[index];
        [buttonBG addSubview:button];
    }
    
}

- (void)updateUserInfo:(NSNotification *)notificaiton
{
    [self getUserInfo];
}

- (void)updateUser
{
    UIFont *textFont = [UIFont systemFontOfSize:20.0];
    
    CGFloat nameLabelX = 0;
    CGFloat nameLabelY = 0;
    CGFloat nameLabelH = 40;
    CGFloat nameLabelW = SCREENWIDTH;
//    nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = userInfo.userNick;
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = textFont;
    nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH);
    [sectionHeaderView addSubview:nameLabel];
    nameLabel.center = userBGImage.center;
    CGRect nameFrame = nameLabel.frame;
    nameFrame.origin.y = nameFrame.origin.y - 20;
    nameLabel.frame = nameFrame;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanUserInfo:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    nameLabel.userInteractionEnabled = YES;
    sectionHeaderView.userInteractionEnabled = YES;
    userBGImage.userInteractionEnabled = YES;
    [nameLabel addGestureRecognizer:tap];
    
    CGSize textSize = [MLLinkLabel getViewSizeByString:nameLabel.text maxWidth:nameLabel.frame.size.width font:nameLabel.font lineHeight:TextLineHeight lines:0];
    UIImageView *sexIcon = [sectionHeaderView viewWithTag:SEXTAG];
    if (userInfo.userSex == 1) {
        sexIcon.image = [UIImage imageNamed:@"icon_sex_boy"];
    }
    else{
        sexIcon.image = [UIImage imageNamed:@"icon_sex_girl"];
    }
    CGFloat imageX = SCREENWIDTH / 2.0 + textSize.width / 2.0 + 5;
    CGFloat imageW = 20;
    CGFloat imageH = 20;
    CGFloat imageY = nameFrame.origin.y + (nameLabelH - imageH) / 2.0;
    sexIcon.frame = CGRectMake(imageX, imageY, imageW, imageH);
    [sectionHeaderView addSubview:sexIcon];
    
    CGFloat addressLabelX = 0;
    CGFloat addressLabelY = CGRectGetMaxY(nameLabel.frame);
    CGFloat addressLabelH = 40;
    CGFloat addressLabelW = SCREENWIDTH;
//    addressLabel = [[UILabel alloc] init];
    addressLabel.textAlignment = NSTextAlignmentLeft;
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = userInfo.userAddress;
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.textColor = [UIColor whiteColor];
    addressLabel.font = textFont;
    addressLabel.frame = CGRectMake(addressLabelX, addressLabelY, addressLabelW, addressLabelH);
    [sectionHeaderView addSubview:addressLabel];
}
//获取用户的信息
- (void)getUserInfo
{
    NSString *getUserInfoUrl = [NSString stringWithFormat:@"%@/user/getUserinfo.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (userId == nil) {
        userId = @"";
    }
    NSDictionary *loginParams = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserInfoUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
            //            NSInteger userState = [[userDictInfo objectForKey:@"userState"] integerValue];
            //            if (userState == 0) {
            //                [self showHint:@"当前用户不可用"];
            //                return ;
            //            }
            NSString *userDataPath = [Tool getUserDataPath];
            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
            BOOL succeed = [@{@"user":respondString} writeToFile:userFileName atomically:YES];
            if (succeed) {
                NSLog(@"用户资料写入成功");
            }
            User *user = [[User alloc] initUserWithDict:userDictInfo];
            [HeSysbsModel getSysModel].user = [[User alloc] initUserWithUser:user];
            userInfo = user;
            [self updateUser];
            [tableview reloadData];
        }
        else{
            NSString *userDataPath = [Tool getUserDataPath];
            NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
            NSDictionary *respondDict = [[NSDictionary alloc] initWithContentsOfFile:userFileName];
            if (respondDict) {
                NSString *myresponseString = [respondDict objectForKey:@"user"];
                NSDictionary *respondDict = [myresponseString objectFromJSONString];
                NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
                User *user = [[User alloc] initUserWithDict:userDictInfo];
                [HeSysbsModel getSysModel].user = [[User alloc] initUserWithUser:user];
            }
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
    
}

- (UIButton *)buttonWithTitle:(NSString *)buttonTitle frame:(CGRect)buttonFrame
{
    UIButton *button = [[UIButton alloc] initWithFrame:buttonFrame];
    [button addTarget:self action:@selector(filterButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//    [button setBackgroundImage:[Tool buttonImageFromColor:[UIColor whiteColor] withImageSize:button.frame.size] forState:UIControlStateSelected];
//    [button setBackgroundImage:[Tool buttonImageFromColor:sectionHeaderView.backgroundColor withImageSize:button.frame.size] forState:UIControlStateNormal];
    
    UILabel *buttonNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, buttonFrame.size.width, buttonFrame.size.height / 2.0)];
    buttonNameLabel.textColor = [UIColor whiteColor];
    buttonNameLabel.text = buttonTitle;
    buttonNameLabel.backgroundColor = [UIColor clearColor];
    buttonNameLabel.font = [UIFont systemFontOfSize:12.0];
    buttonNameLabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:buttonNameLabel];
    
    UILabel *buttonNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, buttonFrame.size.height / 2.0, buttonFrame.size.width, buttonFrame.size.height / 2.0)];
    buttonNumberLabel.tag = 200;
    buttonNumberLabel.backgroundColor = [UIColor clearColor];
    buttonNumberLabel.textColor = [UIColor whiteColor];
    buttonNumberLabel.font = [UIFont systemFontOfSize:12.0];
    buttonNumberLabel.textAlignment = NSTextAlignmentCenter;
    [button addSubview:buttonNumberLabel];
    
    return button;
}

- (void)scanUserInfo:(UITapGestureRecognizer *)tap
{
    HeUserInfoVC *userInfoVC = [[HeUserInfoVC alloc] init];
    userInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userInfoVC animated:YES];
}

- (void)filterButtonClick:(UIButton *)button
{
    NSLog(@"button = %@",button);
    NSInteger tag = button.tag;
    NSInteger index = tag - 100;
    switch (index) {
        case 0:
        {
            HeMyFansVC *userFansVC = [[HeMyFansVC alloc] init];
            userFansVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userFansVC animated:YES];
            break;
        }
        case 1:{
            HeMyTicketVC *userTicketVC = [[HeMyTicketVC alloc] init];
            userTicketVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userTicketVC animated:YES];
            break;
        }
        case 2:
        {
            HeUserFollowVC *userFollowVC = [[HeUserFollowVC alloc] init];
            userFollowVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:userFollowVC animated:YES];
            break;
        }
        default:
            break;
    }
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
    
    static NSString *cellIndentifier = @"HeUserCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGFloat iconH = 25;
    CGFloat iconW = 25;
    CGFloat iconX = 10;
    CGFloat iconY = (cellSize.height - iconH) / 2.0;
    NSString *image = iconDataSource[section][row];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [cell.contentView addSubview:icon];
    
    NSString *title = dataSource[section][row];
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = iconX + iconW + 10;
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    CGFloat titleW = 200;
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textAlignment = NSTextAlignmentLeft;
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.text = title;
    topicLabel.numberOfLines = 0;
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = textFont;
    topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [cell.contentView addSubview:topicLabel];
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:{
            switch (row) {
                case 0:{
                    HeUserAlbumVC *albumVC = [[HeUserAlbumVC alloc] init];
                    albumVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:albumVC animated:YES];
                    break;
                }
                case 1:{
                    HeUserDistributeVC *distributeContestVC = [[HeUserDistributeVC alloc] init];
                    distributeContestVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:distributeContestVC animated:YES];
                    break;
                }
                case 2:{
                    HeUserJoinVC *userJoinVC = [[HeUserJoinVC alloc] init];
                    userJoinVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:userJoinVC animated:YES];
                    break;
                }
                case 3:{
                    HeUserFinanceVC *financeVC = [[HeUserFinanceVC alloc] init];
                    financeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:financeVC animated:YES];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 1:
        {
            switch (row) {
                case 0:
                {
                    HeSettingVC *settingVC = [[HeSettingVC alloc] init];
                    settingVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:settingVC animated:YES];
                    break;
                }
                
                default:
                    break;
            }
            break;
        }
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
