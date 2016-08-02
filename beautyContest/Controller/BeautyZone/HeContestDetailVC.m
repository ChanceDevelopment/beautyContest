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

#define TextLineHeight 1.2f

@interface HeContestDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSDictionary *contestDetailDict;
@property(strong,nonatomic)UIView *sectionHeaderView;

@end

@implementation HeContestDetailVC
@synthesize contestBaseDict;
@synthesize contestDetailDict;
@synthesize tableview;
@synthesize sectionHeaderView;

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
}

- (void)initView
{
    [super initView];
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor whiteColor];
    [Tool setExtraCellLineHidden:tableview];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    static NSString *cellIndentifier = @"HeContestDetailIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    UIView *circleView = [[UIView alloc] initWithFrame:CGRectMake(5, (cellSize.height - 3) / 2.0, 3, 3)];
    circleView.backgroundColor = [UIColor colorWithRed:164.0 / 255.0 green:57 / 255.0 blue:5.0 / 255.0 alpha:1.0];
    circleView.layer.cornerRadius = 1.5;
    circleView.layer.masksToBounds = YES;
    [cell.contentView addSubview:circleView];
    
    
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return sectionHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeaderView.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    NSString *title = [contestDetailDict objectForKey:@"title"];
    if ([title isMemberOfClass:[NSNull class]] || title == nil) {
        title = @"";
    }
    CGFloat titleW = SCREENWIDTH - 33;
    CGFloat titleH = [MLLinkLabel getViewSizeByString:title maxWidth:titleW font:textFont lineHeight:TextLineHeight lines:0].height;
    if (titleH < 30) {
        titleH = 30;
    }
    CGFloat margin = 10;
    
    return titleH + 2 * margin;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    HeContestRankVC *contestRankVC = [[HeContestRankVC alloc] init];
    contestRankVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:contestRankVC animated:YES];
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
