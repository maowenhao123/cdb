//
//  YZBuyLotteryCollectionView.m
//  ez
//
//  Created by apple on 16/10/9.
//  Copyright © 2016年 9ge. All rights reserved.
//
#define bannerCellId @"BuyLotteryCollectionViewBannerCellId"
#define functionCellId @"HomePageFunctionCollectionViewCellId"
#define gameInfoCellId @"BuyLotteryCollectionViewGameInfoCellId"

#define bannerH 180
#define cellH 90
#import "YZBuyLotteryCollectionView.h"
#import "YZGameIdViewController.h"
#import "YZInitiateUnionBuyViewController.h"
#import "YZBannerCollectionViewCell.h"
#import "YZHomePageFunctionCollectionViewCell.h"
#import "YZBuyLotteryCollectionViewCell.h"

@interface YZBuyLotteryCollectionView ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) int pageIndex;
@property (nonatomic,strong) NSArray *functions;
@property (nonatomic, strong) NSArray *cycleDatas;
@property (nonatomic, strong) NSArray *gameInfos;
@property (nonatomic, strong) NSMutableArray *informations;
@property (nonatomic, weak) MJRefreshBackGifFooter *footer;

@end

@implementation YZBuyLotteryCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
        [self registerClass];
        [MBProgressHUD showMessage:@"获取数据，客官请稍后..." toView:self];
        [self getFunctionData];
        [self getGameInfoDataWith:nil];;
    }
    return self;
}

#pragma mark - 注册
- (void)registerClass
{
    [self registerClass:[YZBannerCollectionViewCell class] forCellWithReuseIdentifier:bannerCellId];
    [self registerClass:[YZHomePageFunctionCollectionViewCell class] forCellWithReuseIdentifier:functionCellId];
    [self registerClass:[YZBuyLotteryCollectionViewCell class] forCellWithReuseIdentifier:gameInfoCellId];
}
#pragma mark - 获取数据
- (void)headerRefreshViewBeginRefreshingWith:(MJRefreshGifHeader *)header
{
    self.pageIndex = 0;
    //轮播图
    YZBannerCollectionViewCell * bannerCollectionViewCell = (YZBannerCollectionViewCell * )[self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    [bannerCollectionViewCell getDataWith:header];
    [self getFunctionData];
    [self getGameInfoDataWith:header];
}

- (void)getFunctionData
{
    NSMutableArray * functions_mu = [NSMutableArray array];
    for (int i = 0; i < 4; i++) {
        YZHomePageFunctionModel *functionModel = [[YZHomePageFunctionModel alloc] init];
        if (i == 0) {
            functionModel.iconName = @"home_recharge";
            functionModel.name = @"点我充值";
        }else if (i == 1)
        {
            functionModel.iconName = @"home_integral_conversion";
            functionModel.name = @"积分兑换";
        }else if (i == 2)
        {
            functionModel.iconName = @"home_forecast";
            functionModel.name = @"预测推荐";
        }else if (i == 3)
        {
            functionModel.iconName = @"home_live";
            functionModel.name = @"视频直播";
        }
        [functions_mu addObject:functionModel];
    }
    self.functions = [NSArray arrayWithArray:functions_mu];
    [UIView performWithoutAnimation:^{
        [self reloadSections:[NSIndexSet indexSetWithIndex:1]];
    }];
}

//获取彩种信息数据
- (void)getGameInfoDataWith:(MJRefreshGifHeader *)header
{
    NSDictionary *dict = @{
                           @"storeId":StoreId,
                           };
    [[YZHttpTool shareInstance] postWithURL:@"/getGameList" params:dict success:^(id json) {
        [MBProgressHUD hideHUDForView:self];
        [header endRefreshing];
        YZLog(@"gameInfo:%@",json);
        if (SUCCESS){
            self.gameInfos = [YZBuyLotteryCellStatus objectArrayWithKeyValuesArray:json[@"game"]];
            [UIView performWithoutAnimation:^{
                [self reloadSections:[NSIndexSet indexSetWithIndex:2]];
            }];
        }else
        {
            self.gameInfos = [self getDefaultGameInfos];
            [UIView performWithoutAnimation:^{
                [self reloadSections:[NSIndexSet indexSetWithIndex:2]];
            }];
        }
    }failure:^(NSError *error)
    {
         [MBProgressHUD hideHUDForView:self];
         [header endRefreshing];
         self.gameInfos = [self getDefaultGameInfos];
         [UIView performWithoutAnimation:^{
            [self reloadSections:[NSIndexSet indexSetWithIndex:2]];
         }];
         YZLog(@"error = %@",error);
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 2 && !YZArrayIsEmpty(self.informations)) {
        return CGSizeMake(screenWidth, 10 + 40);
    }
    return CGSizeZero;
}

//配置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return CGSizeMake(self.width, bannerH);
    }else if (indexPath.section == 1)
    {
        return CGSizeMake(self.width, 84);
    }else if (indexPath.section == 2)
    {
        return CGSizeMake(self.width / 2, cellH);
    }
    return CGSizeMake(self.width, 0);
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 3;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 2) {
        return self.gameInfos.count;
    }
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        YZBannerCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bannerCellId forIndexPath:indexPath];
        return cell;
    }else if (indexPath.section == 1)
    {
        YZHomePageFunctionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:functionCellId forIndexPath:indexPath];
        cell.functions = self.functions;
        return cell;
    }else if (indexPath.section == 2)
    {
        YZBuyLotteryCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:gameInfoCellId forIndexPath:indexPath];
        cell.status = self.gameInfos[indexPath.row];
        if (indexPath.row % 2 == 0) {
            cell.line2.hidden = NO;
        }else
        {
            cell.line2.hidden = YES;
        }
        return cell;
    }
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2)
    {
        YZBuyLotteryCellStatus * status = self.gameInfos[indexPath.row];
        if ([status.gameId isEqualToString:@"UNIONPLAN"]) {
            YZInitiateUnionBuyViewController *initiateUnionBuyVC = [[YZInitiateUnionBuyViewController alloc] init];
            [self.viewController.navigationController pushViewController:initiateUnionBuyVC animated:YES];
        }else
        {
            YZGameIdViewController *destVc = (YZGameIdViewController *)[[[YZTool gameDestClassDict][status.gameId] alloc] initWithGameId:status.gameId];
            [self.viewController.navigationController pushViewController:destVc animated:YES];
        }
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 2)
    {
        return YES;
    }
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{    
    if (_buyLotteryDelegate && [_buyLotteryDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [_buyLotteryDelegate scrollViewDidScroll:self];
    }
}

#pragma mark - 初始化
- (NSArray *)functions
{
    if (_functions == nil) {
        _functions = [NSArray array];
    }
    return _functions;
}

- (NSArray *)cycleDatas
{
    if (_cycleDatas == nil) {
        _cycleDatas = [NSArray array];
    }
    return _cycleDatas;
}

- (NSArray *)gameInfos
{
    if (_gameInfos == nil) {
        _gameInfos = [NSArray array];
    }
    return _gameInfos;
}

- (NSMutableArray *)informations
{
    if (_informations == nil) {
        _informations = [NSMutableArray array];
    }
    return _informations;
}

#pragma mark - 默认数据
- (NSArray *)getDefaultGameInfos
{
    NSArray * gameInfos = [NSArray array];
    NSError*error;
    //获取文件路径
    NSString *filePath = [[NSBundle mainBundle]pathForResource:@"default_lottery"ofType:nil];
    //根据文件路径读取数据
    NSData *jdata = [[NSData alloc]initWithContentsOfFile:filePath];
    //格式化成json数据
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jdata options:kNilOptions error:&error];
    gameInfos = [YZBuyLotteryCellStatus objectArrayWithKeyValuesArray:jsonObject[@"pages"]];
    return gameInfos;
}

@end
