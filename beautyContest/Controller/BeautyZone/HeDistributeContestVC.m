//
//  HeDistributeContestVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/8/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeDistributeContestVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestRankVC.h"
#import "HeBaseIconTitleTableCell.h"
#import "ZJSwitch.h"

#define TextLineHeight 1.2f

@interface HeDistributeContestVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSDictionary *contestDetailDict;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)NSArray *titleDataSource;
@property(strong,nonatomic)UITextField *titleField;

@end

@implementation HeDistributeContestVC
@synthesize contestDetailDict;
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize iconDataSource;
@synthesize titleDataSource;
@synthesize titleField;

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
    iconDataSource = @[@[@""],@[@""],@[@"icon_time",@"icon_location",@"icon_sex_boy",@"icon_sex_girl",@"",@""]];
    titleDataSource = @[@[@""],@[@"主题广告"],@[@"截止时间",@"定位",@"男生参加",@"女生参加",@"",@""]];
}

- (void)initView
{
    [super initView];
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] init];
    distributeItem.title = @"发布";
    distributeItem.target = self;
    distributeItem.action = @selector(distributeContest:);
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index2.jpg"]];
    bgImage.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    titleField = [[UITextField alloc] init];
    titleField.layer.borderColor = [UIColor clearColor].CGColor;
    titleField.delegate = self;
    titleField.placeholder = @"请输入比赛主题";
    titleField.font = [UIFont systemFontOfSize:15.0];
    titleField.textColor = [UIColor blackColor];
}

- (void)distributeContest:(UIBarButtonItem *)barItem
{
    NSLog(@"distributeContest");
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [iconDataSource[section] count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [iconDataSource count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeBaseIconTitleTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseIconTitleTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseIconTitleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    UIFont *textFont = [UIFont  boldSystemFontOfSize:18.0];
    cell.topicLabel.font = textFont;
    cell.topicLabel.textColor = APPDEFAULTORANGE;
    
    NSString *iconName = iconDataSource[section][row];
    NSString *title = titleDataSource[section][row];
    
    cell.icon.image = [UIImage imageNamed:iconName];
    cell.topicLabel.text = title;
    
    CGFloat labelX = 10;
    CGFloat labelH = cellSize.height;
    CGFloat labelY = 0;
    CGFloat labelW = 200;
    
    switch (section) {
        case 0:
        {
            titleField.frame = CGRectMake(labelX, labelY, labelW, labelH);
            [cell addSubview:titleField];
            break;
        }
        case 1:{
            CGFloat iconW = 20;
            CGFloat iconH = 20;
            CGFloat iconX = SCREENWIDTH - iconW - 10;
            CGFloat iconY = (cellSize.height - iconH) / 2.0;
            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_edit"]];
            icon.frame = CGRectMake(iconX , iconY, iconW, iconH);
            [cell addSubview:icon];
            
            CGRect frame = cell.topicLabel.frame;
            frame.origin.x = labelX;
            cell.topicLabel.frame = frame;
            cell.topicLabel.text = @"主题广告";
            break;
        }
        case 2:{
            switch (row) {
                case 0:
                {
                    CGFloat iconW = 20;
                    CGFloat iconH = 20;
                    CGFloat iconX = SCREENWIDTH - iconW - 10;
                    CGFloat iconY = (cellSize.height - iconH) / 2.0;
                    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
                    icon.frame = CGRectMake(iconX , iconY, iconW, iconH);
                    [cell addSubview:icon];
                    
                    
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - iconW - 15 - 100, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = @"2016/02/17";
                    [cell addSubview:tipLabel];
                    
                    break;
                }
                case 1:
                {
                    CGFloat iconW = 20;
                    CGFloat iconH = 20;
                    CGFloat iconX = SCREENWIDTH - iconW - 10;
                    CGFloat iconY = (cellSize.height - iconH) / 2.0;
                    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
                    icon.frame = CGRectMake(iconX , iconY, iconW, iconH);
                    [cell addSubview:icon];
                    
                    
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - iconW - 15 - 100, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = @"广东珠海";
                    [cell addSubview:tipLabel];
                    break;
                }
                case 2:
                {
                    CGFloat zjSwitchW = 50;
                    CGFloat zjSwitchH = 30;
                    CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
                    CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
                    ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
                    [cell addSubview:zjSwitch];
                    break;
                }
                case 3:
                {
                    CGFloat zjSwitchW = 50;
                    CGFloat zjSwitchH = 30;
                    CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
                    CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
                    ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
                    [cell addSubview:zjSwitch];
                    break;
                }
                case 4:
                {
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - 110, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = @"￥ 0.00";
                    [cell addSubview:tipLabel];
                    break;
                }
                case 5:
                {
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - 110, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = @"平台回收20%赏金";
                    [cell addSubview:tipLabel];
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
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    switch (row) {
        case 2:
        {
            NSString *address = @"广东省中山市西区长乐新村10栋601会议厅8楼8501";
            CGFloat labelW = 0;
            UIFont *font = [UIFont  boldSystemFontOfSize:16.0];
            CGSize textSize = [MLLinkLabel getViewSizeByString:address maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
            if (textSize.height < 50) {
                textSize.height = 50;
            }
            return textSize.height + 10;
            break;
        }
        default:
            break;
    }
    
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
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
