//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserFinanceVC.h"
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
#import "HeBalanceEditVC.h"
#import "HeModifyPasswordVC.h"
#import "HeBalanceDetailVC.h"

#define TextLineHeight 1.2f

@interface HeUserFinanceVC ()<UITableViewDelegate,UITableViewDataSource>
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
@property(strong,nonatomic)NSDictionary *userBalance;
@property(strong,nonatomic)UILabel *balanceLabel;

@end

@implementation HeUserFinanceVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize iconDataSource;
@synthesize userBGImage;
@synthesize nameLabel;
@synthesize addressLabel;
@synthesize userInfo;
@synthesize balanceLabel;
@synthesize userBalance;

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
        label.text = @"我的资金宝";
        [label sizeToFit];
        
        self.title = @"我的资金宝";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self getBalance];
}


- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@[@"充值",@"提现",@"明细",@"绑定账号",@"支付密码"]];
    iconDataSource = @[@[@"icon_recharge",@"icon_withdrawals",@"icon_withdrawals_detail",@"icon_alipay",@"icon_pay_password"]];
    userInfo = [[User alloc] initUserWithUser:[HeSysbsModel getSysModel].user];
}

- (void)initView
{
    [super initView];
//    self.navigationController.navigationBarHidden = YES;
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    CGFloat headerH = 270;
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerH)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
    tableview.tableHeaderView = sectionHeaderView;
    
    userBGImage = [[UIImageView alloc] init];
    userBGImage.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBarIOS7"]];
    userBGImage.layer.masksToBounds = YES;
    userBGImage.contentMode = UIViewContentModeScaleAspectFill;
    userBGImage.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
    [sectionHeaderView addSubview:userBGImage];
    
    UIFont *textFont = [UIFont systemFontOfSize:20.0];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, SCREENWIDTH - 10, 30)];
    titleLabel.font = [UIFont systemFontOfSize:18.0];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"余额账户（元）";
    titleLabel.textColor = [UIColor whiteColor];
    [sectionHeaderView addSubview:titleLabel];
    
    balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(titleLabel.frame), SCREENWIDTH - 10, 40)];
    balanceLabel.font = textFont;
    balanceLabel.backgroundColor = [UIColor clearColor];
    balanceLabel.textColor = [UIColor whiteColor];
    balanceLabel.text = @"0.00";
    balanceLabel.textColor = [UIColor whiteColor];
    [sectionHeaderView addSubview:balanceLabel];
    
    NSString *tipString = @"根据监管部门要求，账户身份信息的完整程度不同，享有不同的余额支付额度。银行卡等付款方式不收该额度限制。了解更多";
    NSString *subString = @"根据监管部门要求，账户身份信息的完整程度不同，享有不同的余额支付额度。";
    NSMutableAttributedString *hintString = [[NSMutableAttributedString alloc]initWithString:tipString];
    //获取要调整颜色的文字位置,调整颜色
    NSRange range1 = [[hintString string]rangeOfString:subString];
    [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:range1];
    
    subString = @"银行卡等付款方式不收该额度限制。";
    //获取要调整颜色的文字位置,调整颜色
    range1 = [[hintString string]rangeOfString:subString];
    [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range1];
    
    subString = @"了解更多";
    //获取要调整颜色的文字位置,调整颜色
    range1 = [[hintString string]rangeOfString:subString];
    [hintString addAttribute:NSForegroundColorAttributeName value:APPDEFAULTORANGE range:range1];
    
    MLLinkLabel *tipLabel = [[MLLinkLabel alloc] initWithFrame:CGRectMake(10, 200, SCREENWIDTH - 10, 70)];
    tipLabel.numberOfLines = 3;
    tipLabel.font = [UIFont systemFontOfSize:13.0];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.attributedText = hintString;
    tipLabel.textColor = [UIColor grayColor];
    [sectionHeaderView addSubview:tipLabel];
    
    MLLink *labelLink = [MLLink linkWithType:MLLinkTypeURL value:@"http://www.baidu.com" range:range1];
    [tipLabel addLink:labelLink];
    __weak HeUserFinanceVC *weakSelf = self;
    [labelLink setDidClickLinkBlock:^(MLLink *link, NSString *linkText, MLLinkLabel *label) {
        NSString *tips = [NSString stringWithFormat:@"Click\nlinkType:%ld\nlinkText:%@\nlinkValue:%@",(unsigned long)link.linkType,linkText,link.linkValue];
        NSLog(@"%@", tips);
        NSNumber *linkTye = [NSNumber numberWithInteger:link.linkType];
        [[NSNotificationCenter defaultCenter] postNotificationName:LinkNOTIFICATION object:weakSelf userInfo:@{LINKVALUEKey:link.linkValue,LINKTypeKey:linkTye}];
    }];
    
    UIView *footerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 50)];
    
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, SCREENWIDTH - 20, 30)];
    footerLabel.font = [UIFont systemFontOfSize:15.0];
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [UIColor grayColor];
    footerLabel.text = @"提现1 - 2个工作日内到账";
    footerLabel.textColor = [UIColor grayColor];
    [footerview addSubview:footerLabel];
    tableview.tableFooterView = footerview;
    return;
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

- (void)getBalance
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/money/getBalance.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userId};
    [self showHudInView:self.view hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            self.userBalance = respondDict[@"json"];
            balanceLabel.text = [NSString stringWithFormat:@"%.2f",[[userBalance objectForKey:@"userBalance"] floatValue]];
        }
        else{
            NSString *data = respondDict[@"data"];
            if (!data) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
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

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (sec) {
//        <#statements#>
//    }
//    return 10.0;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 50;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 0:
        {
            switch (row) {
                case 0:
                {
                    //充值
                    HeBalanceEditVC *recharegeVC = [[HeBalanceEditVC alloc] init];
                    recharegeVC.banlanceType = Balance_Edit_Recharge;
                    recharegeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:recharegeVC animated:YES];
                    break;
                }
                case 1:
                {
                    //提现
                    CGFloat maxWithDrawMoney = [[userBalance objectForKey:@"userBalance"] floatValue];
                    HeBalanceEditVC *recharegeVC = [[HeBalanceEditVC alloc] init];
                    recharegeVC.banlanceType = Balance_Edit_Withdraw;
                    recharegeVC.maxWithDrawMoney = maxWithDrawMoney;
                    recharegeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:recharegeVC animated:YES];
                    break;
                }
                case 2:
                {
                    //明细
                    HeBalanceDetailVC *balanceDetailVC = [[HeBalanceDetailVC alloc] init];
                    balanceDetailVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:balanceDetailVC animated:YES];
                    break;
                }
                case 3:
                {
                    //账号绑定
                    HeBalanceEditVC *recharegeVC = [[HeBalanceEditVC alloc] init];
                    recharegeVC.banlanceType = Balance_Edit_BindAccount;
                    recharegeVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:recharegeVC animated:YES];
                    break;
                }
                case 4:
                {
                    //支付密码
                    HeModifyPasswordVC *modifyPasswordVC = [[HeModifyPasswordVC alloc] init];
                    modifyPasswordVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:modifyPasswordVC animated:YES];
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

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
