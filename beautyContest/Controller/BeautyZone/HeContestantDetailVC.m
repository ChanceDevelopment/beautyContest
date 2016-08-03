//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeContestantDetailVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "MLLinkLabel.h"

#define TextLineHeight 1.2f

@interface HeContestantDetailVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL requestReply; //是否已经完成
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)IBOutlet UIView *footerView;
@property(strong,nonatomic)UILabel *nameLabel;
@property(strong,nonatomic)UIButton *followButton;
@property(strong,nonatomic)UIImageView *detailImage;
@property(strong,nonatomic)UILabel *userNoLabel;
@property(strong,nonatomic)UILabel *supportNumLabel;

@end

@implementation HeContestantDetailVC
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize footerView;
@synthesize nameLabel;
@synthesize followButton;
@synthesize detailImage;
@synthesize userNoLabel;
@synthesize supportNumLabel;

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
        label.text = @"参赛者详情";
        [label sizeToFit];
        
        self.title = @"参赛者详情";
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
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    CGFloat headerH = 200;
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerH)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    CGFloat imageX = 10;
    CGFloat imageY = 10;
    CGFloat imageW = SCREENWIDTH - 2 * imageX;
    CGFloat imageH = headerH - 2 * imageY;
    UIImageView *bgImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index2.jpg"]];
    bgImage.frame = CGRectMake(imageX, imageY, imageW, imageH);
    bgImage.layer.masksToBounds = YES;
    bgImage.layer.cornerRadius = 5.0;
    bgImage.contentMode = UIViewContentModeScaleAspectFill;
    bgImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:bgImage];
    
    
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = 10;
    CGFloat titleH = 30;
    CGFloat titleY = imageH - titleH - 50;
    CGFloat titleW = (imageW - 2 *titleX) / 2.0;
    
    NSString *name = @"何栋明";
    
    CGSize nameSize = [MLLinkLabel getViewSizeByString:name maxWidth:200 font:textFont lineHeight:TextLineHeight lines:0];
    titleW = nameSize.width;
    
    nameLabel = [[UILabel alloc] init];
    nameLabel.textAlignment = NSTextAlignmentLeft;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = name;
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = APPDEFAULTORANGE;
    nameLabel.font = textFont;
    nameLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
    [bgImage addSubview:nameLabel];
    
    CGFloat buttonX = titleX + titleW + 10;
    CGFloat buttonY = titleY;
    CGFloat buttonW = 60;
    CGFloat buttonH = titleH;
    followButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [followButton setTitle:@"关注" forState:UIControlStateNormal];
    [followButton setTitleColor:APPDEFAULTORANGE forState:UIControlStateNormal];
    followButton.layer.masksToBounds = YES;
    followButton.layer.cornerRadius = 3.0;
    followButton.layer.borderWidth = 1.0;
    [followButton.titleLabel setFont:textFont];
    [followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    followButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [bgImage addSubview:followButton];
    
    CGFloat detailImageW = 30;
    CGFloat detailImageH = 30;
    CGFloat detailImageX = imageW - detailImageW - titleX;
    CGFloat detailImageY = imageH - titleH - 10;
    
    detailImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index4.jpg"]];
    detailImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
    detailImage.layer.cornerRadius = detailImageW / 2.0;
    detailImage.layer.masksToBounds = YES;
    detailImage.contentMode = UIViewContentModeScaleAspectFill;
    [bgImage addSubview:detailImage];
    
    CGFloat iconX = titleX;
    CGFloat iconW = 30;
    CGFloat iconH = 30;
    CGFloat iconY = CGRectGetMaxY(detailImage.frame) - iconH;
    
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [bgImage addSubview:icon];
    
    userNoLabel = [[UILabel alloc] init];
    userNoLabel.textAlignment = NSTextAlignmentLeft;
    userNoLabel.backgroundColor = [UIColor clearColor];
    userNoLabel.text = @"选美号:10086";
    userNoLabel.numberOfLines = 1;
    userNoLabel.textColor = [UIColor whiteColor];
    userNoLabel.font = [UIFont systemFontOfSize:13.0];
    userNoLabel.frame = CGRectMake(iconX + iconW + 5, iconY, 100, iconH);
    [bgImage addSubview:userNoLabel];
    
    CGFloat tiptitleX = (imageW - 2 *titleX) / 2.0;
    CGFloat tiptitleH = 30;
    CGFloat tiptitleY = iconY;
    CGFloat tiptitleW = (imageW - 2 *titleX) / 2.0 - detailImageW - titleX;
    
    supportNumLabel = [[UILabel alloc] init];
    supportNumLabel.textAlignment = NSTextAlignmentRight;
    supportNumLabel.backgroundColor = [UIColor clearColor];
    supportNumLabel.text = @"票数:62";
    supportNumLabel.numberOfLines = 1;
    supportNumLabel.textColor = [UIColor whiteColor];
    supportNumLabel.font = [UIFont systemFontOfSize:13.0];
    supportNumLabel.frame = CGRectMake(tiptitleX, tiptitleY, tiptitleW, tiptitleH);
    [bgImage addSubview:supportNumLabel];
    
    
    buttonX = 10;
    buttonY = 5;
    buttonH = 40;
    buttonW = SCREENWIDTH / 2.0 - 2 * buttonX;
    
    UIButton *joinButton = [Tool getButton:CGRectMake(buttonX, buttonY, buttonW, buttonH) title:@"投票" image:@"icon_love"];
    joinButton.tag = 1;
    [joinButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [joinButton setBackgroundImage:[Tool buttonImageFromColor:[UIColor orangeColor] withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:joinButton];
    
    UIButton *commentButton = [Tool getButton:CGRectMake(SCREENWIDTH / 2.0 + buttonX, buttonY, buttonW, buttonH) title:@"留言" image:@"icon_comment"];
    joinButton.tag = 2;
    [commentButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    [commentButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:joinButton.frame.size] forState:UIControlStateNormal];
    [footerView addSubview:commentButton];
    
    
}

- (void)followButtonClick:(UIButton *)button
{
     NSLog(@"button = %@",button);
}

- (void)buttonClick:(UIButton *)button
{
    NSLog(@"button = %@",button);
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 1:
        {
            return 2;
            break;
        }
        default:
            break;
    }
    return 1;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeContestantDetailIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        
    }
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    switch (section) {
        case 0:
        {
            cell.textLabel.text = @"个人信息";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:16.0];
            cell.textLabel.textColor = APPDEFAULTORANGE;
            
            UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellSize.width - 110, 0, 100, cellSize.height)];
            tipLabel.text = @"发布人可见";
            tipLabel.textColor = [UIColor grayColor];
            tipLabel.textAlignment = NSTextAlignmentRight;
            tipLabel.font = textFont;
            [cell addSubview:tipLabel];
            break;
        }
        case 1:
        {
            switch (row) {
                case 0:
                {
                    cell.textLabel.text = @"希望大家多多给我投票";
                    cell.textLabel.font = textFont;
                    cell.textLabel.textColor = [UIColor grayColor];
                    break;
                }
                case 1:{
                    CGFloat imageNum = 3;
                    CGFloat imageDistance = 10;
                    CGFloat imageX = 10;
                    CGFloat imageY = 10;
                    CGFloat imageH = cellSize.height - 2 * imageY;
                    CGFloat imageW = (cellSize.width - 2 * imageX - 20 - (imageNum - 1) * imageDistance) / imageNum;
                    for (NSInteger index = 0; index < imageNum; index++) {
                        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index3.jpg"]];
                        imageView.frame = CGRectMake(imageX, imageY, imageW, imageH);
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        imageView.layer.masksToBounds = YES;
                        imageX = imageX + imageW + imageDistance;
                        [cell addSubview:imageView];
                    }
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
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
    switch (section) {
        case 1:
        {
            switch (row) {
                case 1:
                {
                    return 80;
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
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
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
