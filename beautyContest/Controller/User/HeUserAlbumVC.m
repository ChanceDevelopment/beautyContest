//
//  HeUserAlbumVC.m
//  beautyContest
//
//  Created by Tony on 16/8/25.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeUserAlbumVC.h"
#import "UIButton+Bootstrap.h"
#import "UIImageView+WebCache.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "HeAlbumImage.h"
#import "HeDistributePhotoVC.h"

#define MAx_row 100000
#define MAx_column 4

@interface HeUserAlbumVC ()
{
    BOOL isEditing;
}
@property(strong,nonatomic)UIScrollView *myScrollView;
@property(strong,nonatomic)NSMutableArray *photoArray;
@property(strong,nonatomic)NSMutableArray *photoDetailArray;
@property(strong,nonatomic)IBOutlet UIButton *addButton;
@property(strong,nonatomic)IBOutlet UIButton *deleteButton;
@property(strong,nonatomic)NSCache *imageCache;

@end

@implementation HeUserAlbumVC
@synthesize myScrollView;
@synthesize photoArray;
@synthesize addButton;
@synthesize deleteButton;
@synthesize photoDetailArray;
@synthesize imageCache;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize:20.0];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        self.navigationItem.titleView = label;
        label.text = @"照片墙";
        [label sizeToFit];
        self.title = @"照片墙";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadPhoto];
}

- (void)initializaiton
{
    [super initializaiton];
    photoArray = [[NSMutableArray alloc] initWithCapacity:0];
    photoDetailArray = [[NSMutableArray alloc] initWithCapacity:0];
    isEditing = NO;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateUserAlbum:) name:@"updateUserAlbum" object:nil];
    imageCache = [[NSCache alloc] init];
}

- (void)initView
{
    [super initView];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] init];
    editItem.title = @"编辑";
    editItem.target = self;
    editItem.action = @selector(editAlbum:);
//    self.navigationItem.rightBarButtonItem = editItem;
    
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    CGFloat viewX = 0;
    CGFloat viewY = 5;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = SCREENHEIGH - 2 * viewY - 50;
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
    [self.view addSubview:myScrollView];
    
    myScrollView.showsVerticalScrollIndicator = NO;
    myScrollView.showsHorizontalScrollIndicator = NO;
    
    [addButton dangerStyle];
    addButton.layer.borderColor = [UIColor clearColor].CGColor;
    [addButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:addButton.frame.size] forState:UIControlStateNormal];
    addButton.layer.masksToBounds = YES;
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addButton.layer.cornerRadius = 3.0;
    
    [deleteButton dangerStyle];
    deleteButton.layer.borderColor = [UIColor clearColor].CGColor;
    [deleteButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:addButton.frame.size] forState:UIControlStateNormal];
    deleteButton.layer.masksToBounds = YES;
    [deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    deleteButton.layer.cornerRadius = 3.0;
    
}

- (void)loadPhoto
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/paperWall/selectPaperWall.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userid};
    [self showHudInView:self.myScrollView hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [photoDetailArray removeAllObjects];
            [photoArray removeAllObjects];
            NSArray *myArray = [respondDict objectForKey:@"json"];
            for (NSDictionary *dict in myArray) {
                NSString *wallUrl = dict[@"wallUrl"];
                if ([wallUrl isMemberOfClass:[NSNull class]]) {
                    wallUrl = @"";
                }
                [photoArray addObject:wallUrl];
                [photoDetailArray addObject:dict];
            }
//            photoArray = [[NSMutableArray alloc] initWithArray:myArray];
            [self addPhotoView];
        }
        else{
            NSString *data = respondDict[@"data"];
            if ([data isMemberOfClass:[NSNull class]]) {
                data = ERRORREQUESTTIP;
            }
            [self showHint:data];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)updateUserAlbum:(NSNotification *)notification
{
    [self loadPhoto];
}

- (IBAction)addButtonClick:(id)sender
{
    HeDistributePhotoVC *distributeAlbumVC = [[HeDistributePhotoVC alloc] init];
    distributeAlbumVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:distributeAlbumVC animated:YES];
}

- (IBAction)deleteButtonClick:(id)sender
{
    NSMutableArray *deleteArray = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *subviewArray = myScrollView.subviews;
    for (UIView *myview in subviewArray) {
        if ([myview isMemberOfClass:[HeAlbumImage class]]) {
            HeAlbumImage *albumImage = (HeAlbumImage *)myview;
            if (albumImage.selected) {
                [deleteArray addObject:photoArray[albumImage.tag - 200]];
            }
        }
    }
    if ([deleteArray count] == 0) {
        [self showHint:@"请选择删除的图片"];
        return;
    }
    isEditing = NO;
    addButton.hidden = NO;
    deleteButton.hidden = YES;
    self.navigationItem.rightBarButtonItem.title = @"编辑";
    
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/paperWall/deletePaperWall.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSMutableString *paper = [[NSMutableString alloc] initWithCapacity:0];
    for (NSInteger index = 0; index < [deleteArray count]; index++) {
        NSString *string = deleteArray[index];
        if (index == 0) {
            [paper appendString:string];
        }
        else{
            [paper appendFormat:@",%@",string];
        }
    }
    NSDictionary *requestMessageParams = @{@"userId":userid,@"paper":paper};
    [self showHudInView:self.view hint:@"删除中..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            [self showHint:@"删除成功"];
            for (UIView *subview in subviewArray) {
                if ([subview isMemberOfClass:[HeAlbumImage class]]) {
                    [subview removeFromSuperview];
                }
            }
            [self loadPhoto];
        }
        else{
            [self showHint:ERRORREQUESTTIP];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (void)editAlbum:(UIBarButtonItem *)item
{
    NSLog(@"item = %@",item);
    isEditing = !isEditing;
    if (isEditing) {
        item.title = @"取消";
        deleteButton.hidden = NO;
        addButton.hidden = YES;
        NSArray *subviewArray = myScrollView.subviews;
        for (UIView *myview in subviewArray) {
            if ([myview isMemberOfClass:[HeAlbumImage class]]) {
                HeAlbumImage *albumImage = (HeAlbumImage *)myview;
                albumImage.selected = NO;
                albumImage.selectBox.selected = NO;
                albumImage.selectBox.hidden = NO;
            }
        }
    }
    else{
        NSArray *subviewArray = myScrollView.subviews;
        for (UIView *myview in subviewArray) {
            if ([myview isMemberOfClass:[HeAlbumImage class]]) {
                HeAlbumImage *albumImage = (HeAlbumImage *)myview;
                albumImage.selected = NO;
                albumImage.selectBox.selected = NO;
                albumImage.selectBox.hidden = YES;
            }
        }
        
        item.title = @"编辑";
        deleteButton.hidden = YES;
        addButton.hidden = NO;
    }
}

- (void)addPhotoView
{
    NSInteger number = [photoArray count];
    
    int row = [Tool getRowNumWithTotalNum:number withMaxRow:MAx_row MaxColumn:MAx_column];
    int column = [Tool getColumnNumWithTotalNum:number withMaxColumn:MAx_column];
    
    CGFloat buttonX = 5;
    CGFloat buttonW = 90;
    CGFloat buttonH = 90;
    CGFloat buttonY = 10;
    CGFloat buttonDistanceX = 10;
    CGFloat buttonDistanceY = 10;
    
    buttonW = (SCREENWIDTH - (MAx_column - 1) * buttonDistanceX - 2 * buttonX) / ((CGFloat)MAx_column);
    buttonH = buttonW;
    
    
    
    CGFloat hight = buttonY;
    for (int i = 0; i < row; i++) {
        
        if ((i + 1) * MAx_column <= number) {
            column = MAx_column;
        }
        else{
            column = number % MAx_column;
        }
        
        for (int j = 0; j < column; j++) {
            buttonX = 5 + j * buttonW + j * buttonDistanceX;
            buttonY = 10 + i * buttonH + i * buttonDistanceY;
            CGRect buttonFrame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            
            NSInteger index = i * MAx_column + j;
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,[photoArray objectAtIndex:index]];
            
            NSString *imageKey = imageUrl;
            HeAlbumImage *albumImage = [imageCache objectForKey:imageKey];
            if (albumImage == nil) {
                albumImage = [[HeAlbumImage alloc] initWithFrame:buttonFrame];
                albumImage.selected = NO;
                albumImage.selectBox.selected = NO;
                albumImage.selectBox.hidden = YES;
                albumImage.imageView.contentMode = UIViewContentModeScaleAspectFill;
                [albumImage.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
                albumImage.imageView.tag = index + 100;
                albumImage.tag = index + 200;
                
                albumImage.imageView.layer.cornerRadius = 5.0;
                albumImage.imageView.layer.masksToBounds = YES;
                albumImage.imageView.userInteractionEnabled = YES;
                albumImage.imageView.layer.borderColor = [UIColor clearColor].CGColor;
                albumImage.imageView.layer.borderWidth = 1.0;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImage:)];
                tap.numberOfTapsRequired = 1;
                tap.numberOfTouchesRequired = 1;
                [albumImage addGestureRecognizer:tap];
                [imageCache setObject:albumImage forKey:imageKey];
            }
            
            [myScrollView addSubview:albumImage];
            
            albumImage.imageView.userInteractionEnabled = YES;
            albumImage.userInteractionEnabled = YES;
            
            hight = albumImage.frame.origin.y + albumImage.frame.size.height + buttonDistanceY;
        }
    }
    if (hight < myScrollView.frame.size.height) {
        hight = myScrollView.frame.size.height;
    }
    myScrollView.contentSize = CGSizeMake(0, hight + 60);
}

-(void)onClickImage:(UITapGestureRecognizer *) tap
{
    HeAlbumImage *myview = (HeAlbumImage *)tap.view;
    if (isEditing) {
        myview.selectBox.hidden = NO;
        myview.selected = !myview.selected;
        myview.selectBox.selected = !myview.selectBox.selected;
        return;
    }
    
    NSMutableArray *photos = [NSMutableArray array];
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    for (NSInteger index = 0; index < photoArray.count; index++) {
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,[photoArray objectAtIndex:index]];
        HeAlbumImage *srcImageView = [myScrollView viewWithTag:index + 200];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageUrl];
        photo.srcImageView = srcImageView.imageView;
        [photos addObject:photo];
    }
    browser.photos = photos;
    browser.currentPhotoIndex = myview.tag - 200;
    [browser show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateUserAlbum" object:nil];
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
