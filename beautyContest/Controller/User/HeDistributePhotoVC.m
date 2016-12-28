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
#import "AFHTTPRequestOperationManager.h"

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
    [self showEULA];
}

- (void)showEULA
{
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"PhotoEULA"] boolValue]) {
        [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"PhotoEULA"];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"请发布健康向上的内容，禁止发布色情内容，否则我们会追究法律责任。您发布的内容我们平台会先审核，只有通过审核的内容才会在App里显示出来。" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
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
        case 3000:{
            [self showHudInView:self.scrollView hint:@"上传中..."];
            [self performSelector:@selector(uploadImage) withObject:nil afterDelay:0.2];
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
    BOOL notShowAlert = [[[NSUserDefaults standardUserDefaults] objectForKey:@"notShowPhotoReviewAlert"] boolValue];
    if (notShowAlert) {
        
        [self showHudInView:self.scrollView hint:@"上传中..."];
        [self performSelector:@selector(uploadImage) withObject:nil afterDelay:0.2];
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:@YES forKey:@"notShowPhotoReviewAlert"];
    if (ISIOS8) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"为了维护平台良好的发展，发布的内容我们会进行审核，只有通过审核的内容才会在App显示出来，不便之处，敬请原谅！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self showHudInView:self.scrollView hint:@"上传中..."];
            [self performSelector:@selector(uploadImage) withObject:nil afterDelay:0.2];
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

- (void)uploadImage
{
    NSMutableString *paper = [[NSMutableString alloc] initWithCapacity:0];
    NSMutableArray *imageArray = [[NSMutableArray alloc] initWithCapacity:0];
    
    for (NSInteger index = 0; index < self.pictureArray.count; index++) {
        AsynImageView *imageview = self.pictureArray[index];
        
        UIImage *imageData = imageview.image;
        NSData *data = UIImageJPEGRepresentation(imageData, 0.1);
        [imageArray addObject:data];
//        NSData *base64Data = [GTMBase64 encodeData:data];
//        NSString *base64String = [[NSString alloc] initWithData:base64Data encoding:NSUTF8StringEncoding];
//        if (index == 0) {
//            [paper appendString:base64String];
//        }
//        else {
//            [paper appendFormat:@"%@,%@",paper,base64String];
//        }
    }
    
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    //    NSString *paper = imageString;
    NSString *mark = @"ss";
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/paperWall/addPaperWall.action",BASEURL];
    NSDictionary *param = @{@"userId":userId,@"mark":mark};
    
    
    [self uploadOneFileData:imageArray imgType:@"image/jpeg" imgName:@"" otherParams:param];
    return;
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        if (![respondDict isKindOfClass:[NSDictionary class]]) {
            respondDict = [[NSDictionary alloc] init];
        }
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserAlbum" object:self];
            [self showHint:@"上传成功!"];
            [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.5];
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

-(void)uploadOneFileData:(NSArray *)woodImgData imgType:(NSString*)typeStr imgName:(NSString *)fileName otherParams:(NSDictionary *)otherParams{
    self.uploadSuccessNum = 0;
    __weak HeDistributePhotoVC *weakSelf = self;
    if (woodImgData) {
        for (NSData *imageData in woodImgData) {
            NSDictionary *params = [[NSDictionary alloc] initWithDictionary:otherParams];
            NSDate *senddate=[NSDate date];
            NSDateFormatter *dateformatter=[[NSDateFormatter alloc] init];
            [dateformatter setDateFormat:@"YYYYMMddhhmmss"];
            NSString *timeStr   = [dateformatter stringFromDate:senddate];
            
            NSString *temfile = [NSString stringWithFormat:@"%@.jpg",timeStr];
            AFHTTPRequestOperationManager *client = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:BASEURL]];
            [client POST:@"http://114.55.226.224:8088/xuanmei/paperWall/addPaperWallIOS.action" parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                [formData appendPartWithFileData:imageData name:@"paper" fileName:temfile mimeType:typeStr];
                
            } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                weakSelf.uploadSuccessNum++;
                NSLog(@"uploadSuccessNum = %ld",weakSelf.uploadSuccessNum);
                if (weakSelf.uploadSuccessNum != [woodImgData count]) {
                    return;
                }
                [self hideHud];
                NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
                NSDictionary *respondDict = [respondString objectFromJSONString];
                if (![respondDict isKindOfClass:[NSDictionary class]]) {
                    respondDict = [[NSDictionary alloc] init];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserAlbum" object:self];
                [self showHint:@"上传成功!"];
                [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.5];
//                NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
//                if (errorCode == REQUESTCODE_SUCCEED) {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserAlbum" object:self];
//                    [self showHint:@"上传成功!"];
//                    [self performSelector:@selector(backLastView) withObject:nil afterDelay:0.5];
//                }
//                else{
//                    NSString *data = [respondDict objectForKey:@"data"];
//                    if ([data isMemberOfClass:[NSNull class]] || data == nil) {
//                        data = ERRORREQUESTTIP;
//                    }
//                    [self showHint:data];
//                }
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                weakSelf.uploadSuccessNum++;
                NSLog(@"uploadSuccessNum = %ld",weakSelf.uploadSuccessNum);
                if (weakSelf.uploadSuccessNum != [woodImgData count]) {
                    return;
                }
                [self hideHud];
                [self showHint:ERRORREQUESTTIP];
            }];
        }
        
    }
}

+(NSString *)PostImagesToServer:(NSString *) strUrl dicPostParams:(NSMutableDictionary *)params dicImages:(NSMutableDictionary *) dicImages{
    NSString * res;
    
    
    //分界线的标识符
    NSString *TWITTERFON_FORM_BOUNDARY = @"AaB03x";
    //根据url初始化request
    //NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:strUrl] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    
    NSURL *url = [NSURL URLWithString:strUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //分界线 --AaB03x
    NSString *MPboundary=[[NSString alloc]initWithFormat:@"--%@",TWITTERFON_FORM_BOUNDARY];
    //结束符 AaB03x--
    NSString *endMPboundary=[[NSString alloc]initWithFormat:@"%@--",MPboundary];
    //要上传的图片
    UIImage *image;//=[params objectForKey:@"pic"];
    //得到图片的data
    //NSData* data = UIImagePNGRepresentation(image);
    //http body的字符串
    NSMutableString *body=[[NSMutableString alloc]init];
    //参数的集合的所有key的集合
    NSArray *keys= [params allKeys];
    
    //遍历keys
    for(int i=0;i<[keys count];i++) {
        //得到当前key
        NSString *key=[keys objectAtIndex:i];
        //如果key不是pic，说明value是字符类型，比如name：Boris
        //if(![key isEqualToString:@"pic"]) {
        //添加分界线，换行
        [body appendFormat:@"%@\r\n",MPboundary];
        //添加字段名称，换2行
        [body appendFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key];
        //[body appendString:@"Content-Transfer-Encoding: 8bit"];
        //添加字段的值
        [body appendFormat:@"%@\r\n",[params objectForKey:key]];
        //}
    }
    ////添加分界线，换行
    //[body appendFormat:@"%@\r\n",MPboundary];
    
    //声明myRequestData，用来放入http body
    NSMutableData *myRequestData=[NSMutableData data];
    //将body字符串转化为UTF8格式的二进制
    [myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    
    //循环加入上传图片
    keys = [dicImages allKeys];
    for(int i = 0; i< [keys count] ; i++){
        //要上传的图片
        image = [dicImages objectForKey:[keys objectAtIndex:i ]];
        //得到图片的data
        NSData* data =  UIImageJPEGRepresentation(image, 0.0);
        NSMutableString *imgbody = [[NSMutableString alloc] init];
        //此处循环添加图片文件
        //添加图片信息字段
        //声明pic字段，文件名为boris.png
        //[body appendFormat:[NSString stringWithFormat: @"Content-Disposition: form-data; name=\"File\"; filename=\"%@\"\r\n", [keys objectAtIndex:i]]];
        
        ////添加分界线，换行
        [imgbody appendFormat:@"%@\r\n",MPboundary];
        [imgbody appendFormat:@"Content-Disposition: form-data; name=\"File%d\"; filename=\"%@.png\"\r\n", i, [keys objectAtIndex:i]];
        //声明上传文件的格式
        [imgbody appendFormat:@"Content-Type: application/octet-stream; charset=utf-8\r\n\r\n"];
        
        NSLog(@"上传的图片：%d  %@", i, [keys objectAtIndex:i]);
        
        //将body字符串转化为UTF8格式的二进制
        //[myRequestData appendData:[body dataUsingEncoding:NSUTF8StringEncoding]];
        [myRequestData appendData:[imgbody dataUsingEncoding:NSUTF8StringEncoding]];
        //将image的data加入
        [myRequestData appendData:data];
        [myRequestData appendData:[ @"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
    }
    //声明结束符：--AaB03x--
    NSString *end=[[NSString alloc]initWithFormat:@"%@\r\n",endMPboundary];
    //加入结束符--AaB03x--
    [myRequestData appendData:[end dataUsingEncoding:NSUTF8StringEncoding]];
    
    //设置HTTPHeader中Content-Type的值
    NSString *content=[[NSString alloc]initWithFormat:@"multipart/form-data; boundary=%@",TWITTERFON_FORM_BOUNDARY];
    //设置HTTPHeader
    [request setValue:content forHTTPHeaderField:@"Content-Type"];
    //[request setValue:@"keep-alive" forHTTPHeaderField:@"connection"];
    //[request setValue:@"UTF-8" forHTTPHeaderField:@"Charsert"];
    //设置Content-Length
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[myRequestData length]] forHTTPHeaderField:@"Content-Length"];
    //设置http body
    [request setHTTPBody:myRequestData];
    //http method
    [request setHTTPMethod:@"POST"];
    
    //建立连接，设置代理
    //NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    //设置接受response的data
    NSData *mResponseData;
    NSError *err = nil;
    mResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
    
    if(mResponseData == nil){
        NSLog(@"err code : %@", [err localizedDescription]);
    }
    res = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];
    /*
     if (conn) {
     mResponseData = [NSMutableData data];
     mResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&err];
     
     if(mResponseData == nil){
     NSLog(@"err code : %@", [err localizedDescription]);
     }
     res = [[NSString alloc] initWithData:mResponseData encoding:NSUTF8StringEncoding];
     }else{
     res = [[NSString alloc] init];
     }*/
    NSLog(@"服务器返回：%@", res);
    return res;
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
