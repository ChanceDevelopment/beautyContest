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

#define TextLineHeight 1.2f

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

@end

@implementation HeUserVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize iconDataSource;
@synthesize userBGImage;
@synthesize nameLabel;
@synthesize addressLabel;

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

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@[@"我的相册",@"我的发布",@"我的参与"],@[@"设置"]];
    iconDataSource = @[@[@"icon_album",@"icon_put",@"icon_participation"],@[@"icon_setting"]];
}

- (void)initView
{
    [super initView];
    self.navigationController.navigationBarHidden = YES;
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    dataSource = @[@[@"我的相册",@"我的发布",@"我的参与"],@[@"设置"]];
    
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
    nameLabel.text = @"Tony";
    nameLabel.textAlignment = NSTextAlignmentCenter;
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = textFont;
    nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH);
    [sectionHeaderView addSubview:nameLabel];
    nameLabel.center = userBGImage.center;
    CGRect nameFrame = nameLabel.frame;
    nameFrame.origin.y = nameFrame.origin.y - 20;
    nameLabel.frame = nameFrame;
    
    CGFloat addressLabelX = 0;
    CGFloat addressLabelY = CGRectGetMaxY(nameLabel.frame);
    CGFloat addressLabelH = 40;
    CGFloat addressLabelW = SCREENWIDTH;
    addressLabel = [[UILabel alloc] init];
    addressLabel.textAlignment = NSTextAlignmentLeft;
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.text = @"广东.珠海";
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
        [buttonBG addSubview:button];
    }
    
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
    buttonNumberLabel.text = @"125";
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
