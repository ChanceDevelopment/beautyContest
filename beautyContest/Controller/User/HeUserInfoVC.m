//
//  HeUserInfoVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/9/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserInfoVC.h"
#import "HeBaseTableViewCell.h"
#import "HeBaseIconTitleTableCell.h"
#import "HeSysbsModel.h"
#import "MLLinkLabel.h"
#import "MLLabel+Size.h"
#import "HeEditUserInfoVC.h"
#import "UIButton+Bootstrap.h"
#import "FTPopOverMenu.h"
#import "HeComplaintUserVC.h"
#import "HeComplaintVC.h"

#define TextLineHeight 1.2f
#define HEADTAG 1000
#define SEXTAG 2000
#define NAMETAG 3000
#define ADDRESSTAG 4000

@interface HeUserInfoVC ()<UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)UIView *sectionHeaderView;

@end

@implementation HeUserInfoVC
@synthesize tableview;
@synthesize iconDataSource;
@synthesize dataSource;
@synthesize sectionHeaderView;
@synthesize userInfo;
@synthesize isScanUser;

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
        label.text = @"个人信息";
        [label sizeToFit];
        
        self.title = @"个人信息";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadUserDetail];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@"职业:",@"生日:",@"身高:",@"体重:",@"血型:",@"个性签名:"];
    iconDataSource = @[@"",@"",@"",@"",@"",@""];
    if (!userInfo) {
        userInfo = [HeSysbsModel getSysModel].user;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserInfo:) name:@"updateUserInfo" object:nil];
}

- (void)initView
{
    [super initView];
    
    if (!isScanUser) {
        UIBarButtonItem *editItem = [[UIBarButtonItem alloc] init];
        editItem.title = @"编辑";
        editItem.target = self;
        editItem.action = @selector(editUserInfo:);
        self.navigationItem.rightBarButtonItem = editItem;
    }
    else{
        UIButton *moreButton = [[UIButton alloc] init];
        [moreButton setTitle:@"投诉" forState:UIControlStateNormal];
        [moreButton addTarget:self action:@selector(complaintAction:) forControlEvents:UIControlEventTouchUpInside];
        moreButton.frame = CGRectMake(0, 0, 40, 25);
        [moreButton.titleLabel setFont:[UIFont systemFontOfSize:13.5]];
        
        UIBarButtonItem *complaintItem = [[UIBarButtonItem alloc] initWithCustomView:moreButton];
        self.navigationItem.rightBarButtonItem = complaintItem;
    }
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 170)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 80)];
    bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBarIOS7"]];
    [sectionHeaderView addSubview:bgView];
    
    CGFloat detailImageW = 60;
    CGFloat detailImageH = 60;
    CGFloat detailImageX = (SCREENWIDTH - detailImageW) / 2.0;
    CGFloat detailImageY = CGRectGetMaxY(bgView.frame) - detailImageH / 2.0;
    
    UIImageView *userHeadImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
    userHeadImage.layer.borderWidth = 1.0;
    userHeadImage.layer.borderColor = [UIColor whiteColor].CGColor;
    userHeadImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
    userHeadImage.layer.cornerRadius = detailImageW / 2.0;
    userHeadImage.layer.masksToBounds = YES;
    userHeadImage.contentMode = UIViewContentModeScaleAspectFill;
    [sectionHeaderView addSubview:userHeadImage];
    userHeadImage.tag = HEADTAG;
    
    CGFloat nameX = 0;
    CGFloat nameH = 30;
    CGFloat nameY = CGRectGetMaxY(userHeadImage.frame);
    CGFloat nameW = SCREENWIDTH;
    UILabel *nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = userInfo.userNick;
    nameLabel.tag = NAMETAG;
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = [UIColor blackColor];
    nameLabel.font = [UIFont systemFontOfSize:18.0];
    nameLabel.frame = CGRectMake(nameX, nameY, nameW, nameH);
    [sectionHeaderView addSubview:nameLabel];
    
    
    CGFloat iconW = 20;
    CGFloat iconH = 20;
    CGFloat iconX = (SCREENWIDTH - iconW) / 2.0;
    CGFloat iconY = CGRectGetMaxY(nameLabel.frame);
    NSString *sexName = @"icon_sex_boy";
    if (userInfo.userSex == 2) {
        sexName= @"icon_sex_girl";
    }
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:sexName]];
    icon.tag = SEXTAG;
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [sectionHeaderView addSubview:icon];
    
    CGFloat addressX = 10;
    CGFloat addressH = 30;
    CGFloat addressY = CGRectGetMaxY(icon.frame) + 5;
    CGFloat addressW = SCREENWIDTH - 2 * addressX;
    NSString *address = userInfo.userAddress;
    
    UIFont *textFont = [UIFont systemFontOfSize:15.0];
    CGSize addressSize = [MLLinkLabel getViewSizeByString:address maxWidth:addressW font:textFont lineHeight:TextLineHeight lines:0];
    addressH = addressSize.height;
    if (addressH < 30) {
        addressH = 30;
    }
    
    UILabel *addressLabel = [[UILabel alloc] init];
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = address;
    addressLabel.tag = ADDRESSTAG;
    addressLabel.numberOfLines = 0;
    addressLabel.textColor = [UIColor blackColor];
    addressLabel.font = textFont;
    addressLabel.frame = CGRectMake(addressX, addressY, addressW, addressH);
    [sectionHeaderView addSubview:addressLabel];
    
    CGFloat sectionHeight = CGRectGetMaxY(addressLabel.frame) + 10;
    CGRect sectionFrame = sectionHeaderView.frame;
    sectionFrame.size.height = sectionHeight;
    sectionHeaderView.frame = sectionFrame;
    tableview.tableHeaderView = sectionHeaderView;
}

- (void)complaintAction:(id)sender
{
    HeComplaintUserVC *complaintVC = [[HeComplaintUserVC alloc] init];
    complaintVC.userNick = userInfo.userNick;
    complaintVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:complaintVC animated:YES];
}

- (void)loadUserDetail
{
    if (isScanUser) {
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 60)];
        
        footerView.userInteractionEnabled = YES;
        CGFloat buttonX = 20;
        CGFloat buttonH = 40;
        CGFloat buttonY = 10;
        CGFloat buttonW = SCREENWIDTH - 2 * buttonX;
        UIButton *voteButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        [voteButton setTitle:@"投    票" forState:UIControlStateNormal];
        [voteButton dangerStyle];
        [voteButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:voteButton.frame.size] forState:UIControlStateNormal];
        [voteButton addTarget:self action:@selector(voteUser:) forControlEvents:UIControlEventTouchUpInside];
        [footerView addSubview:voteButton];
        
        tableview.tableFooterView = footerView;
    }
    [self getUserInfo];
}

- (void)voteUser:(id)sender
{
    NSString *voteUser = userInfo.userId;
    if (!voteUser) {
        voteUser = @"";
    }
    NSString *voteHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];//投票者
    if (voteHost == nil) {
        voteHost = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
        if (!voteHost){
            voteHost = @"";
        }
    }
    
    NSString *getUserInfoUrl = [NSString stringWithFormat:@"%@/vote/GodVoteUser.action",BASEURL];
    NSDictionary *loginParams = @{@"voteHost":voteHost,@"voteUser":voteUser};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserInfoUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [self showHint:@"投票成功"];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)updateUserInfo:(NSNotification *)notificaiton
{
    [self getUserInfo];
}

- (void)updateUser
{
    UIImageView *userImage = [sectionHeaderView viewWithTag:HEADTAG];
    NSString *userHeader = userInfo.userHeader;
    if (![userHeader hasPrefix:@"http"]) {
        userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    }
    [userImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:userImage.image];
    
    UILabel *nameLabel = [sectionHeaderView viewWithTag:NAMETAG];
    nameLabel.text = userInfo.userNick;
    
    NSString *sexName = @"icon_sex_boy";
    if (userInfo.userSex == 2) {
        sexName= @"icon_sex_girl";
    }
    UIImageView *icon = [sectionHeaderView viewWithTag:SEXTAG];
    icon.image = [UIImage imageNamed:sexName];
    icon.tag = SEXTAG;
    
    CGFloat addressX = 10;
    CGFloat addressH = 30;
    CGFloat addressY = CGRectGetMaxY(icon.frame) + 5;
    CGFloat addressW = SCREENWIDTH - 2 * addressX;
    
    NSString *address = userInfo.userAddress;
    UIFont *textFont = [UIFont systemFontOfSize:15.0];
    CGSize addressSize = [MLLinkLabel getViewSizeByString:address maxWidth:addressW font:textFont lineHeight:TextLineHeight lines:0];
    addressH = addressSize.height;
    if (addressH < 30) {
        addressH = 30;
    }
    
    
    UILabel *addressLabel = [sectionHeaderView viewWithTag:ADDRESSTAG];
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = address;
    addressLabel.tag = ADDRESSTAG;
    addressLabel.frame = CGRectMake(addressX, addressY, addressW, addressH);
    
    CGFloat sectionHeight = CGRectGetMaxY(addressLabel.frame) + 10;
    CGRect sectionFrame = sectionHeaderView.frame;
    sectionFrame.size.height = sectionHeight;
    sectionHeaderView.frame = sectionFrame;
    tableview.tableHeaderView = sectionHeaderView;
    
}
//获取用户的信息
- (void)getUserInfo
{
    NSString *getUserInfoUrl = [NSString stringWithFormat:@"%@/user/getUserinfo.action",BASEURL];
    NSString *userId = userInfo.userId;
    if ((userId == nil || [userId isEqualToString:@""]) && !isScanUser) {
        userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
        if (!userId){
            userId = @"";
        }
    }
    NSDictionary *loginParams = @{@"userId":userId};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:getUserInfoUrl params:loginParams  success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSDictionary *userDictInfo = [respondDict objectForKey:@"json"];
            NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
            User *user = [[User alloc] initUserWithDict:userDictInfo];
            user.userId = userInfo.userId;
            
            BOOL isthirdPartyLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isthirdPartyLogin"] boolValue];
            NSDictionary *thirdPartyDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"thirdPartyData"];
            
            
            
            if ([userId isEqualToString:myUserId]) {
                NSString *userDataPath = [Tool getUserDataPath];
                NSString *userFileName = [userDataPath stringByAppendingPathComponent:@"userInfo.plist"];
                BOOL succeed = [@{@"user":respondString} writeToFile:userFileName atomically:YES];
                if (succeed) {
                    NSLog(@"用户资料写入成功");
                }
                if (isthirdPartyLogin) {
                    NSString *userHeader = user.userHeader;
                    if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil || [userHeader isEqualToString:@""]) {
                        userHeader = thirdPartyDict[@"userHeader"];
                    }
                    user.userHeader = userHeader;
                    NSString *userNick = user.userNick;
                    if (userNick == nil || [userNick isEqualToString:@""]) {
                        userNick = thirdPartyDict[@"userNick"];
                    }
                    user.userNick = userNick;
                }
                
                [HeSysbsModel getSysModel].user = [[User alloc] initUserWithUser:user];
            }
            
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
                
                NSString *myUserId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
                if ([myUserId isEqualToString:userId]) {
                    BOOL isthirdPartyLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isthirdPartyLogin"] boolValue];
                    NSDictionary *thirdPartyDict = [[NSUserDefaults standardUserDefaults] objectForKey:@"thirdPartyData"];
                    
                    if (isthirdPartyLogin) {
                        NSString *userHeader = user.userHeader;
                        if ([userHeader isMemberOfClass:[NSNull class]] || userHeader == nil || [userHeader isEqualToString:@""]) {
                            userHeader = thirdPartyDict[@"userHeader"];
                        }
                        user.userHeader = userHeader;
                        NSString *userNick = user.userNick;
                        if (userNick == nil || [userNick isEqualToString:@""]) {
                            userNick = thirdPartyDict[@"userNick"];
                        }
                        user.userNick = userNick;
                    }
                }
                
                
                [HeSysbsModel getSysModel].user = [[User alloc] initUserWithUser:user];
            }
        }
        
    } failure:^(NSError *error){
        [self hideHud];
        [self showHint:ERRORREQUESTTIP];
    }];
    
}

- (void)editUserInfo:(UIBarButtonItem *)item
{
    HeEditUserInfoVC *editInfoVC = [[HeEditUserInfoVC alloc] init];
    editInfoVC.userInfo = [[User alloc] initUserWithUser:userInfo];
    editInfoVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:editInfoVC animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeUserCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseIconTitleTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseIconTitleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGFloat iconH = 25;
    CGFloat iconW = 25;
    CGFloat iconX = 10;
    CGFloat iconY = (cellSize.height - iconH) / 2.0;
    NSString *image = iconDataSource[row];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [cell.contentView addSubview:icon];
    
    NSString *title = dataSource[row];
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = iconX + iconW + 10;
    if (icon.image == nil) {
        titleX = 10;
    }
    id content = @"未设置";
    switch (row) {
        case 0:
        {
            content = userInfo.infoProfession;
            break;
        }
        case 1:
        {
            content = userInfo.infoBirth;
            if (userInfo.infoBirth.length > 5) {
                @try {
                    content = [userInfo.infoBirth substringFromIndex:5];
                } @catch (NSException *exception) {
                    
                } @finally {
        
                }
                
            }
            break;
        }
        case 2:
        {
            if ([userInfo.infoTall isEqualToString:@""]) {
                content = @"";
            }
            else{
                content = [NSString stringWithFormat:@"%.1lf",[userInfo.infoTall floatValue]];
            }
            
            break;
        }
        case 3:
        {
            if ([userInfo.infoTall isEqualToString:@""]) {
                content = @"";
            }
            else{
                content = [NSString stringWithFormat:@"%.1lf",[userInfo.infoWeight floatValue]];
            }
            
            break;
        }
        case 4:
        {
            content = userInfo.infoBlood;
            break;
        }
        case 5:
        {
            content = userInfo.userSign;
            break;
        }
        default:
            break;
    }
    if ([content isKindOfClass:[NSString class]]) {
        if (content == nil || [content isEqualToString:@""]) {
            content = @"未设置";
        }
    }
    
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    CGFloat titleW = SCREENWIDTH - titleX - 10;
    UILabel *topicLabel = [[UILabel alloc] init];
    topicLabel.textAlignment = NSTextAlignmentLeft;
    topicLabel.backgroundColor = [UIColor clearColor];
    topicLabel.text = [NSString stringWithFormat:@"%@  %@",title,content];
    topicLabel.numberOfLines = 0;
    topicLabel.textColor = [UIColor blackColor];
    topicLabel.font = textFont;
    topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [cell.contentView addSubview:topicLabel];
    
    
    
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
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
