//
//  HeContestDetailVC.m
//  beautyContest
//
//  Created by HeDongMing on 16/7/31.
//  Copyright © 2016年 iMac. All rights reserved.
//

#import "HeRecommendVC.h"
#import "MLLabel+Size.h"
#import "HeBaseTableViewCell.h"
#import "FLCollectionSeparator.h"
#import "HeGBoxCollectionCell.h"
#import "HeGBoxHeaderCollectionCell.h"
#import "AoiroSoraLayout.h"
#import "Recommend.h"
#import "RecommendCollectionViewCell.h"
#import "UIImage+MultiFormat.h"
#import "MJRefresh.h"
#import "UIScrollView+MJRefresh.h"
#import "BLImageSize.h"
#import "SDRefreshFooterView.h"
#import "SDRefreshHeaderView.h"
#import "HeDistributeRecommendVC.h"

#define TextLineHeight 1.2f
#define imageurl @"http://i1.15yan.guokr.cn/u0bk6rs5q79lnochkx3vj1ki18zjcobh.jpg!content"


#define HTTPURL @"http://apis.guokr.com/handpick/article.json?limit=%ld&ad=1&category=all&retrieve_type=by_since"

@interface HeRecommendVC ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,AoiroSoraLayoutDelegate>
{
    BOOL requestReply; //是否已经完成
    SDRefreshFooterView *refreshFooter;
    SDRefreshHeaderView *refreshHeader;
    
}
@property(strong,nonatomic)IBOutlet UICollectionView *recommendCollectionView;
@property(strong,nonatomic)NSArray *dataSource;
@property(strong,nonatomic)UIView *sectionHeaderView;
@property(strong,nonatomic)NSArray *iconDataSource;
@property (nonatomic,strong)NSMutableArray * heightArray;// 存储图片高度的数组
@property (nonatomic,strong)NSMutableArray * modelArray;// 存储图片高度的数组modelArray
@property (nonatomic,assign)NSInteger page; // 一次刷新的个数

@end

@implementation HeRecommendVC
@synthesize recommendCollectionView;
@synthesize sectionHeaderView;
@synthesize dataSource;
@synthesize iconDataSource;
@synthesize heightArray;
@synthesize modelArray;

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
        label.text = @"推荐";
        [label sizeToFit];
        
        self.title = @"推荐";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializaiton];
    [self initView];
    [self loadRecomendDataShow:YES];  // json 解析
    [self addHeader]; // 下拉刷新
    [self addFooter]; // 上拉刷新
}

- (void)initializaiton
{
    [super initializaiton];
    _page = 30;
    heightArray = [[NSMutableArray alloc] initWithCapacity:0];
    modelArray = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initView
{
    [super initView];
    AoiroSoraLayout * layout = [[AoiroSoraLayout alloc]init];
    layout.interSpace = 5; // 每个item 的间隔
    layout.edgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    layout.colNum = 2; // 列数;
    layout.delegate = self;
    
    recommendCollectionView.collectionViewLayout = layout;
    recommendCollectionView.delegate = self;
    recommendCollectionView.dataSource = self;
    recommendCollectionView.backgroundColor = [UIColor whiteColor];
    
    [recommendCollectionView registerClass:[RecommendCollectionViewCell class] forCellWithReuseIdentifier:@"RecommendCollectionViewCell"];
    
    sectionHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREENWIDTH, 40)];
    sectionHeaderView.backgroundColor = [UIColor colorWithWhite:237.0 / 255.0 alpha:1.0];
    sectionHeaderView.userInteractionEnabled = YES;
    
    UIButton *distributeButton = [[UIButton alloc] init];
    [distributeButton setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [distributeButton addTarget:self action:@selector(distributeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    distributeButton.frame = CGRectMake(0, 0, 25, 25);
    UIBarButtonItem *distributeItem = [[UIBarButtonItem alloc] initWithCustomView:distributeButton];
    distributeItem.target = self;
    self.navigationItem.rightBarButtonItem = distributeItem;
    
    
}

- (void)distributeButtonClick:(id)sender
{
    HeDistributeRecommendVC *distributeVC = [[HeDistributeRecommendVC alloc] init];
    distributeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:distributeVC animated:YES];
}
#pragma mark -- 下拉刷新
- (void)addHeader
{
    refreshHeader = [SDRefreshHeaderView refreshView];
    [refreshHeader addToScrollView:recommendCollectionView];
    [refreshHeader addTarget:self refreshAction:@selector(headerRefresh)];
//    __unsafe_unretained typeof(self) vc = self;
//    // 添加下拉刷新头部控件
//    [self.recommendCollectionView addHeaderWithCallback:^{
//        // 进入刷新状态就会调这个Block
//        
//        
//        // 模拟延迟加载数据,因此2秒后才调用
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            
//            // 结束刷新
//            [vc.recommendCollectionView headerEndRefreshing];
//        });
//    }];
//#pragma mark -- 自动刷新--进入程序就下拉刷新
//    [self.recommendCollectionView headerBeginRefreshing];
}

#pragma mark -- 上拉刷新
- (void)addFooter
{
    refreshFooter = [SDRefreshFooterView refreshView];
    [refreshFooter addToScrollView:recommendCollectionView];
    [refreshFooter addTarget:self refreshAction:@selector(footerRefresh)];
    
//    __unsafe_unretained typeof(self)vc = self;
//    // 添加上拉刷新尾部控件
//    [self.collectionView addFooterWithCallback:^{
//        // 添加刷新状态就会回调这个block
//        vc.page = vc.page + 10;
//        NSString * str = [NSString stringWithFormat:HTTPURL,(long)vc.page];
//        
//        NSURL * url = [NSURL URLWithString:str];
//        // 创建请求对象
//        NSURLRequest * request = [NSURLRequest requestWithURL:url];
//        // 发送请求
//        NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            
//            [vc.modelArray removeAllObjects];
//            [vc.heightArray removeAllObjects];
//            
//            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
//            
//            for (NSDictionary * d in [dict objectForKey:@"result"]) {
//                Recommend * m = [[Recommend alloc]init];
//                [m setValuesForKeysWithDictionary:d];
//                
//                [vc.modelArray addObject:m];
//                
//                [vc p_putImageWithURL:m.headline_img];
//            }
//            
//            // 模拟延迟加载数据,因此2秒后才调用
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//                // 判断图片高度数组的个数  是否已经全部计算完成
//                // 完成则结束刷新
//                if (vc.heightArray.count == vc.page) {
//                    [vc.collectionView reloadData];
//                    
//                    [vc.collectionView footerEndRefreshing];
//                }
//                
//            });
//            
//        }];
//        
//        [dataTask resume]; // 开始请求
//        
//    }];
    
    
}

- (void)headerRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshHeader endRefreshing];
        //        if (_totalPageCount == pageIndex) {
        //            return;
        //        }
        //        isNeedCleanOrder = NO;
        //        [self loadData];
    });
}

- (void)footerRefresh
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [refreshFooter endRefreshing];
//        if (_totalPageCount == pageIndex) {
//            return;
//        }
//        isNeedCleanOrder = NO;
//        [self loadData];
    });
}

#pragma mark -- json解析  初次加载

- (void)p_json
{
    NSString * str = [NSString stringWithFormat:HTTPURL,(long)_page];
    
    NSURL * url = [NSURL URLWithString:str];
    // 创建请求对象
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    // 发送请求
    NSURLSessionDataTask * dataTask = [[NSURLSession sharedSession]dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        
        if (!error) {
            
            NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            
            for (NSDictionary * d in [dict objectForKey:@"result"]) {
                Recommend * m = [[Recommend alloc]init];
                [m setValuesForKeysWithDictionary:d];
                
                [self.modelArray addObject:m];
                
                [self p_putImageWithURL:m.headline_img];
                
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [recommendCollectionView reloadData];
        });
        
        
    }];
    
    [dataTask resume]; // 开始请求
}

- (void)loadRecomendDataShow:(BOOL)show
{
    NSString * requestRecommendDataPath = [NSString stringWithFormat:@"%@/recommend/showwaterfallflow.action",BASEURL];
    NSDictionary *param = @{@"1":@"1"};
    if (show) {
        [self showHudInView:self.recommendCollectionView hint:@"加载中..."];
    }
    [AFHttpTool requestWihtMethod:RequestMethodTypePost url:requestRecommendDataPath params:param success:^(AFHTTPRequestOperation* operation,id response){
        [self hideHud];
        if (show) {
            
            [Waiting dismiss];
        }
        NSString *respondString = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        NSDictionary *respondDict = [respondString objectFromJSONString];
        NSInteger errorCode = [[respondDict objectForKey:@"errorCode"] integerValue];
        if (errorCode == REQUESTCODE_SUCCEED) {
            NSArray *recommendArray = [respondDict objectForKey:@"json"];
            if ([recommendArray isKindOfClass:[NSArray class]]) {
                for (NSDictionary * d in recommendArray) {
                    
                    Recommend * m = [[Recommend alloc]init];
                    NSString *recommendCover = [d objectForKey:@"recommendCover"];
                    if ([recommendCover isMemberOfClass:[NSNull class]] || recommendCover == nil) {
                        recommendCover = @"";
                    }
                    recommendCover = [NSString stringWithFormat:@"%@/%@",HYTIMAGEURL,recommendCover];
                    m.headline_img = recommendCover;
//                    [m setValuesForKeysWithDictionary:d];
                    
                    [self.modelArray addObject:m];
                    NSLog(@"recommendCover = %@",recommendCover);
                    [self p_putImageWithURL:m.headline_img];
                    
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [recommendCollectionView reloadData];
                });
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
        [self hideHud];
        if (show) {
            [Waiting dismiss];
        }
        [self showHint:ERRORREQUESTTIP];
    }];
}


#pragma mark -- 获取 图片 和 图片的比例高度
- (void)p_putImageWithURL:(NSString *)url
{
    // 获取图片
    
    CGSize  size = CGSizeZero;
//    [BLImageSize dowmLoadImageSizeWithURL:url];
    
    // 获取图片的高度并按比例压缩
    NSInteger itemHeight = size.height * (((self.view.frame.size.width - 20) / 2 / size.width));
    if (itemHeight == 0) {
        itemHeight = (arc4random() % 51) + 50;
    }
    itemHeight = itemHeight + (arc4random() % 51);
    itemHeight = itemHeight + (arc4random() % 51);
    itemHeight = itemHeight + (arc4random() % 51);
    
    NSNumber * number = [NSNumber numberWithInteger:itemHeight];
    
    [self.heightArray addObject:number];
    
}

#pragma mark -- 返回每个item的高度
- (CGFloat)itemHeightLayOut:(AoiroSoraLayout *)layOut indexPath:(NSIndexPath *)indexPath
{
    
    if ([self.heightArray[indexPath.row] integerValue] < 0 || !self.heightArray[indexPath.row]) {
        
        return 150;
    }
    else
    {
        NSInteger intger = [self.heightArray[indexPath.row] integerValue];
        return intger;
    }
    
}

#pragma mark -- collectionView 的分组个数
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

#pragma mark -- item 的个数
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.modelArray.count;
}
#pragma mark -- cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RecommendCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"RecommendCollectionViewCell" forIndexPath:indexPath];
    
    cell.model = self.modelArray[indexPath.row];
    
    
    
    // jiazai shibai chongxin jiazai
    Recommend * model = self.modelArray[indexPath.row];
    if ([model.headline_img isEqualToString:imageurl]) {
        cell.MyImage.image = [UIImage sd_imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:model.headline_img]]];
    }
    
    return cell;
}



#pragma mark -- 选中某个cell
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"第 %ld 个cell",(long)indexPath.row);
    Recommend * model = self.modelArray[indexPath.row];
    NSLog(@"%@",model.headline_img);
}

#pragma mark --UICollectionViewDelegate
//UICollectionView被选中时调用的方法

-(BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    if (section == 1) {
        return YES;
    }
    return NO;
}

//放大缩小效果
-(void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.2 animations:^{
        selectedCell.transform = CGAffineTransformMakeScale(2.0f, 2.0f);
    }];
}

-(void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *selectedCell = [collectionView cellForItemAtIndexPath:indexPath];
    [UIView animateWithDuration:0.2 animations:^{
        selectedCell.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    }];
}

//返回这个UICollectionView是否可以被选择
-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;

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
