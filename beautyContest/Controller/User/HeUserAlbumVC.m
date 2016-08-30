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

#define MAx_row 100000
#define MAx_column 3

@interface HeUserAlbumVC ()
@property(strong,nonatomic)UIScrollView *myScrollView;
@property(strong,nonatomic)NSMutableArray *photoArray;
@property(strong,nonatomic)IBOutlet UIButton *addButton;

@end

@implementation HeUserAlbumVC
@synthesize myScrollView;
@synthesize photoArray;
@synthesize addButton;

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
}

- (void)initView
{
    [super initView];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] init];
    editItem.title = @"编辑";
    editItem.target = self;
    editItem.action = @selector(editAlbum:);
    self.navigationItem.rightBarButtonItem = editItem;
    
    self.view.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    CGFloat viewX = 10;
    CGFloat viewY = 10;
    CGFloat viewW = SCREENWIDTH - 2 * viewX;
    CGFloat viewH = SCREENHEIGH - 2 * viewY - 50;
    myScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(viewX, viewY, viewW, viewH)];
    [self.view addSubview:myScrollView];
    
    [addButton dangerStyle];
    addButton.layer.borderColor = [UIColor clearColor].CGColor;
    [addButton setBackgroundImage:[Tool buttonImageFromColor:APPDEFAULTORANGE withImageSize:addButton.frame.size] forState:UIControlStateNormal];
    addButton.layer.masksToBounds = YES;
    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    addButton.layer.cornerRadius = 3.0;
    
}

- (void)loadPhoto
{
    NSString *requestWorkingTaskPath = [NSString stringWithFormat:@"%@/paperWall/selectPaperWall.action",BASEURL];
    
    NSString *userid = [[NSUserDefaults standardUserDefaults] objectForKey:USERIDKEY];
    if (!userid) {
        userid = @"";
    }
    NSDictionary *requestMessageParams = @{@"userId":userid};
    [self showHudInView:self.view hint:@"正在获取..."];
    
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestWorkingTaskPath params:requestMessageParams success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger statueCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        
        if (statueCode == REQUESTCODE_SUCCEED){
            NSDictionary *jsonDict = [respondDict objectForKey:@"json"];
            NSString *wallUrl = [jsonDict objectForKey:@"wallUrl"];
            NSArray *myArray = [wallUrl componentsSeparatedByString:@","];
            photoArray = [[NSMutableArray alloc] initWithArray:myArray];
            [self addPhotoView];
        }
        else{
            [self showHint:ERRORREQUESTTIP];
        }
    } failure:^(NSError *error){
        [self showHint:ERRORREQUESTTIP];
    }];
}

- (IBAction)addButtonClick:(id)sender
{

}

- (void)editAlbum:(UIBarButtonItem *)item
{
    NSLog(@"item = %@",item);
}

- (void)addPhotoView
{
    NSInteger number = [photoArray count];
    
    int row = [Tool getRowNumWithTotalNum:number withMaxRow:MAx_row MaxColumn:MAx_column];
    int column = [Tool getColumnNumWithTotalNum:number withMaxColumn:MAx_column];
    
    CGFloat buttonX = 10;
    CGFloat buttonW = 90;
    CGFloat buttonH = 90;
    CGFloat buttonY = 10;
    CGFloat buttonDistanceX = (SCREENWIDTH - MAx_column * buttonW - 2 * buttonX) / ((CGFloat)(MAx_column - 1));
    CGFloat buttonDistanceY = 10;
    CGFloat hight = buttonY;
    for (int i = 0; i < row; i++) {
        
        if ((i + 1) * MAx_column <= number) {
            column = MAx_column;
        }
        else{
            column = number % MAx_column;
        }
        
        for (int j = 0; j < column; j++) {
            buttonX = 10 + j * buttonW + j * buttonDistanceX;
            buttonY = 10 + i * buttonH + i * buttonDistanceY;
            CGRect buttonFrame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
            
            NSInteger index = i * 3 + j;
            NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,[photoArray objectAtIndex:index]];
            
            UIImageView *imageview = [[UIImageView alloc] init];
            imageview.contentMode = UIViewContentModeScaleAspectFill;
            [imageview sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"comonDefaultImage"]];
            imageview.tag = index + 100;
            imageview.frame = buttonFrame;
            imageview.layer.cornerRadius = 5.0;
            imageview.layer.masksToBounds = YES;
            imageview.layer.borderColor = [UIColor clearColor].CGColor;
            imageview.layer.borderWidth = 1.0;
            [myScrollView addSubview:imageview];
            
            imageview.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClickImage:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [imageview addGestureRecognizer:tap];
            
            hight = imageview.frame.origin.y + imageview.frame.size.height + buttonDistanceY;
        }
    }
    if (hight > myScrollView.frame.size.height) {
        myScrollView.contentSize = CGSizeMake(0, hight + 10);
    }
}

-(void)onClickImage:(UITapGestureRecognizer *) tap
{
    UIView *myview = tap.view;
    NSMutableArray *photos = [NSMutableArray array];
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    for (NSInteger index = 0; index < photoArray.count; index++) {
        
        NSString *imageUrl = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,[photoArray objectAtIndex:index]];
        UIImageView *srcImageView = [myScrollView viewWithTag:index + 100];
        
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageUrl];
        photo.srcImageView = srcImageView;
        [photos addObject:photo];
    }
    browser.photos = photos;
    browser.currentPhotoIndex = myview.tag - 100;
    [browser show];
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
