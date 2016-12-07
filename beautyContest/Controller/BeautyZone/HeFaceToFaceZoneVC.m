//
//  HeFaceToFaceZoneVC.m
//  beautyContest
//
//  Created by Danertu on 16/10/25.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeFaceToFaceZoneVC.h"
#import "HeFaceCreatZoneVC.h"

@interface HeFaceToFaceZoneVC ()<UITextFieldDelegate>
@property(strong,nonatomic)IBOutlet UITextField *myTextField;

@property(strong,nonatomic)IBOutlet UILabel *myNumLabel1;
@property(strong,nonatomic)IBOutlet UILabel *myNumLabel2;
@property(strong,nonatomic)IBOutlet UILabel *myNumLabel3;
@property(strong,nonatomic)IBOutlet UILabel *myNumLabel4;

@property(strong,nonatomic)IBOutlet UIImageView *myViewPoint1;
@property(strong,nonatomic)IBOutlet UIImageView *myViewPoint2;
@property(strong,nonatomic)IBOutlet UIImageView *myViewPoint3;
@property(strong,nonatomic)IBOutlet UIImageView *myViewPoint4;

@end

@implementation HeFaceToFaceZoneVC
@synthesize myTextField;
@synthesize myNumLabel1;
@synthesize myNumLabel2;
@synthesize myNumLabel3;
@synthesize myNumLabel4;

@synthesize myViewPoint1;
@synthesize myViewPoint2;
@synthesize myViewPoint3;
@synthesize myViewPoint4;

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
        label.text = @"面对面创建赛区";
        [label sizeToFit];
        
        self.title = @"面对面创建赛区";
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
}

- (void)initView
{
    [super initView];
    [myTextField becomeFirstResponder];
    myTextField.inputAccessoryView = [self addToolbar];
}

- (void)creatFaceToFaceZoneWithPassword:(NSString *)password
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/zone/createNewTemporary.action",BASEURL];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestParamDict = @{@"userid":userId,@"userpassword":password};
    [self showHudInView:self.view hint:@"创建中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestParamDict success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            HeFaceCreatZoneVC *faceZoneVC = [[HeFaceCreatZoneVC alloc] init];
            faceZoneVC.zonePassword = [[NSString alloc] initWithFormat:@"%@",password];
            faceZoneVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:faceZoneVC animated:YES];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"";
            }
            [self showHint:data];
        }
        
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

//删除临时赛区
- (void)delTemporary
{
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSDictionary *params = @{@"userid":userid};
    NSString *requestRecommendDataPath = [NSString stringWithFormat:@"%@/zone/delTemporayByUserid.action",BASEURL];
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            //            [self showHint:data];
        }
        
        
    } failure:^(NSError *error){
    }];
}

- (UIToolbar *)addToolbar
{
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame), 35)];
    toolbar.tintColor = [UIColor blueColor];
    toolbar.backgroundColor = [UIColor clearColor];
//    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"下一步" style:UIBarButtonItemStylePlain target:self action:@selector(nextTextField)];
//    UIBarButtonItem *prevButton = [[UIBarButtonItem alloc] initWithTitle:@"上一步" style:UIBarButtonItemStylePlain target:self action:@selector(prevTextField)];
//    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    UIBarButtonItem *bar = [[UIBarButtonItem alloc] initWithTitle:@"完成" style:UIBarButtonItemStylePlain target:self action:@selector(textFieldDone)];
    toolbar.items = nil;
    return toolbar;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if (textField.text.length > 4) {
        textField.text = [textField.text substringToIndex:4];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSLog(@"textField.text = %@",textField.text);
    NSInteger length = textField.text.length;
    NSString *historyString = textField.text;
    for (NSInteger index = 0; index < length; index++) {
        NSRange range = NSMakeRange(index, 1);
        NSString *subString = [historyString substringWithRange:range];
        UILabel *label = [self.view viewWithTag:index + 1];
        label.hidden = NO;
        label.text = subString;
        
        UIImageView *icon = [self.view viewWithTag:index + 1 + 10];
        icon.hidden = YES;
    }
    NSInteger offset = 1;
    if ([string isEqualToString:@""]) {
        offset = 0;
    }
    NSInteger lastTag = length + offset;
    UILabel *lastLabel = [self.view viewWithTag:lastTag];
    lastLabel.text = string;
    if (offset == 1) {
        lastLabel.hidden = NO;
    }
    else{
        lastLabel.hidden = YES;
    }
    
    UIImageView *icon = [self.view viewWithTag:lastTag + 10];
    if (offset == 1) {
        icon.hidden = YES;
    }
    else{
        icon.hidden = NO;
    }
    
    
    if (length + offset < 4) {
        NSInteger startIndex = length + offset;
        for (NSInteger index = startIndex; index < 4; index++) {
            UILabel *label = [self.view viewWithTag:index + 1];
            label.hidden = YES;
            label.text = @"";
            
            UIImageView *icon = [self.view viewWithTag:index + 1 + 10];
            icon.hidden = NO;
        }
    }
    
    if (![string isEqualToString:@""]) {
        NSString *password = [NSString stringWithFormat:@"%@%@",textField.text,string];
        if (password.length == 4) {
            if ([myTextField isFirstResponder]) {
                [myTextField resignFirstResponder];
            }
            [self performSelector:@selector(creatFaceToFaceZoneWithPassword:) withObject:password afterDelay:0.2];
        }
    }
    NSLog(@"string = %@",string);
    if (string.length == 0) return YES;
    
        NSInteger existedLength = textField.text.length;
        NSInteger selectedLength = range.length;
        NSInteger replaceLength = string.length;
        if (existedLength - selectedLength + replaceLength > 4) {
            return NO;
    }
    
    return YES;
}

- (void)backItemClick:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"delTemporaryNotification" object:nil];
    [self.navigationController popViewControllerAnimated:YES];
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
