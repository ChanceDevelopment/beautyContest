//
//  HeDistributeRecommendVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/8/24.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeDistributeRecommendVC.h"
#import "UIButton+Bootstrap.h"
#import "HeBaseTableViewCell.h"
#import "SAMTextView.h"

@interface HeDistributeRecommendVC ()<UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)IBOutlet UIButton *distributeButton;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSMutableArray *imageArray;
@property(strong,nonatomic)SAMTextView *recommendTextView;
@property(strong,nonatomic)UIButton *addPhotoButton;
@property(strong,nonatomic)UIButton *addVideoButton;
@property(strong,nonatomic)UITextField *redPocketTextField;
@property(strong,nonatomic)UITextField *redPocketNumField;

@end

@implementation HeDistributeRecommendVC
@synthesize tableview;
@synthesize distributeButton;
@synthesize dataSource;
@synthesize imageArray;
@synthesize recommendTextView;
@synthesize addPhotoButton;
@synthesize addVideoButton;
@synthesize redPocketTextField;
@synthesize redPocketNumField;

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
        label.text = @"发布推荐";
        [label sizeToFit];
        
        self.title = @"发布推荐";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    dataSource = @[@[@"推荐自己"],@[@"添加图片",@""],@[@"添加视频",@""],@[@"红包",@"红包个数"]];
    imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    CGFloat textViewX = 5;
    CGFloat textViewY = 5;
    CGFloat textViewW = SCREENWIDTH - 2 * textViewX;
    CGFloat textViewH = 130;
    recommendTextView = [[SAMTextView alloc] initWithFrame:CGRectMake(textViewX, textViewY, textViewW, textViewH)];
    recommendTextView.layer.borderColor = [UIColor clearColor].CGColor;
    recommendTextView.font = [UIFont systemFontOfSize:18.0];
    recommendTextView.textColor = [UIColor blackColor];
    recommendTextView.placeholder = @"推荐自己...";
    recommendTextView.delegate = self;
}

- (void)initView
{
    [super initView];
//    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] init];
//    distributeItem.title = @"发布";
//    distributeItem.action = @selector(distributeRecommend:);
//    self.navigationItem.rightBarButtonItem = distributeItem;
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 1)];
    tableview.tableHeaderView = headerview;
//    [distributeButton dangerStyle];
    distributeButton.layer.borderColor = [UIColor clearColor].CGColor;
    [distributeButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:distributeButton.frame.size] forState:UIControlStateNormal];
    
    addPhotoButton = [[UIButton alloc] init];
    [addPhotoButton setBackgroundImage:[UIImage imageNamed:@"icon_add_pho"] forState:UIControlStateNormal];
    addPhotoButton.tag = 100;
    [addPhotoButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    addVideoButton = [[UIButton alloc] init];
    [addVideoButton setBackgroundImage:[UIImage imageNamed:@"icon_add_pho"] forState:UIControlStateNormal];
    addVideoButton.tag = 200;
    [addVideoButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    redPocketTextField = [[UITextField alloc] init];
    redPocketTextField.font = [UIFont systemFontOfSize:16.0];
    redPocketTextField.textColor = APPDEFAULTORANGE;
    redPocketTextField.placeholder = @"0.00";
    redPocketTextField.textAlignment = NSTextAlignmentRight;
    redPocketTextField.delegate = self;
    
    redPocketNumField = [[UITextField alloc] init];
    redPocketNumField.font = [UIFont systemFontOfSize:16.0];
    redPocketNumField.textColor = APPDEFAULTORANGE;
    redPocketNumField.placeholder = @"输入红包个数";
    redPocketNumField.textAlignment = NSTextAlignmentRight;
    redPocketNumField.delegate = self;
    
    
    
}

- (void)distributeRecommend:(UIBarButtonItem *)item
{
    
}

- (IBAction)distributeButtonClick:(id)sender
{

}

- (void)addButtonClick:(UIButton *)sender
{

}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    return YES;
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
    
    static NSString *cellIndentifier = @"HeBaseIconTitleTableCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseTableViewCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier cellSize:cellSize];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.textLabel.text = dataSource[section][row];
    cell.textLabel.textColor = APPDEFAULTORANGE;
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    switch (section) {
        case 0:
        {
            [cell addSubview:recommendTextView];
            break;
        }
        case 1:
        {
            switch (row) {
                case 1:
                {
                    CGFloat buttonX = 10;
                    CGFloat buttonY = 10;
                    CGFloat buttonH = cellSize.height - 2 * buttonY;
                    CGFloat buttonW = buttonH;
                    addPhotoButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
                    [cell addSubview:addPhotoButton];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 2:
        {
            switch (row) {
                case 1:
                {
                    CGFloat buttonX = 10;
                    CGFloat buttonY = 10;
                    CGFloat buttonH = cellSize.height - 2 * buttonY;
                    CGFloat buttonW = buttonH;
                    addVideoButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
                    [cell addSubview:addVideoButton];
                    break;
                }
                default:
                    break;
            }
            break;
        }
        case 3:
        {
            switch (row) {
                case 0:
                {
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 50, 0, 50, cellSize.height)];
                    titleLabel.font = [UIFont systemFontOfSize:16.0];
                    titleLabel.textColor = APPDEFAULTORANGE;
                    titleLabel.text = @"元";
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [cell addSubview:titleLabel];
                    
                    CGFloat textW = 150;
                    CGFloat textX = SCREENWIDTH - 10 - textW - 40;
                    CGFloat textY = 0;
                    CGFloat textH = cellSize.height;
                    redPocketTextField.frame = CGRectMake(textX, textY, textW, textH);
                    [cell addSubview:redPocketTextField];
                    break;
                }
                case 1:
                {
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 60, 0, 50, cellSize.height)];
                    titleLabel.font = [UIFont systemFontOfSize:16.0];
                    titleLabel.textColor = APPDEFAULTORANGE;
                    titleLabel.text = @"个";
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [cell addSubview:titleLabel];
                    
                    CGFloat textW = 150;
                    CGFloat textX = SCREENWIDTH - 10 - textW - 50;
                    CGFloat textY = 0;
                    CGFloat textH = cellSize.height;
                    redPocketNumField.frame = CGRectMake(textX, textY, textW, textH);
                    [cell addSubview:redPocketNumField];
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
        case 0:
            return 150;
            break;
        case 1:{
            switch (row) {
                case 1:
                {
                    return 100;
                    break;
                }
                default:
                    break;
            }
        }
        case 2:{
            switch (row) {
                case 1:
                {
                    return 100;
                    break;
                }
                default:
                    break;
            }
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
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return nil;
    }
    
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
    headerview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    return headerview;
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
