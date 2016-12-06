//
//  HeUserInfoVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/9/2.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeEditUserInfoVC.h"
#import "HeBaseTableViewCell.h"
#import "HeBaseIconTitleTableCell.h"
#import "HeSysbsModel.h"
#import "MLLinkLabel.h"
#import "MLLabel+Size.h"
#import "HeEditUserInfoVC.h"
#import "IQActionSheetPickerView.h"

#define TextLineHeight 1.2f
#define HEADTAG 100
#define SEXTAG 200
#define NAMETAG 300
#define ADDRESSTAG 400
#define ALERTTAG 500

#define SEXACTIONTAG 600
#define BLOODACTIONTAG 700

@interface HeEditUserInfoVC ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate,IQActionSheetPickerView,UITextFieldDelegate>
{
    BOOL haveSelectUserImage;
}
@property(strong,nonatomic)IBOutlet UITableView *tableview;
@property(strong,nonatomic)NSArray *iconDataSource;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSString *tmpDateString;
@property(strong,nonatomic)UIView *bgview;
@property(strong,nonatomic)UIView *dismissView;
@property(strong,nonatomic)UITextField *nameField;
@property(strong,nonatomic)UITextField *addressField;
@property(strong,nonatomic)UITextField *userSignField;
@property(strong,nonatomic)UITextField *tallField;
@property(strong,nonatomic)UITextField *weightField;
@property(strong,nonatomic)UITextField *professionField;
@property(assign,nonatomic)BOOL updateByUserInfoFinish;
@property(assign,nonatomic)BOOL updateByUserNameFinish;
@end

@implementation HeEditUserInfoVC
@synthesize tableview;
@synthesize iconDataSource;
@synthesize dataSource;
@synthesize sectionHeaderView;
@synthesize userInfo;
@synthesize tmpDateString;
@synthesize bgview;
@synthesize dismissView;
@synthesize nameField;

@synthesize addressField;
@synthesize userSignField;
@synthesize tallField;
@synthesize weightField;
@synthesize professionField;

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
        label.text = @"编辑个人信息";
        [label sizeToFit];
        
        self.title = @"编辑个人信息";
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
    dataSource = @[@"",@"职业:",@"性别:",@"出生年月:",@"身高(cm):",@"体重(kg):",@"血型:",@"所在地:",@"个性签名"];
    iconDataSource = @[@"",@"",@"",@"",@"",@"",@"",@"",@""];
    if (!userInfo) {
        userInfo = [HeSysbsModel getSysModel].user;
    }
    self.updateByUserInfoFinish = NO;
    self.updateByUserNameFinish = NO;
    haveSelectUserImage = NO;
}

- (void)initView
{
    [super initView];
    
    UIBarButtonItem *saveItem = [[UIBarButtonItem alloc] init];
    saveItem.title = @"保存";
    saveItem.target = self;
    saveItem.action = @selector(saveUserInfo:);
    self.navigationItem.rightBarButtonItem = saveItem;
    
    tableview.backgroundView = nil;
    tableview.backgroundColor = [UIColor whiteColor];
    [Tool setExtraCellLineHidden:tableview];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 250)];
    sectionHeaderView.backgroundColor = [UIColor whiteColor];
    sectionHeaderView.userInteractionEnabled = YES;
//    tableview.tableHeaderView = sectionHeaderView;
    
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 130)];
    bgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"NavBarIOS7"]];
    [sectionHeaderView addSubview:bgView];
    
    CGFloat detailImageW = 60;
    CGFloat detailImageH = 60;
    CGFloat detailImageX = (SCREENWIDTH - detailImageW) / 2.0;
    CGFloat detailImageY = CGRectGetMaxY(bgView.frame) - detailImageH / 2.0;
    
    UIImageView *userHeadImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"userDefalut_icon"]];
    userHeadImage.layer.borderWidth = 1.0;
    userHeadImage.layer.borderColor = [UIColor whiteColor].CGColor;
    userHeadImage.frame = CGRectMake(detailImageX, detailImageY, detailImageW, detailImageH);
    userHeadImage.layer.cornerRadius = detailImageW / 2.0;
    userHeadImage.layer.masksToBounds = YES;
    userHeadImage.contentMode = UIViewContentModeScaleAspectFill;
    [sectionHeaderView addSubview:userHeadImage];
    userHeadImage.tag = HEADTAG;
    
    NSString *userHeader = userInfo.userHeader;
    if (![userHeader hasPrefix:@"http"]) {
        userHeader = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,userHeader];
    }
    [userHeadImage sd_setImageWithURL:[NSURL URLWithString:userHeader] placeholderImage:userHeadImage.image];
    
    userHeadImage.userInteractionEnabled = YES;
    sectionHeaderView.userInteractionEnabled = YES;
    UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editUserHead:)];
    editTap.numberOfTapsRequired = 1;
    editTap.numberOfTouchesRequired = 1;
    [userHeadImage addGestureRecognizer:editTap];
    
    CGFloat nameX = 0;
    CGFloat nameH = 30;
    CGFloat nameY = CGRectGetMaxY(userHeadImage.frame);
    CGFloat nameW = SCREENWIDTH;
    nameField = [[UITextField alloc] init];
    nameField.textAlignment = NSTextAlignmentCenter;
    nameField.backgroundColor = [UIColor clearColor];
    nameField.text = [NSString stringWithFormat:@"%@",userInfo.userNick];
    nameField.delegate = self;
//    nameLabel.numberOfLines = 0;
    nameField.textColor = [UIColor blackColor];
    nameField.font = [UIFont systemFontOfSize:18.0];
    nameField.frame = CGRectMake(nameX, nameY, nameW, nameH);
    [sectionHeaderView addSubview:nameField];
    
    bgview = [[UIView alloc] init];
    bgview.frame = self.view.frame;
    bgview.backgroundColor = [UIColor colorWithWhite:135.0/255.0 alpha:0.5];
    dismissView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, [UIScreen mainScreen].bounds.size.height)];
    dismissView.backgroundColor = [UIColor blackColor];
    dismissView.hidden = YES;
    dismissView.alpha = 0.7;
    [self.view addSubview:dismissView];
    UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissViewGes:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [dismissView addGestureRecognizer:tapGes];
//    CGFloat iconW = 20;
//    CGFloat iconH = 20;
//    CGFloat iconX = (SCREENWIDTH - iconW) / 2.0;
//    CGFloat iconY = CGRectGetMaxY(nameLabel.frame);
//    NSString *sexName = @"icon_sex_boy";
//    if (userInfo.sex == 2) {
//        sexName= @"icon_sex_girl";
//    }
//    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:sexName]];
//    icon.tag = SEXTAG;
//    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
//    [sectionHeaderView addSubview:icon];
//    
//    CGFloat addressX = 10;
//    CGFloat addressH = 30;
//    CGFloat addressY = CGRectGetMaxY(icon.frame) + 5;
//    CGFloat addressW = SCREENWIDTH - 2 * addressX;
//    NSString *address = userInfo.userAddress;
//    
//    UIFont *textFont = [UIFont systemFontOfSize:15.0];
//    CGSize addressSize = [MLLinkLabel getViewSizeByString:address maxWidth:addressW font:textFont lineHeight:TextLineHeight lines:0];
//    addressH = addressSize.height;
//    if (addressH < 30) {
//        addressH = 30;
//    }
//    
//    UILabel *addressLabel = [[UILabel alloc] init];
//    addressLabel.textAlignment = NSTextAlignmentCenter;
//    addressLabel.backgroundColor = [UIColor clearColor];
//    addressLabel.text = address;
//    addressLabel.numberOfLines = 0;
//    addressLabel.textColor = [UIColor blackColor];
//    addressLabel.font = textFont;
//    addressLabel.frame = CGRectMake(addressX, addressY, addressW, addressH);
//    [sectionHeaderView addSubview:addressLabel];
    
    CGFloat sectionHeight = CGRectGetMaxY(nameField.frame) + 20;
    CGRect sectionFrame = sectionHeaderView.frame;
    sectionFrame.size.height = sectionHeight;
    sectionHeaderView.frame = sectionFrame;
//    tableview.tableHeaderView = sectionHeaderView;
    [nameField becomeFirstResponder];
}

- (void)saveUserInfo:(UIBarButtonItem *)item
{
    NSString *userAddress = addressField.text;
    if (userAddress == nil) {
        userAddress = userInfo.userAddress;
    }
    NSString *userHeader = userInfo.userHeader;
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *userNick = nameField.text;
    if (userNick == nil) {
        userNick = userInfo.userNick;
    }
    NSNumber *userPositionX = [NSNumber numberWithFloat:[userInfo.userPositionX floatValue]];
    NSNumber *userPositionY = [NSNumber numberWithFloat:[userInfo.userPositionY floatValue]];
    NSNumber *userSex = [NSNumber numberWithInteger:userInfo.userSex];
    NSString *userSign = userSignField.text;
    if (userSign == nil) {
        userSign = userInfo.userSign;
    }
    NSDictionary *userName_param = @{@"userAddress":userAddress,@"userHeader":userHeader,@"userId":userId,@"userNick":userNick,@"userPositionX":userPositionX,@"userPositionY":userPositionY,@"userSex":userSex,@"userSign":userSign};
    
    
    NSString *infoBirth = userInfo.infoBirth;
    if (infoBirth == nil) {
        infoBirth = userInfo.infoBirth;
    }
    long long timeSep = [Tool convertStringToTimesp:userInfo.infoBirth dateFormate:@"yyyy-MM-dd"];
    infoBirth = [NSString stringWithFormat:@"%lld000",timeSep];
    
    NSString *infoBlood = userInfo.infoBlood;
    if ([infoBlood isEqualToString:@"A"]) {
        infoBlood = @"0";
    }
    else if ([infoBlood isEqualToString:@"B"]) {
        infoBlood = @"1";
    }
    else if ([infoBlood isEqualToString:@"AB"]) {
        infoBlood = @"2";
    }
    else {
        infoBlood = @"3";
    }
    NSString *infoProfession = professionField.text;
    if (infoProfession == nil) {
        infoProfession = userInfo.infoProfession;
    }
    NSString *infoTall = tallField.text;
    if (infoTall == nil) {
        infoTall = userInfo.infoTall;
    }
    NSString *infoUser = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    NSString *infoWeight = weightField.text;
    if (infoWeight == nil) {
        infoWeight = userInfo.infoWeight;
    }
    NSString *infoZodiac = [NSString stringWithFormat:@"%ld",[userInfo.infoZodiac integerValue]];
    
    NSDictionary *userInfo_param = @{@"infoBirth":infoBirth,@"infoBlood":infoBlood,@"infoProfession":infoProfession,@"infoTall":infoTall,@"infoUser":infoUser,@"infoWeight":infoWeight,@"infoZodiac":infoZodiac,@"infoMeasurements":@""};
    
    if (userNick == nil || [userNick isEqualToString:@""]) {
        [self showHint:@"请输入用户昵称"];
        return;
    }
    
    
    if (haveSelectUserImage) {
        UIImageView *userImage = [sectionHeaderView viewWithTag:HEADTAG];
        UIImage *imageData = userImage.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        NSString *userHeader = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        
        userName_param = @{@"userHeader":userHeader,@"userAddress":userAddress,@"userHeader":userHeader,@"userId":userId,@"userNick":userNick,@"userPositionX":userPositionX,@"userPositionY":userPositionY,@"userSex":userSex,@"userSign":userSign};
    }
    [self updateUserByUserNameWith:@{@"jsonDate":[userName_param JSONString]}];
    [self updateUserInfoByInfoUser:@{@"jsonDate":[userInfo_param JSONString]}];
}

- (void)updateUserByUserNameWith:(NSDictionary *)param
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/updateUserByuserName.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    [self showHudInView:self.view hint:@"正在更新..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        self.updateByUserNameFinish = YES;
        if (statueCode == REQUESTCODE_SUCCEED){
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
            [self.tableview reloadData];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:self];
            if (self.updateByUserInfoFinish && self.updateByUserNameFinish) {
                [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.2];
            }
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)updateUserInfoByInfoUser:(NSDictionary *)param
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/user/updateUserInfoByinfoUser.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
//    [self showHudInView:self.view hint:@"正在更新..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        self.updateByUserInfoFinish = YES;
        if (statueCode == REQUESTCODE_SUCCEED){
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
            [self.tableview reloadData];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserInfo" object:self];
            if (self.updateByUserInfoFinish && self.updateByUserNameFinish) {
                [self performSelector:@selector(backToLastView) withObject:nil afterDelay:0.2];
            }
        }
        else{
            NSString *data = [respondDict objectForKey:@"data"];
            if ([data isMemberOfClass:[NSNull class]] || data == nil) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
            
        }
    } failure:^(NSError *error){
        
        [self showHint:ERRORREQUESTTIP];
    }];
}


- (void)backToLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)editUserHead:(UITapGestureRecognizer *)tap
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"来自相册",@"来自拍照", nil];
    sheet.tag = 2;
    [sheet showInView:tap.view];
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
        imagePicker.allowsEditing = YES;
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
    
    //    [self initButtonWithImage:image];
    
//    AsynImageView *asyncImage = [[AsynImageView alloc] init];
    
    UIImageJPEGRepresentation(image, 0.6);
    
    [self dismissViewControllerAnimated:YES completion:^{
        haveSelectUserImage = YES;
        UIImageView *userImage = [sectionHeaderView viewWithTag:HEADTAG];
        [userImage setImage:image];
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

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    
    static NSString *cellIndentifier = @"HeUserCellIndentifier";
    CGSize cellSize = [tableView rectForRowAtIndexPath:indexPath].size;
    
    
    HeBaseIconTitleTableCell *cell  = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell) {
        cell = [[HeBaseIconTitleTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        //        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    CGFloat iconH = 25;
    CGFloat iconW = 25;
    CGFloat iconX = 10;
    CGFloat iconY = (cellSize.height - iconH) / 2.0;
    NSString *image = iconDataSource[row];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:image]];
    icon.frame = CGRectMake(iconX, iconY, iconW, iconH);
    [cell.contentView addSubview:icon];
    
    NSString *title = dataSource[row];
    UIFont *textFont = [UIFont systemFontOfSize:16.0];
    
    CGFloat titleX = iconX + iconW + 10;
    if (icon.image == nil) {
        titleX = 10;
    }
    id content = @"未设置";
    switch (row) {
        case 0:{
            [cell addSubview:sectionHeaderView];
            break;
        }
        case 1:
        {
            content = userInfo.infoProfession;
            break;
        }
        case 2:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            if (userInfo.userSex == 1) {
                content = @"男";
            }
            else{
                content = @"女";
            }
            break;
        }
        case 3:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            content = userInfo.infoBirth;
            break;
        }
        case 4:
        {
            if (userInfo.infoTall == nil || [userInfo.infoTall isEqualToString:@""]) {
                content = @"";
            }
            else{
                content = [NSString stringWithFormat:@"%.1lf",[userInfo.infoTall floatValue]];
            }
            
            break;
        }
        case 5:
        {
            if (userInfo.infoTall == nil || [userInfo.infoTall isEqualToString:@""]) {
                content = @"";
            }
            else{
                content = [NSString stringWithFormat:@"%.1lf",[userInfo.infoWeight floatValue]];
            }
            
            break;
        }
        case 6:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            content = userInfo.infoBlood;
            break;
        }
        case 7:
        {
            content = userInfo.userAddress;
            break;
        }
        case 8:
        {
            content = userInfo.userSign;
            break;
        }
        default:
            break;
    }
    if ([content isKindOfClass:[NSString class]]) {
        if (content == nil || [content isEqualToString:@""]) {
            content = @"未设置";
        }
    }
    
    CGFloat titleY = 0;
    CGFloat titleH = cellSize.height;
    CGFloat titleW = SCREENWIDTH - titleX - 10;
    
    if (row == 2 || row == 3 || row == 6) {
        UILabel *topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = [NSString stringWithFormat:@"%@  %@",title,content];
        topicLabel.numberOfLines = 0;
        topicLabel.textColor = [UIColor blackColor];
        topicLabel.font = textFont;
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [cell.contentView addSubview:topicLabel];
    }
    else if(row != 0){
        
        CGSize textSize = [MLLinkLabel getViewSizeByString:title maxWidth:titleW font:textFont lineHeight:TextLineHeight lines:0];
        
        titleW = titleX + textSize.width;
        UILabel *topicLabel = [[UILabel alloc] init];
        topicLabel.textAlignment = NSTextAlignmentLeft;
        topicLabel.backgroundColor = [UIColor clearColor];
        topicLabel.text = [NSString stringWithFormat:@"%@",title];
        topicLabel.numberOfLines = 0;
        topicLabel.textColor = [UIColor blackColor];
        topicLabel.font = textFont;
        topicLabel.frame = CGRectMake(titleX, titleY, titleW, titleH);
        [cell.contentView addSubview:topicLabel];
        titleX = CGRectGetMaxX(topicLabel.frame) + 5;
        titleW = SCREENWIDTH - titleX - 10;
        
        UITextField *textfield = [[UITextField alloc] init];
        textfield.delegate = self;
        textfield.textAlignment = NSTextAlignmentLeft;
        textfield.backgroundColor = [UIColor clearColor];
        textfield.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        if ([content isKindOfClass:[NSString class]] && [content isEqualToString:@"未设置"]) {
            textfield.placeholder = [NSString stringWithFormat:@"%@",content];
        }
        else{
            textfield.text = [NSString stringWithFormat:@"%@",content];
        }
        
        textfield.textColor = [UIColor blackColor];
        textfield.font = textFont;
        textfield.frame = CGRectMake(titleX, titleY, titleW, titleH);
        
        
        switch (row) {
            case 1:
            {
                if (!professionField) {
                    professionField = textfield;
                }
                else{
                    textfield = professionField;
                }
                break;
            }
            case 4:
            {
                if (!tallField) {
                    tallField = textfield;
                }
                else{
                    textfield = tallField;
                }
                break;
            }
            case 5:
            {
                if (!weightField) {
                    weightField = textfield;
                }
                else{
                    textfield = weightField;
                }
                break;
            }
            case 7:
            {
                if (!addressField) {
                    addressField = textfield;
                }
                else{
                    textfield = addressField;
                }
                break;
            }
            case 8:
            {
                if (!userSignField) {
                    userSignField = textfield;
                }
                else{
                    textfield = userSignField;
                }
                break;
            }
            default:
                break;
        }
        [cell.contentView addSubview:textfield];
    }
    
    
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    if (row == 0) {
        return sectionHeaderView.frame.size.height;
    }
    return 50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    NSInteger section = indexPath.section;
    [tableview deselectRowAtIndexPath:indexPath animated:YES];
    switch (row) {
        case 2:
        {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"请选择性别"                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
                //添加Button
                [alertController addAction: [UIAlertAction actionWithTitle: @"男" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    userInfo.userSex = 1;
                    [tableview reloadData];
                }]];
                [alertController addAction: [UIAlertAction actionWithTitle: @"女" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    userInfo.userSex = 2;
                    [tableview reloadData];
                }]];
                [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
                
                [self presentViewController: alertController animated: YES completion: nil];
            }
            else{
                UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"请选择性别" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"男",@"女", nil];
                actionsheet.tag = SEXACTIONTAG;
                [actionsheet showInView:self.view];
            }
            break;
        }
        case 6:
        {
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"请选择血型"                                                                             message: nil                                                                       preferredStyle:UIAlertControllerStyleActionSheet];
                //添加Button
                [alertController addAction: [UIAlertAction actionWithTitle: @"A" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    userInfo.infoBlood = @"A";
                    [tableview reloadData];
                }]];
                [alertController addAction: [UIAlertAction actionWithTitle: @"B" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    userInfo.infoBlood = @"B";
                    [tableview reloadData];
                }]];
                [alertController addAction: [UIAlertAction actionWithTitle: @"AB" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    userInfo.infoBlood = @"AB";
                    [tableview reloadData];
                }]];
                [alertController addAction: [UIAlertAction actionWithTitle: @"O" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action){
                    userInfo.infoBlood = @"O";
                    [tableview reloadData];
                }]];
                [alertController addAction: [UIAlertAction actionWithTitle: @"取消" style: UIAlertActionStyleCancel handler:nil]];
                
                [self presentViewController: alertController animated: YES completion: nil];
            }
            else{
                UIActionSheet *actionsheet = [[UIActionSheet alloc] initWithTitle:@"请选择血型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"A",@"B",@"O",@"AB", nil];
                actionsheet.tag = BLOODACTIONTAG;
                [actionsheet showInView:self.view];
            }
            break;
        }
        case 3:
        {
            [self modifyDate];
            break;
        }
        default:
            break;
    }
}

- (void)modifyDate
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
        NSUInteger hour = [cps hour];
        NSUInteger minute = [cps minute];
        self.tmpDateString = [NSString stringWithFormat:@"%d-%d-%d",(int)year,(int)month,(int)day];
    }
    
    [self dateButtonClick:nil withString:self.tmpDateString];
}

-(void)dateButtonClick:(id)sender withString:(NSString *)datestring
{
    [self.view addSubview:bgview];
    IQActionSheetPickerView *picker = [[IQActionSheetPickerView alloc] initWithTitle:@"请选择日期" date:datestring delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
//    picker.dateFormat = @"yyyy-MM-dd";
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
    self.tmpDateString = [NSString stringWithString:datestring];
    userInfo.infoBirth = self.tmpDateString;
    [tableview reloadData];
    NSLog(@"%@",datestring);
}

- (void)dismissViewGes:(UITapGestureRecognizer *)ges
{
    UIView *mydismissView = ges.view;
    mydismissView.hidden = YES;
    UIView *alertview = [self.view viewWithTag:ALERTTAG];
    [alertview removeFromSuperview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == SEXACTIONTAG) {
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"男");
                userInfo.userSex = 1;
                break;
            }
            case 1:
            {
                NSLog(@"女");
                userInfo.userSex = 2;
                break;
            }
            default:
                break;
        }
    }
    else if (actionSheet.tag == BLOODACTIONTAG){
        switch (buttonIndex) {
            case 0:
            {
                NSLog(@"A");
                userInfo.infoBlood = @"A";
                break;
            }
            case 1:
            {
                NSLog(@"B");
                userInfo.infoBlood = @"B";
                break;
            }
            case 2:
            {
                NSLog(@"AB");
                userInfo.infoBlood = @"AB";
                break;
            }
            case 3:
            {
                NSLog(@"O");
                userInfo.infoBlood = @"O";
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
    [tableview reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isFirstResponder]) {
        [textField resignFirstResponder];
    }
    return YES;
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
