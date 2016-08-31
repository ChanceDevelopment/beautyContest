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

#define MinLocationSucceedNum 1   //要求最少成功定位的次数
#define TextLineHeight 1.2f

@interface HeDistributeContestVC ()<UITextFieldDelegate,UITableViewDelegate,UITableViewDataSource,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    BMKLocationService *_locService;
    BMKGeoCodeSearch *_geoSearch;
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
    titleDataSource = @[@[@""],@[@"截止时间",@"定位",@"男生参加",@"女生参加",@"",@""]];
    switchDict = [[NSMutableDictionary alloc] initWithCapacity:0];
    [switchDict setObject:@YES forKey:@"2"];
    [switchDict setObject:@YES forKey:@"3"];
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
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 200)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    tableview.tableHeaderView = sectionHeaderView;
    
    coverImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"index2.jpg"]];
    coverImage.frame = CGRectMake(0, 0, SCREENWIDTH, 200);
    coverImage.userInteractionEnabled = YES;
    [sectionHeaderView addSubview:coverImage];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editImageTap:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [coverImage addGestureRecognizer:tap];
    coverImage.userInteractionEnabled = YES;
    
    titleField = [[UITextField alloc] init];
    titleField.layer.borderColor = [UIColor clearColor].CGColor;
    titleField.delegate = self;
    titleField.placeholder = @"请输入比赛主题";
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
    
    _geoSearch = [[BMKGeoCodeSearch alloc] init];
    _geoSearch.delegate = self;
    
    
    locationSucceedNum = 0;
}

- (void)distributeContest:(UIBarButtonItem *)barItem
{
    NSLog(@"distributeContest");
}

- (IBAction)distributeButtonClick:(id)sender
{

}

- (void)editImageTap:(UITapGestureRecognizer *)tap
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"修改头像" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    [sheet showInView:self.coverImage];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
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
    if (a>0) {
        CGSize size = CGSizeMake(sizeImage.width/a, sizeImage.height/a);
        image = [self scaleToSize:image size:size];
    }
    
    CGSize imagesize = image.size;
    CGFloat width = imagesize.width;
    CGFloat hight = imagesize.height;
    CGFloat sizewidth = width;
    if (hight < width) {
        sizewidth = hight;
    }
    CGRect newframe = CGRectMake(0, 0, sizewidth, sizewidth);
    UIImage *scaleImage = [self imageFromImage:image inRect:newframe];
    coverImage.image = scaleImage;
    
    
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(float)getSize:(CGSize)size
{
    float a = size.width/480;
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
            titleField.frame = CGRectMake(labelX, labelY, labelW, labelH);
            [cell addSubview:titleField];
            break;
        }
//        case 1:{
//            CGFloat iconW = 20;
//            CGFloat iconH = 20;
//            CGFloat iconX = SCREENWIDTH - iconW - 10;
//            CGFloat iconY = (cellSize.height - iconH) / 2.0;
//            UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_edit"]];
//            icon.frame = CGRectMake(iconX , iconY, iconW, iconH);
//            [cell addSubview:icon];
//            
//            CGRect frame = cell.topicLabel.frame;
//            frame.origin.x = labelX;
//            cell.topicLabel.frame = frame;
//            cell.topicLabel.text = @"主题广告";
//            break;
//        }
        case 1:{
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
                    
                    if (self.tmpDateString == nil) {
                        self.tmpDateString = @"请选择日期";
                    }
                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - iconW - 15 - 100, cellSize.height)];
                    tipLabel.textAlignment = NSTextAlignmentRight;
                    tipLabel.backgroundColor = [UIColor clearColor];
                    tipLabel.textColor = APPDEFAULTORANGE;
                    tipLabel.font = textFont;
                    tipLabel.text = self.tmpDateString;
                    [cell addSubview:tipLabel];
                    
                    break;
                }
                case 1:
                {
//                    CGFloat iconW = 20;
//                    CGFloat iconH = 20;
//                    CGFloat iconX = SCREENWIDTH - iconW - 10;
//                    CGFloat iconY = (cellSize.height - iconH) / 2.0;
//                    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appIcon"]];
//                    icon.frame = CGRectMake(iconX , iconY, iconW, iconH);
//                    [cell addSubview:icon];
                    
                    CGFloat textW = 250;
                    CGFloat textH = cellSize.height;
                    CGFloat textY = 0;
                    CGFloat textX = SCREENWIDTH - 10 - textW;
                    addressField.frame = CGRectMake(textX, textY, textW, textH);
                    [cell addSubview:addressField];
//                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - iconW - 15 - 100, cellSize.height)];
//                    tipLabel.textAlignment = NSTextAlignmentRight;
//                    tipLabel.backgroundColor = [UIColor clearColor];
//                    tipLabel.textColor = APPDEFAULTORANGE;
//                    tipLabel.font = textFont;
//                    tipLabel.text = @"广东珠海";
//                    [cell addSubview:tipLabel];
                    break;
                }
                case 2:
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
                case 3:
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
                case 4:
                {
                    CGFloat textW = 250;
                    CGFloat textH = cellSize.height;
                    CGFloat textY = 0;
                    CGFloat textX = SCREENWIDTH - 10 - textW;
                    rewardField.frame = CGRectMake(textX, textY, textW, textH);
                    [cell addSubview:rewardField];
                    
//                    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, SCREENWIDTH - 110, cellSize.height)];
//                    tipLabel.textAlignment = NSTextAlignmentRight;
//                    tipLabel.backgroundColor = [UIColor clearColor];
//                    tipLabel.textColor = APPDEFAULTORANGE;
//                    tipLabel.font = textFont;
//                    tipLabel.text = @"￥ 0.00";
//                    [cell addSubview:tipLabel];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    switch (section) {
        case 2:
        {
            switch (row) {
                case 0:
                {
                    if ([self.tmpDateString isMemberOfClass:[NSNull class]] || self.tmpDateString == nil || [self.tmpDateString isEqualToString:@""]) {
                        NSDate * startDate = [[NSDate alloc] init];
                        NSCalendar * chineseCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                        NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit |
                        NSSecondCalendarUnit | NSDayCalendarUnit  | NSMonthCalendarUnit | NSYearCalendarUnit;
                        NSDateComponents * cps = [chineseCalendar components:unitFlags fromDate:startDate];
                        NSUInteger day = [cps day];
                        NSUInteger month = [cps month];
                        NSUInteger year = [cps year];
                        self.tmpDateString = [NSString stringWithFormat:@"%d-%d-%d",(int)year,(int)month,(int)day];
                    }
                    
                    [self dateButtonClick:nil withString:self.tmpDateString];
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
//            [userLocationDict setObject:latitudeStr forKey:@"latitude"];
//            [userLocationDict setObject:longitudeStr forKey:@"longitude"];
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
//            [userLocationDict setObject:latitudeStr forKey:@"latitude"];
//            [userLocationDict setObject:longitudeStr forKey:@"longitude"];
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
