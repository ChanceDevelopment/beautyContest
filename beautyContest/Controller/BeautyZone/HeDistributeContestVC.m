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
#import "IQActionSheetPickerView.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "HeUserRecommendCell.h"
#import "HeUserContestCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "ScanPictureView.h"
#import "HeModifyPayPasswordVC.h"
#import "HcdDateTimePickerView.h"
#import "HeUserLocatiVC.h"
#import "LocationViewController.h"
#import "HeContestDetailVC.h"
#import "UWDatePickerView.h"
#import "ScanPictureView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "TZImagePickerController.h"
#import "UIView+Layout.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "TZImageManager.h"

#define ALERTTAG 200
#define MinLocationSucceedNum 1   //要求最少成功定位的次数
#define TextLineHeight 1.2f

#define MAXUPLOADIMAGE 6
#define MAX_column  4
#define MAX_row 3
#define IMAGEWIDTH 70

@interface HeDistributeContestVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,IQActionSheetPickerView,GetUserLocationInfoDelegate,UWDatePickerViewDelegate,TZImagePickerControllerDelegate>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geoSearch;
    BOOL coverImageHaveTake; //封面图片是否已经获取
    NSMutableDictionary *userLocationDict;
    
    BOOL currentSelectBanner;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSDictionary *contestDetailDict;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)NSArray *titleDataSource;
@property(strong,nonatomic)UITextField *titleField;
@property(strong,nonatomic)UITextField *addressField;
@property(strong,nonatomic)UITextField *rewardField;
@property(strong,nonatomic)NSMutableDictionary *switchDict;
@property(strong,nonatomic)NSString *tmpDateString;
@property(strong,nonatomic)UIView *bgview;
@property(strong,nonatomic)UIImageView *coverImage;
@property (nonatomic,assign)NSInteger locationSucceedNum; //定位成功的次数
@property(strong,nonatomic)UIView *dismissView;

@property(strong,nonatomic)NSMutableArray *bannerImageDataSource;
@property(strong,nonatomic)UIView *bannerImageBG;
@property(strong,nonatomic)UIButton *addPictureButton;

@property(strong,nonatomic)NSMutableArray *selectedAssets;
@property(strong,nonatomic)NSMutableArray *selectedPhotos;
@property(strong,nonatomic)NSMutableArray *takePhotoArray;

@property(strong,nonatomic)NSDictionary *userBalance;

@end

@implementation HeDistributeContestVC
@synthesize contestDetailDict;
@synthesize tableview;
@synthesize sectionHeaderView;
@synthesize iconDataSource;
@synthesize titleDataSource;
@synthesize titleField;
@synthesize addressField;
@synthesize rewardField;
@synthesize switchDict;
@synthesize bgview;
@synthesize coverImage;
@synthesize locationSucceedNum;
@synthesize dismissView;
@synthesize bannerImageDataSource;
@synthesize bannerImageBG;
@synthesize addPictureButton;
@synthesize zonePassword;
@synthesize takePhotoArray;
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
    [self getBalance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    _locService.delegate = self;
    [self showEULA];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    _locService.delegate = nil;
}

- (void)showEULA
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"ContestEULA"] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"ContestEULA"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请发布健康向上的内容，禁止发布色情内容，否则我们会追究法律责任。您发布的内容我们平台会先审核，只有通过审核的内容才会在App里显示出来。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)initializaiton
{
    [super initializaiton];
    iconDataSource = @[@[@"",@""],@[@"",@"",@""],@[@"",@"icon_time",@"icon_location",@"icon_sex_boy",@"icon_sex_girl",@"icon_pay_password",@""]];
    titleDataSource = @[@[@"",@""],@[@"",@"宣传图片",@""],@[@"",@"截止时间",@"定位",@"男生参加",@"女生参加",@"我要验证",@""]];
    switchDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [switchDict setObject:@YES forKey:@"2"];
    [switchDict setObject:@YES forKey:@"3"];
    [switchDict setObject:@NO forKey:@"4"];
    userLocationDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    
    coverImageHaveTake = NO;
    currentSelectBanner = NO;
    
    if (!_selectedPhotos) {
        _selectedPhotos = [[NSMutableArray alloc] initWithCapacity:0];
    }
    if (!_selectedAssets) {
        _selectedAssets = [[NSMutableArray alloc] initWithCapacity:0];
    }
    takePhotoArray = [[NSMutableArray alloc] initWithCapacity:0];
    
}

- (void)getBalance
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/money/getBalance.action",BASEURL];
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userId) {
        userId = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userId};
    //    [self showHudInView:self.view hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            self.userBalance = respondDict[@"json"];
            
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

- (void)initView
{
    [super initView];
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] init];
    distributeItem.title = @"发布";
    distributeItem.target = self;
    distributeItem.action = @selector(distributeContest:);
//    self.navigationItem.rightBarButtonItem = distributeItem;
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    [Tool setExtraCellLineHidden:tableview];
    
    
    CGFloat headerHeight = BESTSCALE * SCREENWIDTH;
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, headerHeight)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
//    tableview.tableHeaderView = sectionHeaderView;
    
    coverImage = [[UIImageView alloc] init];
    
    coverImage.frame = CGRectMake(0, 0, SCREENWIDTH, headerHeight);
    coverImage.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    coverImage.userInteractionEnabled = YES;
    coverImage.layer.masksToBounds = YES;
//    coverImage.contentMode = UIViewContentModeScaleAspectFill;
    [sectionHeaderView addSubview:coverImage];
    
    addPictureButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, IMAGEWIDTH, IMAGEWIDTH)];
    [addPictureButton setBackgroundImage:[UIImage imageNamed:@"icon_add_pho"] forState:UIControlStateNormal];
    addPictureButton.tag = 100;
    [addPictureButton addTarget:self action:@selector(addButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat tipX = 10;
    CGFloat tipW = SCREENWIDTH - 2 * tipX;
    CGFloat tipH = 40;
    CGFloat tipY = 0;
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(tipX, tipY, tipW, tipH)];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.font = [UIFont systemFontOfSize:12.0];
    tipLabel.numberOfLines = 2;
    tipLabel.text = @"请上传像素为512 * 297 的图片，发布后主题内容不能修改";
    tipLabel.textColor = [UIColor grayColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    tipLabel.tag = 8888;
    tipLabel.center = coverImage.center;
    [coverImage addSubview:tipLabel];
    
    UIImageView *editIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_edit"]];
    CGFloat imageW = 20;
    CGFloat imageH = imageW;
    CGFloat imageY = 20;
    CGFloat imageX = SCREENWIDTH - imageW - 20;
    editIcon.frame = CGRectMake(imageX, imageY, imageW, imageH);
    [coverImage addSubview:editIcon];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [coverImage addGestureRecognizer:tap];
    coverImage.userInteractionEnabled = YES;
    
    titleField = [[UITextField alloc] init];
    titleField.layer.borderColor = [UIColor clearColor].CGColor;
    titleField.delegate = self;
    titleField.placeholder = @"例如：浙大15届选美赛-寻找最美同学";
    titleField.font = [UIFont systemFontOfSize:16.0];
    titleField.textColor = APPDEFAULTORANGE;
    
    addressField = [[UITextField alloc] init];
    addressField.layer.borderColor = [UIColor clearColor].CGColor;
    addressField.delegate = self;
    addressField.placeholder = @"请输入赛区地址";
    addressField.font = [UIFont systemFontOfSize:16.0];
    addressField.textColor = APPDEFAULTORANGE;
    
    rewardField = [[UITextField alloc] init];
    rewardField.layer.borderColor = [UIColor clearColor].CGColor;
    rewardField.delegate = self;
    rewardField.placeholder = @"0.00";
    rewardField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    rewardField.font = [UIFont systemFontOfSize:16.0];
    rewardField.textColor = APPDEFAULTORANGE;
    
    bgview = [[UIView alloc] init];
    bgview.frame = self.view.frame;
    bgview.backgroundColor = [UIColor colorWithWhite:135.0/255.0 alpha:0.5];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc] init];
    _locService.delegate = self;
    //启动LocationService
    _locService.desiredAccuracy = kCLLocationAccuracyBest;
    _locService.distanceFilter  = 1.5f;
    [_locService startUserLocationService];
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _geoSearch.delegate = self;
    
    
    locationSucceedNum = 0;
    
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
    
    
    bannerImageDataSource = [[NSMutableArray alloc] initWithCapacity:0];
    int row = [Tool getRowNumWithTotalNum:[bannerImageDataSource count]];
    int column = [Tool getColumnNumWithTotalNum:[bannerImageDataSource count]];
    CGFloat bannerX = 5;
    CGFloat bannerY = 5;
    CGFloat bannerW = SCREENWIDTH - 2 * bannerX;
    CGFloat bannerH = IMAGEWIDTH;
    bannerImageBG = [[UIView alloc] initWithFrame:CGRectMake(bannerX, bannerY, bannerW, bannerH)];
    [bannerImageBG setBackgroundColor:[UIColor whiteColor]];
    [bannerImageBG addSubview:addPictureButton];
    bannerImageBG.userInteractionEnabled = YES;
    [self updateImageBG];
}

- (void)updateImageBG
{
    for (UIView *subview in bannerImageBG.subviews) {
        [subview removeFromSuperview];
    }
    CGFloat buttonH = IMAGEWIDTH;
    CGFloat buttonW = IMAGEWIDTH;
    
    CGFloat buttonHDis = (SCREENWIDTH - 20 - MAX_column * buttonW) / (MAX_column - 1);
    CGFloat buttonVDis = 10;
    
    int row = [Tool getRowNumWithTotalNum:[bannerImageDataSource count]];
    int column = [Tool getColumnNumWithTotalNum:[bannerImageDataSource count]];
    
    CGFloat distributeX = bannerImageBG.frame.origin.x;
    CGFloat distributeY = bannerImageBG.frame.origin.y;
    CGFloat distributeW = bannerImageBG.frame.size.width;
    CGFloat distributeH = 0;
    
    for (int i = 0; i < row; i++) {
        if ((i + 1) * MAX_column <= [bannerImageDataSource count]) {
            column = MAX_column;
        }
        else{
            column = [bannerImageDataSource count] % MAX_column;
        }
        for (int j = 0; j < column; j++) {
            
            CGFloat buttonX = (buttonW + buttonHDis) * j;
            CGFloat buttonY = (buttonH + buttonVDis) * i;
            
            NSInteger picIndex = i * MAX_column + j;
            AsynImageView *asynImage = [bannerImageDataSource objectAtIndex:picIndex];
            asynImage.tag = picIndex;
            asynImage.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            asynImage.layer.borderColor = [UIColor clearColor].CGColor;
            asynImage.layer.borderWidth = 0;
            asynImage.layer.masksToBounds = YES;
            asynImage.contentMode = UIViewContentModeScaleAspectFill;
            asynImage.userInteractionEnabled = YES;
            [bannerImageBG addSubview:asynImage];
            
            UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scanImageTap:)];
            tapGes.numberOfTapsRequired = 1;
            tapGes.numberOfTouchesRequired = 1;
            [asynImage addGestureRecognizer:tapGes];
        }
    }
    if ([bannerImageDataSource count] < MAXUPLOADIMAGE) {
        
        NSInteger last_i = -1;
        NSInteger last_j = -1;
        row = [Tool getRowNumWithTotalNum:[bannerImageDataSource count] + 1];
        for (int i = 0; i < row; i++) {
            if ((i + 1) * MAX_column <= [bannerImageDataSource count] + 1) {
                column = MAX_column;
            }
            else{
                column = ([bannerImageDataSource count] + 1) % MAX_column;
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
        
        CGFloat distributeX = bannerImageBG.frame.origin.x;
        CGFloat distributeY = bannerImageBG.frame.origin.y;
        CGFloat distributeW = bannerImageBG.frame.size.width;
        CGFloat distributeH = addPictureButton.frame.origin.y + addPictureButton.frame.size.height;
        
        bannerImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
    }
    else{
        
        CGFloat distributeX = bannerImageBG.frame.origin.x;
        CGFloat distributeY = bannerImageBG.frame.origin.y;
        CGFloat distributeW = bannerImageBG.frame.size.width;
        CGFloat distributeH = (buttonH + buttonVDis) * (MAX_row - 1) + buttonH;
        
        bannerImageBG.frame = CGRectMake(distributeX, distributeY, distributeW, distributeH);
        
        addPictureButton.hidden = YES;
    }
    [bannerImageBG addSubview:addPictureButton];
    
    [tableview reloadData];
}

- (void)scanImageTap:(UITapGestureRecognizer *)tap
{
    NSInteger selectIndex = tap.view.tag + 1;
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (AsynImageView *asyImage in bannerImageDataSource) {
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

//删除所选图片的代理方法
-(void)deleteImageAtIndex:(int)index
{
    [bannerImageDataSource removeObjectAtIndex:index];
    [self updateImageBG];
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

- (void)addButtonClick:(UIButton *)sender
{
    if ([bannerImageDataSource count] > MAXUPLOADIMAGE) {
        [self showHint:[NSString stringWithFormat:@"上传图片最多不能超过%d张",MAXUPLOADIMAGE]];
        return;
    }
    currentSelectBanner = YES;
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 1;
    [sheet showInView:bannerImageBG];
    return;
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"选择宣传图片" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //取消
        }];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickerCamer];
        }];
        
        UIAlertAction *libAction = [UIAlertAction actionWithTitle:@"从手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickerPhotoLibrary];
        }];
        
        // Add the actions.
        [alertController addAction:cameraAction];
        [alertController addAction:libAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
//    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"选择宣传图片" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
//    [sheet showInView:bannerImageBG];
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
    else if (actionSheet.tag == 2){
        switch (buttonIndex) {
            case 0:
            {
                [self pickerPhotoLibrary];
                break;
            }
            case 1:{
                //查看大图
                [self pickerCamer];
                break;
            }
            case 2:
                //取消
                break;
            default:
                break;
        }
    }
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
    [shareButton setBackgroundImage:[self buttonImageFromColor:APPDEFAULTORANGE size:shareButton.frame.size] forState:UIControlStateHighlighted];
    [shareButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [shareAlert addSubview:shareButton];
    
    UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(buttonX + buttonDis + buttonW, buttonY, buttonW, buttonH)];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(alertbuttonClick:) forControlEvents:UIControlEventTouchUpInside];
    cancelButton.tag = 0;
    [cancelButton.titleLabel setFont:shareFont];
    [cancelButton setBackgroundColor:APPDEFAULTORANGE];
    [cancelButton setBackgroundImage:[self buttonImageFromColor:APPDEFAULTORANGE size:shareButton.frame.size] forState:UIControlStateHighlighted];
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
            [self performSelector:@selector(creatContestZone) withObject:nil afterDelay:0.3];
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

- (void)creatContestZone
{
    UIImage *imageData = coverImage.image;
    NSData *data = UIImageJPEGRepresentation(imageData,0.2);
    NSData *base64Data = [GTMBase64 encodeData:data];
    NSString *zoneCover = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
    
    NSMutableString *cover = [[NSMutableString alloc] initWithString:zoneCover];
    for (NSInteger index = 0; index < self.bannerImageDataSource.count; index++) {
        AsynImageView *imageview = self.bannerImageDataSource[index];
        
        UIImage *imageData = imageview.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        [cover appendFormat:@"%@,%@",cover,base64String];
//        if (index == 0) {
//            [cover appendString:base64String];
//        }
//        else {
//            [cover appendFormat:@"%@,%@",cover,base64String];
//        }
    }
    
    
    long long timeSp = [Tool convertStringToTimesp:self.tmpDateString dateFormate:@"yyyy-MM-dd HH:mm"];
    NSString *zoneDeathline = [NSString stringWithFormat:@"%lld",timeSp];
    if (zoneDeathline.length < 13) {
        NSInteger length = 13 - zoneDeathline.length;
        for (NSInteger index = 0; index < length; index++) {
            zoneDeathline = [NSString stringWithFormat:@"%@0",zoneDeathline];
        }
    }
    NSString *zoneTitle = titleField.text;
    NSString *zoneAddress = addressField.text;
    NSString *zoneReward = rewardField.text;
    NSNumber *zoneManin = [NSNumber numberWithBool:[[switchDict objectForKey:@"2"] boolValue]];
    NSNumber *zoneWomanin = [NSNumber numberWithBool:[[switchDict objectForKey:@"3"] boolValue]];
    NSNumber *zoneState	= [NSNumber numberWithInteger:0];
    
    NSString *zoneLocationY = [userLocationDict objectForKey:@"latitude"];
    if (!zoneLocationY) {
        zoneLocationY = @"";
    }
    NSString *zoneLocationX = [userLocationDict objectForKey:@"longitude"];
    if (!zoneLocationX) {
        zoneLocationX = @"";
    }
    
    NSString *zoneUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (zoneUser == nil) {
        zoneUser = @"";
    }
    
    
//    NSString *paper = @"";
//    NSString *zonePwd = @"";
//    NSString *zoneSwith = @"";
//    NSNumber *zoneTeststate = [NSNumber numberWithBool:[[switchDict objectForKey:@"4"] boolValue]];
    
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/zone/createNewZone.action",BASEURL];
    
    NSDictionary *params = @{@"zoneTitle":zoneTitle,@"zoneCover":cover,@"zoneReward":zoneReward,@"zoneUser":zoneUser,@"zoneDeathline":zoneDeathline,@"zoneAddress":zoneAddress,@"zoneLocationX":zoneLocationX,@"zoneLocationY":zoneLocationY,@"zoneManin":zoneManin,@"zoneWomanin":zoneWomanin,@"zoneState":zoneState};
    if (zonePassword) {
        NSString *zonePwd = zonePassword;
        NSNumber *zoneTeststate = [NSNumber numberWithBool:[[switchDict objectForKey:@"4"] boolValue]];
        params = @{@"zoneTitle":zoneTitle,@"zoneCover":cover,@"zoneReward":zoneReward,@"zoneUser":zoneUser,@"zoneDeathline":zoneDeathline,@"zoneAddress":zoneAddress,@"zoneLocationX":zoneLocationX,@"zoneLocationY":zoneLocationY,@"zoneManin":zoneManin,@"zoneWomanin":zoneWomanin,@"zoneState":zoneState,@"zonePwd":zonePwd,@"zoneTeststate":zoneTeststate};
    }
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
//            [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.2];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateContestZone" object:self];
            NSString *zoneId = respondDict[@"json"];
            if ([zoneId isMemberOfClass:[NSNull class]] || zoneId == nil) {
                zoneId = @"";
            }
            HeContestDetailVC *contestDetailVC = [[HeContestDetailVC alloc] init];
            contestDetailVC.myzoneId = [[NSString alloc] initWithFormat:@"%@",zoneId];
            contestDetailVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:contestDetailVC animated:YES];
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
    if (zonePassword){
        [self.navigationController popToRootViewControllerAnimated:YES];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *) buttonImageFromColor:(UIColor *)color size:(CGSize)size{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (void)distributeContest:(UIBarButtonItem *)barItem
{
    NSLog(@"distributeContest");
}

- (IBAction)distributeButtonClick:(id)sender
{
    if (!coverImageHaveTake) {
        [self showHint:@"请选择封面图片"];
        return;
    }
    NSString *contestTitle = titleField.text;
    if (contestTitle == nil || [contestTitle isEqualToString:@""]) {
        [self showHint:@"请输入比赛主题"];
        return;
    }
    if (self.tmpDateString == nil) {
        [self showHint:@"请选择截止时间"];
        return;
    }
    NSString *address = addressField.text;
    if (address == nil || [address isEqualToString:@""]) {
        [self showHint:@"请输入赛区地址"];
        return;
    }
    NSString *reward = rewardField.text;
    if ([reward  floatValue] < 0.01) {
        [self showHint:@"请输入比赛的赏金"];
        return;
    }
    BOOL havePayPassword = [userBalance[@"userPayPwd"] boolValue];
    
    if (!havePayPassword) {
        if (ISIOS8) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"尚未设置密码，马上设置？" preferredStyle:UIAlertControllerStyleAlert];
            
            // Create the actions.
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                [self.navigationController popViewControllerAnimated:YES];
                //取消
            }];
            
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self setPayPassword];
            }];
            
            
            // Add the actions.
            [alertController addAction:cameraAction];
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            return;
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"尚未设置密码，马上设置？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"马上设置", nil];
        alert.tag = 100;
        [alert show];
        
        return;
    }
    NSNumber *boyJoin = [NSNumber numberWithBool:[[switchDict objectForKey:@"2"] boolValue]];
    NSNumber *girlJoin = [NSNumber numberWithBool:[[switchDict objectForKey:@"3"] boolValue]];
    
    BOOL notShowAlert = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notShowContestReviewAlert"] boolValue];
    if (notShowAlert) {
        [self inputPayPassword];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"notShowContestReviewAlert"];
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"为了维护平台良好的发展，发布的内容我们会进行审核，只有通过审核的内容才会在App显示出来，不便之处，敬请原谅！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self inputPayPassword];
        }];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"为了维护平台良好的发展，发布的内容我们会进行审核，只有通过审核的内容才会在App显示出来，不便之处，敬请原谅！" delegate:self cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
        alert.tag = 3000;
        [alert show];
    }
    
    
    
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if(buttonIndex == 1){
            [self setPayPassword];
        }
    }
    else if (alertView.tag == 3000){
        [self inputPayPassword];
    }
}
- (void)setPayPassword
{
    //支付密码
    HeModifyPayPasswordVC *modifyPasswordVC = [[HeModifyPayPasswordVC alloc] init];
    modifyPasswordVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:modifyPasswordVC animated:YES];
}

- (void)editImageTap:(UITapGestureRecognizer *)tap
{
    currentSelectBanner = NO;
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied){
        //无权限
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"此应用没有权限访问您的照片或摄像机，请在: 隐私设置 中启用访问" delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"选择封面图片" preferredStyle:UIAlertControllerStyleActionSheet];
        
        // Create the actions.
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            //取消
        }];
        
        UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickerCamer];
        }];
        
        UIAlertAction *libAction = [UIAlertAction actionWithTitle:@"从手机相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self pickerPhotoLibrary];
        }];
        
        // Add the actions.
        [alertController addAction:cameraAction];
        [alertController addAction:libAction];
        [alertController addAction:cancelAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
        return;
    }
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 2;
    [sheet showInView:self.coverImage];
}

//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    switch (buttonIndex) {
//        case 0:
//        {
//            [self pickerPhotoLibrary];
//            break;
//        }
//        case 1:{
//            //查看大图
//            [self pickerCamer];
//            break;
//        }
//        case 2:
//            //取消
//            break;
//        default:
//            break;
//    }
//}

- (void)handleSelectPhoto
{
    for (AsynImageView *imageview in bannerImageDataSource) {
        if (imageview.imageTag != -1) {
            [bannerImageDataSource removeObject:imageview];
        }
    }
    
    for (UIImage *image in _selectedPhotos) {
        AsynImageView *asyncImage = [[AsynImageView alloc] init];
        [asyncImage setImage:image];
        asyncImage.bigImageURL = nil;
        [bannerImageDataSource addObject:asyncImage];
        
    }
    [self updateImageBG];
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
        imagePicker.videoQuality = UIImagePickerControllerQualityTypeLow;
        //设置可以编辑
        imagePicker.allowsEditing = YES;
        //设置类型为照相机
        imagePicker.sourceType = sourceType;
        //进入照相机画面
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}


- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}


- (void)mutiplepickPhotoSelect{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:MAXUPLOADIMAGE delegate:self];
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

//当按下相册按钮时触发事件
-(void)pickerPhotoLibrary
{
    //图片库类型
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    UIImagePickerController *photoAlbumPicker = [[UIImagePickerController alloc]init];
    photoAlbumPicker.delegate = self;
    photoAlbumPicker.videoQuality = UIImagePickerControllerQualityTypeMedium;
    //设置可以编辑
    photoAlbumPicker.allowsEditing = YES;
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
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    CGSize sizeImage = image.size;
    float a = [self getSize:sizeImage];
    if (a > 0) {
        CGSize size = CGSizeMake(sizeImage.width / a, sizeImage.height / a);
        image = [self scaleToSize:image size:size];
    }
    
    CGSize imagesize = image.size;
    CGFloat width = imagesize.width;
    CGFloat hight = imagesize.height;
    CGFloat sizewidth = width;
    if (hight < width) {
        sizewidth = hight;
    }
    
    
    if (!currentSelectBanner) {
        UIImage *editedImage = [info objectForKey:UIImagePickerControllerEditedImage];
        CGRect newframe = CGRectMake(0, 0, 512, 297);
        UIImage *scaleImage = [self imageFromImage:editedImage inRect:newframe];
        
        coverImage.image = scaleImage;
        [picker dismissViewControllerAnimated:YES completion:^{
            coverImageHaveTake = YES;
            [coverImage viewWithTag:8888].hidden = YES;
        }];
    }
    else{
        AsynImageView *asyncImage = [[AsynImageView alloc] init];
        
        UIImageJPEGRepresentation(image, 0.6);
        [asyncImage setImage:image];
        
        asyncImage.bigImageURL = nil;
        asyncImage.imageTag = -1; //表明是调用系统相机、相册的
        [bannerImageDataSource addObject:asyncImage];
        [self dismissViewControllerAnimated:YES completion:^{
            [self updateImageBG];
        }];
    }
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
//相应取消动作
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dateButtonClick:(id)sender withString:(NSString *)datestring
{
    [self.view addSubview:bgview];
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"请选择日期" date:datestring delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
    picker.tag = 11;
    [picker setActionSheetPickerStyle:IQActionSheetPickerStyleDatePicker];
    [picker showInView:self.view];
    
    
}

- (void)myactionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.bgview removeFromSuperview];
}
-(void)actionSheetPickerView:(IQActionSheetPickerView *)pickerView didSelectTitles:(NSArray *)titles
{
    NSString *datestring = [titles componentsJoinedByString:@"-"];
    
    NSLog(@"%@",datestring);
    self.tmpDateString = datestring;
    [tableview reloadData];
}

- (void)zjSwitchChange:(ZJSwitch *)zjSwitch
{
    NSInteger tag = zjSwitch.tag;
    NSString *key = [NSString stringWithFormat:@"%ld",tag];
    NSNumber *number = [NSNumber numberWithBool:zjSwitch.on];
    [switchDict setObject:number forKey:key];
    [tableview reloadData];
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
    if (section == 1) {
        return 3;
    }
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
    
    UIFont *textFont = [UIFont  systemFontOfSize:16.0];
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
            switch (row) {
                case 0:
                {
                    [cell addSubview:sectionHeaderView];
                    break;
                }
                case 1:{
                    titleField.frame = CGRectMake(labelX, labelY, labelW, labelH);
                    [cell addSubview:titleField];
                    break;
                }
                default:
                    break;
            }
            
            break;
        }
        case 1:
        {
            switch (row) {
                case 0:{
                    cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
                    break;
                }
                case 1:{
                    UIImageView *editIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_edit"]];
                    CGFloat imageW = 20;
                    CGFloat imageH = imageW;
                    CGFloat imageY = (cellSize.height - imageH) / 2.0;
                    CGFloat imageX = SCREENWIDTH - imageW - 20;
                    editIcon.frame = CGRectMake(imageX, imageY, imageW, imageH);
//                    [cell addSubview:editIcon];
                    CGRect frame = cell.topicLabel.frame;
                    frame.origin.x = 10;
                    cell.topicLabel.frame = frame;
                    break;
                }
                case 2:
                {
                    [cell addSubview:bannerImageBG];
                    break;
                }
                
                default:
                    break;
            }
            
            break;
        }
        case 2:{
            switch (row) {
                case 0:{
                    cell.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
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
//                    [cell addSubview:icon];
                    
                    
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - 10 - 100, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = self.tmpDateString;
                    if (self.tmpDateString == nil) {
                        tipLabel.text = @"请选择日期";
                    }
                    [cell addSubview:tipLabel];
                    
                    break;
                }
                case 2:
                {
                    CGFloat textW = 220;
                    CGFloat textH = cellSize.height;
                    CGFloat textY = 0;
                    CGFloat textX = SCREENWIDTH - 10 - textW;
                    
                    
                    addressField.textAlignment = NSTextAlignmentRight;
                    addressField.frame = CGRectMake(textX, textY, textW, textH);
                    addressField.enabled = NO;
                    addressField.backgroundColor = [UIColor clearColor];
                    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(textX, textY, textW, textH)];
                    addressLabel.textColor = APPDEFAULTORANGE;
                    addressLabel.backgroundColor = [UIColor clearColor];
                    addressLabel.text = addressField.text;
                    [cell addSubview:addressField];
                    addressLabel.textAlignment = NSTextAlignmentRight;
                
//                    [cell addSubview:addressField];
                    break;
                }
                case 3:
                {
                    CGFloat zjSwitchW = 50;
                    CGFloat zjSwitchH = 30;
                    CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
                    CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
                    ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
                    zjSwitch.on = [[switchDict objectForKey:@"2"] boolValue];
                    [zjSwitch addTarget:self action:@selector(zjSwitchChange:) forControlEvents:UIControlEventValueChanged];
                    zjSwitch.tag = 2;
                    [cell addSubview:zjSwitch];
                    break;
                }
                case 4:
                {
                    CGFloat zjSwitchW = 50;
                    CGFloat zjSwitchH = 30;
                    CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
                    CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
                    ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
                    zjSwitch.on = [[switchDict objectForKey:@"3"] boolValue];
                    [zjSwitch addTarget:self action:@selector(zjSwitchChange:) forControlEvents:UIControlEventValueChanged];
                    zjSwitch.tag = 3;
                    [cell addSubview:zjSwitch];
                    break;
                }
                case 5:
                {
                    CGFloat zjSwitchW = 50;
                    CGFloat zjSwitchH = 30;
                    CGFloat zjSwitchY = (cellSize.height - zjSwitchH) / 2.0;
                    CGFloat zjSwitchX = SCREENWIDTH - zjSwitchW - 10;
                    ZJSwitch *zjSwitch = [[ZJSwitch alloc] initWithFrame:CGRectMake(zjSwitchX, zjSwitchY, zjSwitchW, zjSwitchH)];
                    zjSwitch.on = [[switchDict objectForKey:@"4"] boolValue];
                    [zjSwitch addTarget:self action:@selector(zjSwitchChange:) forControlEvents:UIControlEventValueChanged];
                    zjSwitch.tag = 4;
                    [cell addSubview:zjSwitch];
                    break;
                }
                case 6:
                {
                    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREENWIDTH - 50, 0, 50, cellSize.height)];
                    titleLabel.font = [UIFont systemFontOfSize:16.0];
                    titleLabel.textColor = APPDEFAULTORANGE;
                    titleLabel.text = @"元";
                    titleLabel.textAlignment = NSTextAlignmentCenter;
                    [cell addSubview:titleLabel];
                    
                    CGFloat textW = 220;
                    CGFloat textH = cellSize.height;
                    CGFloat textY = 0;
                    CGFloat textX = CGRectGetMinX(titleLabel.frame) - 10 - textW;
                    rewardField.textAlignment = NSTextAlignmentRight;
                    rewardField.frame = CGRectMake(textX, textY, textW, textH);
                    [cell addSubview:rewardField];
                    break;
                }
                case 7:
                {
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - 110, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = @"平台回收10%赏金";
//                    [cell addSubview:tipLabel];
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
    
    if (row == 0) {
        if (section == 0) {
            return sectionHeaderView.frame.size.height;
        }
        else{
            return 10;
        }
    }
    if (section == 1 && row == 2) {
        return 2 * bannerImageBG.frame.origin.y + bannerImageBG.frame.size.height;
    }
    switch (row) {
        case 1:
        {
//            NSString *address = @"广东省中山市西区长乐新村10栋601会议厅8楼8501";
//            CGFloat labelW = 0;
//            UIFont *font = [UIFont  boldSystemFontOfSize:16.0];
//            CGSize textSize = [MLLinkLabel getViewSizeByString:address maxWidth:labelW font:font lineHeight:TextLineHeight lines:0];
//            if (textSize.height < 50) {
//                textSize.height = 50;
//            }
//            return textSize.height + 10;
//            break;
        }
        default:
            break;
    }
    
    return 50;
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 1:{
            switch (row) {
                case 1:
                {
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
                    
                    NSDate *nowDate = [NSDate date];
                    if (!([self.tmpDateString isMemberOfClass:[NSNull class]] || self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""])) {
                        
                        //设置转换格式
                        NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                        //NSString转NSDate
                        nowDate = [formatter dateFromString:self.tmpDateString];
                    }
                    [self setupDateView:DateTypeOfStart minDate:nowDate];
                    return;
                    __block HeDistributeContestVC *weakSelf = self;
                    HcdDateTimePickerView *dateTimePickerView = [[HcdDateTimePickerView alloc] initWithDatePickerMode:DatePickerDateHourMinuteMode defaultDateTime:nowDate];
                    dateTimePickerView.topViewColor = [UIColor greenColor];
                    dateTimePickerView.buttonTitleColor = [UIColor redColor];
                    [dateTimePickerView setMinYear:2016];
                    [dateTimePickerView setMaxYear:2020];
                    dateTimePickerView.topViewColor = APPDEFAULTORANGE;
                    dateTimePickerView.buttonTitleColor = [UIColor whiteColor];
                    dateTimePickerView.clickedOkBtn = ^(NSString * datetimeStr){
                        NSLog(@"%@", datetimeStr);
                        weakSelf.tmpDateString = datetimeStr;
                        [tableView reloadData];
                    };
//                    return;
                    if (dateTimePickerView) {
                        [self.view addSubview:dateTimePickerView];
                        [dateTimePickerView showHcdDateTimePicker];
                    }
                    return;
//                    if ([self.tmpDateString isMemberOfClass:[NSNull class]] || self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""]) {
//                        NSDate * startDate = [[NSDate alloc] init];
//                        NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//                        NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
//                        NSSecondCalendarUnit | NSDayCalendarUnit  | NSMonthCalendarUnit | NSYearCalendarUnit;
//                        NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:startDate];
//                        NSUInteger day = [cps day];
//                        NSUInteger month = [cps month];
//                        NSUInteger year = [cps year];
//                        NSUInteger hour = [cps hour];
//                        NSUInteger minute = [cps minute];
//                        self.tmpDateString = [NSString stringWithFormat:@"%d-%d-%d %d:%d",(int)year,(int)month,(int)day,(int)hour,(int)minute];
//                    }
//                    
//                    [self dateButtonClick:nil withString:self.tmpDateString];
                    break;
                }
                case 2:{
                    HeUserLocatiVC *locationVC = [[HeUserLocatiVC alloc] init];
                    locationVC.editLocation = YES;
                    locationVC.addressDelegate = self;
                    locationVC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:locationVC animated:YES];
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

- (void)getSelectDate:(NSString *)date type:(DateType)type {
    
    NSLog(@"时间 : %@",date);
    switch (type) {
        case DateTypeOfStart:
            // TODO 日期确定选择
            self.tmpDateString = date;
            [tableview reloadData];
            break;
            
        case DateTypeOfEnd:
            // TODO 日期取消选择
            break;
        default:
            break;
    }
}

- (void)setupDateView:(DateType)type minDate:(NSDate *)minDate{
    
    UWDatePickerView *pickerView = [UWDatePickerView instanceDatePickerView];
    pickerView.datePickerView.minimumDate = minDate;
    if (!minDate) {
        pickerView.datePickerView.minimumDate = [NSDate date];
    }
    NSDate *maxDate = [minDate dateByAddingTimeInterval:365 * 24 * 60 * 60];
    pickerView.datePickerView.maximumDate = maxDate;
    
    pickerView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [pickerView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.8]];
    pickerView.delegate = self;
    pickerView.type = type;
    [self.view addSubview:pickerView];
    
}

- (void)getUserInfoWithDict:(NSDictionary *)addressDict
{
    NSString *zoneLocationX = addressDict[@"zoneLocationX"];
    NSString *zoneLocationY = addressDict[@"zoneLocationY"];
    NSString *address = addressDict[@"address"];
    [userLocationDict setObject:zoneLocationX forKey:@"zoneLocationX"];
    [userLocationDict setObject:zoneLocationY forKey:@"zoneLocationY"];
    [userLocationDict setObject:address forKey:@"address"];
    addressField.text = address;
}

//实现相关delegate 处理位置信息更新
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    CLLocation *newLocation = userLocation.location;
    CLLocationCoordinate2D coordinate = newLocation.coordinate;
    
    NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.longitude];
    
    
    if (newLocation) {
        locationSucceedNum = locationSucceedNum + 1;
        if (locationSucceedNum >= MinLocationSucceedNum) {
            [self hideHud];
            locationSucceedNum = 0;
            [userLocationDict setObject:latitudeStr forKey:@"latitude"];
            [userLocationDict setObject:longitudeStr forKey:@"longitude"];
            [_locService stopUserLocationService];
            
            BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
            reverseGeoCodeOption.reverseGeoPoint = coordinate;
            _geoSearch.delegate = self;
            //进行反地理编码
            [_geoSearch reverseGeoCode:reverseGeoCodeOption];
            
        }
    }
    //NSLog(@"heading is %@",userLocation.heading);
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    //    NSLog(@"地址是：%@,%@",result.address,result.addressDetail);
    addressField.text = result.address;
}

- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    NSLog(@"%@",result.address);
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    //NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
}

#pragma mark CLLocationManagerDelegate
//iOS6.0以后定位更新使用的代理方法
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *newLocation = [locations objectAtIndex:0];
    CLLocationCoordinate2D coordinate1 = newLocation.coordinate;
    
    CLLocationCoordinate2D coordinate = [self returnBDPoi:coordinate1];
    NSString *latitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.latitude];
    NSString *longitudeStr = [NSString stringWithFormat:@"%.6f",coordinate.longitude];
    
    
    if (newLocation) {
        locationSucceedNum = locationSucceedNum + 1;
        if (locationSucceedNum >= MinLocationSucceedNum) {
            [self hideHud];
            locationSucceedNum = 0;
            [userLocationDict setObject:latitudeStr forKey:@"latitude"];
            [userLocationDict setObject:longitudeStr forKey:@"longitude"];
            [_locService stopUserLocationService];
            
            BMKReverseGeoCodeOption *reverseGeoCodeOption = [[BMKReverseGeoCodeOption alloc] init];
            reverseGeoCodeOption.reverseGeoPoint = coordinate;
            _geoSearch.delegate = self;
            //进行反地理编码
            [_geoSearch reverseGeoCode:reverseGeoCodeOption];
           
        }
    }
    
}

#pragma 火星坐标系 (GCJ-02) 转 mark-(BD-09) 百度坐标系 的转换算法
-(CLLocationCoordinate2D)returnBDPoi:(CLLocationCoordinate2D)PoiLocation
{
    const double x_pi = 3.14159265358979324 * 3000.0 / 180.0;
    float x = PoiLocation.longitude + 0.0065, y = PoiLocation.latitude + 0.006;
    float z = sqrt(x * x + y * y) + 0.00002 * sin(y * x_pi);
    float theta = atan2(y, x) + 0.000003 * cos(x * x_pi);
    CLLocationCoordinate2D GCJpoi=
    CLLocationCoordinate2DMake( z * sin(theta),z * cos(theta));
    return GCJpoi;
}

//定位失误时触发
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"error:%@",error);
    //    [self.view makeToast:@"定位失败,请重新定位" duration:2.0 position:@"center"];
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
