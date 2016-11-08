//
//  HeDistributePhotoVC.m
//  huayoutong
//
//  Created by Tony on 16/3/10.
//  Copyright © 2016年 HeDongMing. All rights reserved.
//

#import "HeDistributePhotoVC.h"
#import "SINavigationMenuView.h"
#import "UIButton+Bootstrap.h"
#import "HeSysbsModel.h"
#import "GTMBase64.h"

@interface HeDistributePhotoVC ()<SINavigationMenuDelegate,UIAlertViewDelegate>
@property(strong,nonatomic)NSArray *userAlbumArray;
@property(assign,nonatomic)NSInteger uploadSuccessNum; //已经成功上传的图片张数

@end

@implementation HeDistributePhotoVC

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
        label.text = @"发布相册图片";
        [label sizeToFit];
        
        self.title = @"发布相册图片";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self initializaiton];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)initializaiton
{
    [super initializaiton];
    
    self.uploadSuccessNum = 0;
}

- (void)initView
{
    [super initView];
    
    self.scrollView.backgroundColor = [UIColor whiteColor];
    self.headerBGView.frame = CGRectZero;
    self.headerBGView.backgroundColor = [UIColor whiteColor];
    self.headerBGView.hidden = YES;
    self.distributeTF.hidden = YES;
    
    CGRect distributeImageframe = self.distributeImageBG.frame;
    distributeImageframe.origin.y = 10;
    self.distributeImageBG.frame = distributeImageframe;
    self.distributeImageBG.backgroundColor = [UIColor whiteColor];
    
    
    UIButton *distributeButton = [[UIButton alloc] init];
    distributeButton.frame = CGRectMake(10, distributeImageframe.origin.y + distributeImageframe.size.height + 5, SCREENWIDTH - 20, 40);
    [distributeButton dangerStyle];
    distributeButton.layer.borderWidth = 0;
    distributeButton.layer.borderColor = [UIColor clearColor].CGColor;
    [distributeButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:distributeButton.frame.size] forState:UIControlStateNormal];
    [distributeButton setTitle:@"完  成" forState:UIControlStateNormal];
    [distributeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(distributeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.footview addSubview:distributeButton];
    
    CGRect footframe = self.footview.frame;
    footframe.origin.y = distributeImageframe.origin.y + distributeImageframe.size.height;
    footframe.size.height = distributeButton.frame.origin.y + distributeButton.frame.size.height + 20;
    self.footview.frame = footframe;
    
    if (footframe.origin.y + footframe.size.height > SCREENHEIGH) {
        self.scrollView.contentSize = CGSizeMake(0, footframe.origin.y + footframe.size.height);
    }
    
}

- (void)backItemClick:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"是否放弃上传图片?" delegate:self cancelButtonTitle:@"放弃" otherButtonTitles:@"继续上传", nil];
    alert.tag = 100;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
        {
            if (buttonIndex == 0) {
                [self.navigationController popViewControllerAnimated:YES];
            }
            break;
        }
        default:
            break;
    }
}


//获取上传图片到七牛的token GET_UPLOAD_ALBUM_UPLOADKEY
- (void)getUploadToken
{
    
}

//上传照片到七牛 UPLOAD_PHOTO_CLOUND
- (void)uploadPhotoToQNWithFileName:(NSString *)fileName link:(NSString *)link
{
    
}

- (void)backLastView
{
    [self.navigationController popViewControllerAnimated:YES];
}
//删除图片 ALBUM_DELETE
- (void)deletePhoto
{
    NSDictionary *deleteParams = @{@"items":@"",@"t_token":@""};
}

- (void)uploadImage:(NSData *)imageData key:(NSString *)uploadKey token:(NSString *)token fileName:(NSString *)fileName{
    
}

- (void)distributeButtonClick:(UIButton *)button
{
    if (self.pictureArray.count == 0) {
        [self showHint:@"请选择上传的图片"];
        return;
    }
    [self showHudInView:self.scrollView hint:@"上传中..."];
    [self performSelector:@selector(uploadImage) withObject:nil afterDelay:0.2];
}

- (void)uploadImage
{
    NSMutableString *paper = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < self.pictureArray.count; index++) {
        AsynImageView *imageview = self.pictureArray[index];
        
        UIImage *imageData = imageview.image;
        NSData *data = UIImageJPEGRepresentation(imageData,0.2);
        NSData *base64Data = [GTMBase64 encodeData:data];
        NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
        if (index == 0) {
            [paper appendString:base64String];
        }
        else {
            [paper appendFormat:@"%@,%@",paper,base64String];
        }
    }
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    //    NSString *paper = imageString;
    NSString *mark = @"ss";
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/paperWall/addPaperWall.action",BASEURL];
    NSDictionary *param = @{@"userId":userId,@"paper":paper,@"mark":mark};
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserAlbum" object:self];
            [self showHint:@"上传成功!"];
            [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.3];
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

- (void)didSelectItemAtIndex:(NSUInteger)index
{
    
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
