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
#import "ScanPictureView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"

#define MAXUPLOADIMAGE 9
#define MAX_column  4
#define MAX_row 3
#define IMAGEWIDTH 70

#define ALERTTAG 400

@interface HeDistributeRecommendVC ()<UITextViewDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,TZImagePickerControllerDelegate>
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)IBOutlet UIButton *distributeButton;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)NSMutableArray *pictureArray;
@property(strong,nonatomic)SAMTextView *recommendTextView;
@property(strong,nonatomic)UIButton *addPictureButton;
@property(strong,nonatomic)UIButton *addVideoButton;
@property(strong,nonatomic)UITextField *redPocketTextField;
@property(strong,nonatomic)UITextField *redPocketNumField;

@property(strong,nonatomic)NSMutableArray *selectedAssets;
@property(strong,nonatomic)NSMutableArray *selectedPhotos;

@property(strong,nonatomic)UIView *distributeImageBG;
@property(strong,nonatomic)UIView *dismissView;
@property(strong,nonatomic)NSMutableArray *takePhotoArray;

@end

@implementation HeDistributeRecommendVC
@synthesize tableview;
@synthesize distributeButton;
@synthesize dataSource;
@synthesize pictureArray;
@synthesize recommendTextView;
@synthesize addPictureButton;
@synthesize addVideoButton;
@synthesize redPocketTextField;
@synthesize redPocketNumField;
@synthesize distributeImageBG;
@synthesize dismissView;

@synthesize takePhotoArray;

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
    dataSource = @[@[@"推荐自己"],@[@"",@"添加图片",@""],@[@"",@"添加视频",@""],@[@"",@"红包",@"红包个数"]];
    pictureArray = [[NSMutableArray alloc] initWithCapacity:0];
    
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
    
    if (!_selectedPhotos) {
        _selectedPhotos = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    }
    takePhotoArray = [[NSMutableArray alloc] initWithCapacity:0];
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
//    tableview.tableHeaderView = headerview;
//    [distributeButton dangerStyle];
    distributeButton.layer.borderColor = [UIColor clearColor].CGColor;
    [distributeButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:distributeButton.frame.size] forState:UIControlStateNormal];
    
    addPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, IMAGEWIDTH, IMAGEWIDTH)];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"icon_add_pho"] forState:UIControlStateNormal];
    addPictureButton.tag = 100;
    [addPictureButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    addVideoButton = [[UIButton alloc] init];
    [addVideoButton setBackgroundImage:[UIImage imageNamed:@"icon_add_pho"] forState:UIControlStateNormal];
    addVideoButton.tag = 200;
    [addVideoButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    redPocketTextField = [[UITextField alloc] init];
    redPocketTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    redPocketTextField.font = [UIFont systemFontOfSize:16.0];
    redPocketTextField.textColor = APPDEFAULTORANGE;
    redPocketTextField.placeholder = @"0.00";
    redPocketTextField.textAlignment = NSTextAlignmentRight;
    redPocketTextField.delegate = self;
    
    redPocketNumField = [[UITextField alloc] init];
    redPocketTextField.keyboardType = UIKeyboardTypeNumberPad;
    redPocketNumField.font = [UIFont systemFontOfSize:16.0];
    redPocketNumField.textColor = APPDEFAULTORANGE;
    redPocketNumField.placeholder = @"输入红包个数";
    redPocketNumField.textAlignment = NSTextAlignmentRight;
    redPocketNumField.delegate = self;
    
    recommendTextView.textColor = APPDEFAULTORANGE;
    
    CGFloat distributeX = 5;
    CGFloat distributeY = 5;
    CGFloat distributeW = SCREENWIDTH - 2 * distributeX;
    CGFloat distributeH = IMAGEWIDTH;
    
    int row = [Tool getRowNumWithTotalNum:[pictureArray count]];
    int column = [Tool getColumnNumWithTotalNum:[pictureArray count]];
    distributeImageBG = [[UIView alloc] initWithFrame:CGRectMake(distributeX, distributeY, distributeW, distributeH)];
    [distributeImageBG setBackgroundColor:[UIColor whiteColor]];
    [distributeImageBG addSubview:addPictureButton];
    distributeImageBG.userInteractionEnabled = YES;
    [self updateImageBG];
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
}

- (void)distributeRecommend:(UIBarButtonItem *)item
{
    
}

- (IBAction)distributeButtonClick:(id)sender
{
    NSString *content = recommendTextView.text;
    if (content == nil || [content isEqualToString:@""]) {
        [self showHint:@"亲，推荐一下自己吧！"];
        return;
    }
    if ([pictureArray count] == 0) {
        [self showHint:@"请添加图片"];
        return;
    }
    NSString *money = redPocketTextField.text;
    if ([money floatValue] < 0.01) {
        [self showHint:@"请输入红包数目"];
        return;
    }
    NSString *redPocketNum = redPocketNumField.text;
    if ([redPocketNum integerValue] <= 0) {
        [self showHint:@"请输入红包个数"];
        return;
    }
    [self inputPayPassword];
}

- (void)dismissViewGes:(UITapGestureRecognizer *)ges
{
    
    UIView *mydismissView = ges.view;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    [alertview removeFromSuperview];
}

- (void)inputPayPassword
{
    [self.view addSubview:dismissView];
    dismissView.hidden = NO;
    
    CGFloat viewX = 10;
    CGFloat viewY = 100;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = 150;
    UIView *shareAlert = [[UIView alloc] init];
    shareAlert.frame = CGRectMake(viewX, viewY, viewW, viewH);
    shareAlert.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBarIOS7"]];
    shareAlert.layer.cornerRadius = 5.0;
    shareAlert.layer.borderWidth = 0;
    shareAlert.layer.masksToBounds = YES;
    shareAlert.tag = ALERTTAG;
    shareAlert.layer.borderColor = [UIColor clearColor].CGColor;
    shareAlert.userInteractionEnabled = YES;
    
    CGFloat labelH = 40;
    CGFloat labelY = 0;
    
    UIFont *shareFont = [UIFont systemFontOfSize:15.0];
    
    UILabel *messageTitleLabel = [[UILabel alloc] init];
    messageTitleLabel.font = shareFont;
    messageTitleLabel.textColor = [UIColor whiteColor];
    messageTitleLabel.textAlignment = NSTextAlignmentCenter;
    messageTitleLabel.backgroundColor = APPDEFAULTORANGE;
    messageTitleLabel.text = @"支付密码";
    messageTitleLabel.frame = CGRectMake(0, 0, viewW, labelH);
    [shareAlert addSubview:messageTitleLabel];
    
    UIImageView *logoImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_logoImage"]];
    logoImage.frame = CGRectMake(20, 5, 30, 30);
    [shareAlert addSubview:logoImage];
    
    //    labelY = labelY + labelH + 10;
    //    UILabel *shareTitleLabel = [[UILabel alloc] init];
    //    shareTitleLabel.font = shareFont;
    //    shareTitleLabel.textColor = [UIColor whiteColor];
    //    shareTitleLabel.textAlignment = NSTextAlignmentLeft;
    //    shareTitleLabel.backgroundColor = [UIColor clearColor];
    //    shareTitleLabel.text = @"网评员";
    //    shareTitleLabel.frame = CGRectMake(10, labelY, viewW - 20, labelH);
    //    [shareAlert addSubview:shareTitleLabel];
    
    
    
    labelY = labelY + labelH + 10;
    UITextField *textview = [[UITextField alloc] init];
    textview.tag = 10;
    textview.secureTextEntry = YES;
    textview.backgroundColor = [UIColor whiteColor];
    textview.placeholder = @"请输入6位数的密码";
    textview.font = shareFont;
    textview.delegate = self;
    textview.frame = CGRectMake(10, labelY, shareAlert.frame.size.width - 20, labelH);
    textview.layer.borderWidth = 1.0;
    textview.layer.cornerRadius = 2.0;
    textview.layer.masksToBounds = YES;
    textview.layer.borderColor = [UIColor colorWithWhite:0xcc / 255.0 alpha:1.0].CGColor;
    [shareAlert addSubview:textview];
    
    CGFloat buttonDis = 10;
    CGFloat buttonW = (viewW - 3 * buttonDis) / 2.0;
    CGFloat buttonH = 40;
    CGFloat buttonY = labelY = labelY + labelH + 10;
    CGFloat buttonX = 10;
    
    UIButton *shareButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
    [shareButton setTitle:@"确定" forState:UIControlStateNormal];
    [shareButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    shareButton.tag = 1;
    [shareButton.titleLabel setFont:shareFont];
    [shareButton setBackgroundColor:APPDEFAULTORANGE];
    [shareButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:shareButton.frame.size] forState:UIControlStateHighlighted];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareAlert addSubview:shareButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX + buttonDis + buttonW, buttonY, buttonW, buttonH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 0;
    [cancelButton.titleLabel setFont:shareFont];
    [cancelButton setBackgroundColor:APPDEFAULTORANGE];
    [cancelButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:shareButton.frame.size] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareAlert addSubview:cancelButton];
    
    CAKeyframeAnimation *popAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    popAnimation.duration = 0.4;
    popAnimation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.01f, 0.01f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.1f, 1.1f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9f, 0.9f, 1.0f)],
                            [NSValue valueWithCATransform3D:CATransform3DIdentity]];
    popAnimation.keyTimes = @[@0.2f, @0.5f, @0.75f, @1.0f];
    popAnimation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut],
                                     [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [shareAlert.layer addAnimation:popAnimation forKey:nil];
    [self.view addSubview:shareAlert];
}

- (void)alertbuttonClick:(UIButton *)button
{
    UIView *mydismissView = dismissView;
    mydismissView.hidden = YES;
    
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    
    UIView *subview = [alertview viewWithTag:10];
    if (button.tag == 0) {
        [alertview removeFromSuperview];
        return;
    }
    UITextField *textview = nil;
    if ([subview isMemberOfClass:[UITextField class]]) {
        textview = (UITextField *)subview;
    }
    NSString *password = textview.text;
    [alertview removeFromSuperview];
    if (password == nil || [password isEqualToString:@""]) {
        
        [self showHint:@"请输入6位数的密码"];
        return;
    }
    [self verifyPassword:password];
}

//验证密码
- (void)verifyPassword:(NSString *)password
{
    [self showHudInView:self.tableview hint:@"验证密码中..."];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/money/verifyPswd.action",BASEURL];
    NSDictionary *param = @{@"userId":userId,@"pswd":password};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            //验证密码成功，发布
            [self showHudInView:self.tableview hint:@"发布中..."];
            [self performSelector:@selector(creatRecommend) withObject:nil afterDelay:0.2];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
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

- (void)creatRecommend
{
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *content = recommendTextView.text;
    NSNumber *moneyNum = [NSNumber numberWithInteger:[redPocketNumField.text integerValue]];
    NSNumber *moneySize = [NSNumber numberWithFloat:[redPocketTextField.text floatValue]];
    NSString *video = @"";
    NSMutableString *cover = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < self.pictureArray.count; index++) {
        AsynImageView *imageview = self.pictureArray[index];
        
        UIImage *imageData = imageview.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        if (index == 0) {
            [cover appendString:base64String];
        }
        else {
            [cover appendFormat:@"%@,%@",cover,base64String];
        }
    }
    
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/recommend/releaseRecommen.action",BASEURL];
    NSDictionary *params = @{@"userId":userId,@"content":content,@"cover":cover,@"moneyNum":moneyNum,@"moneySize":moneySize,@"video":video};
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:params success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = @"发布成功!";
            }
            [self showHint:data];
            [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateRecommend" object:self];
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
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

- (void)backLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}
//删除所选图片的代理方法
-(void)deleteImageAtIndex:(int)index
{
    [pictureArray removeObjectAtIndex:index];
    [self updateImageBG];
}

- (void)addButtonClick:(UIButton *)sender
{
    if ([recommendTextView isFirstResponder]) {
        [recommendTextView resignFirstResponder];
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 1;
    [sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:YES];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 1) {
        switch (buttonIndex) {
            case 1:
            {
                if (ISIOS7) {
                    NSString *mediaType = AVMediaTypeVideo;
                    AVAuthorizationStatus  authorizationStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
                    if (authorizationStatus == AVAuthorizationStatusRestricted|| authorizationStatus == AVAuthorizationStatusDenied) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }else{
                        [self pickerCamer];
                    }
                }
                else{
                    [self pickerCamer];
                }
                
                
                break;
            }
            case 0:
            {
                if (ISIOS7) {
                    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
                    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
                        //无权限
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    else{
                        [self mutiplepickPhotoSelect];
                    }
                }
                else{
                    [self mutiplepickPhotoSelect];
                }
                break;
            }
            case 2:
            {
                break;
            }
            default:
                break;
        }
    }
}

- (void)updateImageBG
{
    for (UIView *subview in distributeImageBG.subviews) {
        [subview removeFromSuperview];
    }
    CGFloat buttonH = IMAGEWIDTH;
    CGFloat buttonW = IMAGEWIDTH;
    
    CGFloat buttonHDis = (SCREENWIDTH - 20 - MAX_column * buttonW) / (MAX_column - 1);
    CGFloat buttonVDis = 10;
    
    int row = [Tool getRowNumWithTotalNum:[pictureArray count]];
    int column = [Tool getColumnNumWithTotalNum:[pictureArray count]];
    for (int i = 0; i < row; i++) {
        if ((i + 1) * MAX_column <= [pictureArray count]) {
            column = MAX_column;
        }
        else{
            column = [pictureArray count] % MAX_column;
        }
        for (int j = 0; j < column; j++) {
            
            CGFloat buttonX = (buttonW + buttonHDis) * j;
            CGFloat buttonY = (buttonH + buttonVDis) * i;
            
            NSInteger picIndex = i * MAX_column + j;
            AsynImageView *asynImage = [pictureArray objectAtIndex:picIndex];
            asynImage.tag = picIndex;
            asynImage.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            asynImage.layer.borderColor = [UIColor clearColor].CGColor;
            asynImage.layer.borderWidth = 0;
            asynImage.layer.masksToBounds = YES;
            asynImage.contentMode = UIViewContentModeScaleAspectFill;
            asynImage.userInteractionEnabled = YES;
            [distributeImageBG addSubview:asynImage];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
            tapGes.numberOfTapsRequired = 1;
            tapGes.numberOfTouchesRequired = 1;
            [asynImage addGestureRecognizer:tapGes];
        }
    }
    
    
    if ([pictureArray count] < MAXUPLOADIMAGE) {
        
        NSInteger last_i = -1;
        NSInteger last_j = -1;
        row = [Tool getRowNumWithTotalNum:[pictureArray count] + 1];
        for (int i = 0; i < row; i++) {
            if ((i + 1) * MAX_column <= [pictureArray count] + 1) {
                column = MAX_column;
            }
            else{
                column = ([pictureArray count] + 1) % MAX_column;
            }
            last_i = i;
            for (int j = 0; j < column; j++) {
                last_j = j;
            }
        }
        if (last_i == -1 || last_j == -1) {
            addPictureButton.hidden = YES;
        }
        else{
            addPictureButton.hidden = NO;
        }
        
        CGFloat buttonX = (buttonW + buttonHDis) * last_j;
        CGFloat buttonY = (buttonH + buttonVDis) * last_i;
        CGFloat buttonW = addPictureButton.frame.size.width;
        CGFloat buttonH = addPictureButton.frame.size.height;
        
        addPictureButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        CGFloat distributeX = distributeImageBG.frame.origin.x;
        CGFloat distributeY = distributeImageBG.frame.origin.y;
        CGFloat distributeW = distributeImageBG.frame.size.width;
        CGFloat distributeH = addPictureButton.frame.origin.y + addPictureButton.frame.size.height;
        
        distributeImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
    }
    else{
        
        CGFloat distributeX = distributeImageBG.frame.origin.x;
        CGFloat distributeY = distributeImageBG.frame.origin.y;
        CGFloat distributeW = distributeImageBG.frame.size.width;
        CGFloat distributeH = (buttonH + buttonVDis) * (MAX_row - 1) + buttonH;
        
        distributeImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
        addPictureButton.hidden = YES;
    }
    [distributeImageBG addSubview:addPictureButton];
    
    [tableview reloadData];
    
}

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
    NSInteger selectIndex = tap.view.tag + 1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AsynImageView *asyImage in pictureArray) {
        if (asyImage.highlightedImage == nil) {
            [array addObject:asyImage];
        }
    }
    
    ScanPictureView *scanPictureView = [[ScanPictureView alloc] initWithArray:array selectButtonIndex:selectIndex];
    scanPictureView.deleteDelegate = self;
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
    [backButton setTintColor:[UIColor colorWithRed:65.0f/255.0f green:164.0f/255.0f blue:220.0f/255.0f alpha:1.0f]];
    scanPictureView.navigationItem.backBarButtonItem = backButton;
    scanPictureView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scanPictureView animated:YES];
}

- (void)handleSelectPhoto
{
    for (AsynImageView *imageview in pictureArray) {
        if (imageview.imageTag != -1) {
            [pictureArray removeObject:imageview];
        }
    }
    
    for (UIImage *image in _selectedPhotos) {
        AsynImageView *asyncImage = [[AsynImageView alloc] init];
        [asyncImage setImage:image];
        asyncImage.bigImageURL = nil;
        [pictureArray addObject:asyncImage];
        
    }
    [self updateImageBG];
}

- (void)mutiplepickPhotoSelect{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    imagePickerVc.selectedAssets = _selectedAssets; // optional, 可选的
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        
    }];
    
    // Set the appearance
    // 在这里设置imagePickerVc的外观
    // imagePickerVc.navigationBar.barTintColor = [UIColor greenColor];
    // imagePickerVc.oKButtonTitleColorDisabled = [UIColor lightGrayColor];
    // imagePickerVc.oKButtonTitleColorNormal = [UIColor greenColor];
    
    // Set allow picking video & photo & originalPhoto or not
    // 设置是否可以选择视频/图片/原图
    // imagePickerVc.allowPickingVideo = NO;
    // imagePickerVc.allowPickingImage = NO;
    // imagePickerVc.allowPickingOriginalPhoto = NO;
    
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

#pragma mark TZImagePickerControllerDelegate



/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
    _selectedPhotos = [NSMutableArray arrayWithArray:photos];
    _selectedAssets = [NSMutableArray arrayWithArray:assets];
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
}

/// User finish picking video,
/// 用户选择好了视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    [_selectedPhotos addObjectsFromArray:@[coverImage]];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self handleSelectPhoto];
    }];
    
    /*
     // open this code to send video / 打开这段代码发送视频
     [[TZImageManager manager] getVideoOutputPathWithAsset:asset completion:^(NSString *outputPath) {
     NSLog(@"视频导出到本地完成,沙盒路径为:%@",outputPath);
     // Export completed, send video here, send by outputPath or NSData
     // 导出完成，在这里写上传代码，通过路径或者通过NSData上传
     
     }];
     */
    
}

#pragma mark -
#pragma mark ImagePicker method
//从相册中打开照片选择画面(图片库)：UIImagePickerControllerSourceTypePhotoLibrary
//启动摄像头打开照片摄影画面(照相机)：UIImagePickerControllerSourceTypeCamera

//按下相机触发事件
-(void)pickerCamer
{
    //照相机类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断属性值是否可用
    if([UIImagePickerController isSourceTypeAvailable:sourceType]){
        //UIImagePickerController是UINavigationController的子类
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
        imagePicker.delegate = self;
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
        //设置可以编辑
        //        imagePicker.allowsEditing = YES;
        //设置类型为照相机
        imagePicker.sourceType = sourceType;
        //进入照相机画面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

//当按下相册按钮时触发事件
-(void)pickerPhotoLibrary
{
    //图片库类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *photoAlbumPicker = [[UIImagePickerController alloc] init];
    photoAlbumPicker.delegate = self;
    photoAlbumPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置可以编辑
    //    photoAlbumPicker.allowsEditing = YES;
    //设置类型
    photoAlbumPicker.sourceType = sourceType;
    //进入图片库画面
    [self presentViewController:photoAlbumPicker animated:YES completion:nil];
}


#pragma mark -
#pragma mark imagePickerController method
//当拍完照或者选取好照片之后所要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    CGSize sizeImage = image.size;
    float a = [self getSize:sizeImage];
    if (a>0) {
        CGSize size = CGSizeMake(sizeImage.width/a, sizeImage.height/a);
        image = [self scaleToSize:image size:size];
    }
    
    //    [self initButtonWithImage:image];
    
    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    
    UIImageJPEGRepresentation(image, 0.6);
    [asyncImage setImage:image];
    
    asyncImage.bigImageURL = nil;
    asyncImage.imageTag = -1; //表明是调用系统相机、相册的
    [pictureArray addObject:asyncImage];
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateImageBG];
    }];
    
}


//相应取消动作
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(float)getSize:(CGSize)size
{
    float a = size.width / 480.0;
    if (a > 1) {
        return a;
    }
    else
        return -1;
}

- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

-(void)initButtonWithImage:(UIImage *)image
{
    
    CGSize sizeImage = image.size;
    CGFloat width = sizeImage.width;
    CGFloat hight = sizeImage.height;
    CGFloat standarW = width;
    CGRect frame = CGRectMake(0, hight - width, standarW, standarW);
    
    if (width > hight) {
        standarW = hight;
        
        frame = CGRectMake(0, 0, standarW, standarW);
    }
    //截取图片
    UIImage *jiequImage = [self imageFromImage:image inRect:frame];
    //    CGSize jiequSize = jiequImage.size;
    
    
    addPictureButton.tag = 1;
    [addPictureButton setImage:jiequImage forState:UIControlStateNormal];
}

- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
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
    if (section != 0 && row == 0) {
        cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    }
    switch (section) {
        case 0:
        {
            [cell addSubview:recommendTextView];
            break;
        }
        case 1:
        {
            switch (row) {
                case 2:
                {
                    [cell addSubview:distributeImageBG];
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
                case 2:
                {
                    CGFloat buttonX = 10;
                    CGFloat buttonY = 10;
                    CGFloat buttonH = IMAGEWIDTH;
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
                case 1:
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
                case 2:
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
    if (row == 0 && section != 0) {
        return 10;
    }
    
    switch (section) {
        case 0:
            return 150;
            break;
        case 1:{
            switch (row) {
                case 2:
                {
                    return 2 * distributeImageBG.frame.origin.y + distributeImageBG.frame.size.height;
                    break;
                }
                default:
                    break;
            }
        }
        case 2:{
            switch (row) {
                case 2:
                {
                    return 2 * addVideoButton.frame.origin.y + addVideoButton.frame.size.height;
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

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return 0.1;
//    }
//    return 10;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 0.1;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    if (section == 0) {
//        return nil;
//    }
//    
//    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 10)];
//    headerview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
//    return headerview;
//}

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
