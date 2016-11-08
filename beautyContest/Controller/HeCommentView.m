//
//  HeCommentView.m
//  beautyContest
//
//  Created by Tony on 16/8/25.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeCommentView.h"
#import "AppDelegate.h"
#import "HeTabBarVC.h"
#import "CustomNavigationController.h"
#import "CPTextViewPlaceholder.h"
#import "SAMTextView.h"

@interface HeCommentView ()<UITextViewDelegate>
@property(strong,nonatomic)IBOutlet SAMTextView *commentTextView;
@property(strong,nonatomic)IBOutlet UILabel *inputTextLengthLabel;

@end

@implementation HeCommentView
@synthesize commentTextView;
@synthesize limitNumber;
@synthesize inputTextLengthLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)initializaiton
{
    [super initializaiton];
    if (limitNumber == 0) {
        limitNumber = 64;
    }
}

- (void)initView
{
    [super initView];
    CGRect rectNav = ((CustomNavigationController *)([((HeTabBarVC *)((AppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController).viewControllers firstObject])).navigationBar.frame;
    
    CGRect rectStatus = [[UIApplication sharedApplication] statusBarFrame];
    rectNav.size.height = rectNav.size.height + rectStatus.size.height;
    
    UIImage *navBackgroundImage = [UIImage imageNamed:@"NavBarIOS7"];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:20.0]};
    rectNav.origin.y = 0;
    UINavigationBar *narvigationBar = [[UINavigationBar alloc] initWithFrame:rectNav];
    [narvigationBar setTintColor:NAVTINTCOLOR];
    [narvigationBar setBackgroundImage:navBackgroundImage forBarMetrics:UIBarMetricsDefault];
    [narvigationBar setTitleTextAttributes:attributeDict];
    [self.view addSubview:narvigationBar];
    
    UINavigationItem *navitem = [[UINavigationItem alloc] initWithTitle:@""];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize:20.0];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"评论";
    if (self.title) {
        label.text = self.title;
    }
    [label sizeToFit];
    navitem.titleView = label;
    [narvigationBar pushNavigationItem:navitem animated:YES];
    
    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc] init];
    cancelItem.title = @"取消";
    cancelItem.tintColor = [UIColor whiteColor];
    cancelItem.action = @selector(cancelComment:);
    cancelItem.target = self;
    
    UIBarButtonItem *commentItem = [[UIBarButtonItem alloc] init];
    commentItem.title = @"发送";
    commentItem.tintColor = [UIColor whiteColor];
    commentItem.action = @selector(comment:);
    commentItem.target = self;
    
    navitem.leftBarButtonItem = cancelItem;
    navitem.rightBarButtonItem = commentItem;
    
    commentTextView.placeholder = @"请输入留言内容";
    commentTextView.layer.borderColor = [UIColor colorWithWhite:237.0 /255.0 alpha:1.0].CGColor;
    commentTextView.layer.borderWidth = 1.0;
    commentTextView.layer.cornerRadius = 5.0;
    commentTextView.layer.masksToBounds = YES;
}

- (void)cancelComment:(UIBarButtonItem *)item
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)comment:(UIBarButtonItem *)item
{
    NSString *commentText = commentTextView.text;
    if ([commentText isEqualToString:@""] || commentText == nil) {
        [self showHint:@"请输入评论内容"];
        return;
    }
    User *userInfo = [HeSysbsModel getSysModel].user;
    [self dismissViewControllerAnimated:YES completion:^{
        [self.commentDelegate commentWithText:commentText user:userInfo];
    }];
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView isFirstResponder]) {
        [textView resignFirstResponder];
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@""] && range.length > 0) {
        //删除字符肯定是安全的
        return YES;
    }
    else {
        if (textView.text.length - range.length + text.length > limitNumber) {
            
            return NO;
        }
        else {
            return YES;
        }
    }
}

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger currentLength = textView.text.length;
    inputTextLengthLabel.text = [NSString stringWithFormat:@"%ld/%d",currentLength,limitNumber];
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
