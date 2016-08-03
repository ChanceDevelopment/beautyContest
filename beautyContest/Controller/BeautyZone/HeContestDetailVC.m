//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestDetailVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "HeContestRankVC.h"
#import "HeBaseIconTitleTableCell.h"

#define TextLineHeight 1.2f

@interface HeContestDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSDictionary *contestDetailDict;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)IBOutlet UIView *footerView;

@end

@implementation HeContestDetailVC
@synthesize contestBaseDict;
@synthesize contestDetailDict;
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize iconDataSource;
@synthesize footerView;

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
        label.text = @"赛区详情";
        [label sizeToFit];
        
        self.title = @"赛区详情";
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
    iconDataSource = @[@"",@"icon_time",@"icon_location",@"icon_sponsor",@"icon_puter",@""];
}

- (void)initView
{
    [super initView];
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
    
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(shareButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    distributeItem.target = self;
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    CGFloat buttonX = 10;
    CGFloat buttonY = 5;
    CGFloat buttonH = 40;
    CGFloat buttonW = SCREENWIDTH / 2.0 - 2 * buttonX;
    UIButton *joinButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"参加" image:@"appIcon"];
    joinButton.tag = 1;
    [joinButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:joinButton];
    
    UIButton *commentButton = [Tool getButton:CGRectMake(SCREENWIDTH / 2.0 + buttonX, buttonY, buttonW, buttonH) title:@"评论" image:@"icon_comment"];
    joinButton.tag = 2;
    [commentButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:commentButton];
}

- (void)buttonClick:(UIButton *)button
{

}

- (void)shareButtonClick:(UIButton *)shareButton
{

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [iconDataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
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
    cell.topicLabel.font = [UIFont  systemFontOfSize:16.0];
    cell.topicLabel.textColor = [UIColor grayColor];
    
    NSString *iconName = iconDataSource[row];
    cell.icon.image = [UIImage imageNamed:iconName];
    switch (row) {
        case 0:
        {
            cell.topicLabel.font = [UIFont  boldSystemFontOfSize:20.0];
            CGRect topFrame = cell.topicLabel.frame;
            topFrame.origin.x = 10;
            topFrame.size.width = SCREENWIDTH - 2 * topFrame.origin.x;
            cell.topicLabel.frame = topFrame;
            cell.topicLabel.textColor = [UIColor blackColor];
            cell.topicLabel.text = @"赛区主题";
            break;
        }
        case 1:
        {
            
            cell.topicLabel.text = @"2016/05/25 周六 13:00 ~ 17:00";
            break;
        }
        case 2:
        {
            cell.topicLabel.numberOfLines = 2;
            cell.topicLabel.text = @"广东省中山市西区长乐新村10栋601会议厅8楼8501";
            break;
        }
        case 3:
        {
            cell.topicLabel.text = @"主办方: 腾讯众创空间杭州站";
            break;
        }
        case 4:
        {
            cell.topicLabel.text = @"发布者";
            break;
        }
        case 5:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.topicLabel.text = @"我的排名";
            CGRect topFrame = cell.topicLabel.frame;
            topFrame.origin.x = 10;
            topFrame.size.width = SCREENWIDTH - 2 * topFrame.origin.x;
            cell.topicLabel.frame = topFrame;
            cell.topicLabel.textColor = [UIColor blackColor];
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
    
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (row) {
        case 5:
        {
            HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
            contestRankVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestRankVC animated:YES];
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
