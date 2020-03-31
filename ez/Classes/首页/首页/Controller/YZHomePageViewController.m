//
//  YZHomePageViewController.m
//  ez
//
//  Created by apple on 16/9/27.
//  Copyright © 2016年 9ge. All rights reserved.
//
#import "YZHomePageViewController.h"
#import "YZGameIdViewController.h"
#import "YZMessageViewController.h"
#import "YZLoginViewController.h"
#import "YZNavigationController.h"
#import "YZBuyLotteryCollectionView.h"
#import "YZCustomerServiceViewController.h"
#import "YZServiceListViewController.h"
#import "YZShopInfoViewController.h"

@interface YZHomePageViewController ()<YZBuyLotteryCollectionViewDelegate>

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *signLabel;
@property (nonatomic, strong) UIBarButtonItem * messageBarButtonItem;
@property (nonatomic, weak) YZBuyLotteryCollectionView *buyLotteryCollectionView;
@property (nonatomic, weak) MJRefreshGifHeader *header;

@end

@implementation YZHomePageViewController

#pragma mark - 控制器的生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupChilds];
    [self getMessageCount];
    if (@available(iOS 11.0, *)) {
        self.buyLotteryCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else
    {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    //接收刷新是否有新消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageCount) name:@"upDataHaveNewMessage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMessageCount) name:loginSuccessNote object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(headerRefreshViewBeginRefreshing) name:loginSuccessNote object:nil];
}

- (void)setupChilds
{
    //顶部nav
    UIView * navView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, statusBarH + 60)];
    navView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navView];
    
    //头像
    UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(YZMargin, statusBarH + 5, 45, 45)];
    self.avatarImageView = avatarImageView;
    avatarImageView.image = [UIImage imageNamed:@"avatar_zc"];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [navView addSubview:avatarImageView];
    
    //店铺名
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 5, statusBarH + 5, navView.width - (CGRectGetMaxX(avatarImageView.frame) + 5) - 120, 28)];
    self.nameLabel = nameLabel;
    nameLabel.text = @"中彩啦投注站";
    nameLabel.textColor = YZBlackTextColor;
    nameLabel.font = [UIFont boldSystemFontOfSize:YZGetFontSize(35)];
    [navView addSubview:nameLabel];
    
    //签名
    UILabel * signLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 5, CGRectGetMaxY(nameLabel.frame), navView.width - (CGRectGetMaxX(avatarImageView.frame) + 5) - 10, 20)];
    self.signLabel = signLabel;
    signLabel.text = @"公告：本店充值优惠，充100返5元";
    signLabel.textColor = YZGrayTextColor;
    signLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
    [navView addSubview:signLabel];
    
    //按钮
    CGFloat navButtonWH = 22;
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(navView.width - 5 - (navButtonWH + 10) * (i + 1), statusBarH + 7, navButtonWH, navButtonWH);
        if (i == 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"home_shop_chat"] forState:UIControlStateNormal];
        }else if (i == 1)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"home_shop_phone"] forState:UIControlStateNormal];
        }else if (i == 2)
        {
            [button setBackgroundImage:[UIImage imageNamed:@"home_shop_erCode"] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(navButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:button];
    }

    //内容CollectionView
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    layout.minimumInteritemSpacing = 0.0;//列间距
    layout.minimumLineSpacing = 0.0;//行间距
    
     YZBuyLotteryCollectionView *buyLotteryCollectionView = [[YZBuyLotteryCollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(navView.frame), screenWidth, screenHeight - CGRectGetMaxY(navView.frame) - tabBarH) collectionViewLayout:layout];
    self.buyLotteryCollectionView = buyLotteryCollectionView;
    buyLotteryCollectionView.buyLotteryDelegate = self;
    [self.view addSubview:buyLotteryCollectionView];

    //初始化头部刷新控件
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    [YZTool setRefreshHeaderGif:header];
    self.header= header;
    buyLotteryCollectionView.mj_header = header;
}

- (void)navButtonDidClick:(UIButton *)button
{
    if (button.tag == 0) {
        if (!UserId) {
            YZLoginViewController *login = [[YZLoginViewController alloc] init];
            YZNavigationController *nav = [[YZNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
            return;
        }
        YZMessageViewController * messageVC = [[YZMessageViewController alloc] init];
        [self.navigationController pushViewController:messageVC animated:YES];
    }else if (button.tag == 1)
    {
        if (!UserId) {
            YZLoginViewController *login = [[YZLoginViewController alloc] init];
            YZNavigationController *nav = [[YZNavigationController alloc] initWithRootViewController:login];
            [self presentViewController:nav animated:YES completion:nil];
            return;
        }
        YZServiceListViewController * contactServiceVC = [[YZServiceListViewController alloc]init];
        [self.navigationController pushViewController:contactServiceVC animated:YES];
    }else if (button.tag == 2)
    {
        YZShopInfoViewController * shopInfoVC = [[YZShopInfoViewController alloc]init];
        [self.navigationController pushViewController:shopInfoVC animated:YES];
    }
}

- (void)headerRefreshViewBeginRefreshing
{
    [self.buyLotteryCollectionView headerRefreshViewBeginRefreshingWith:self.header];
}

#pragma mark - message
- (void)getMessageCount
{
    if (!UserId) {
        return;
    }
    NSDictionary *dict = @{
                           @"userId":UserId
                           };
    [[YZHttpTool shareInstance] postWithURL:BaseUrlJiguang(@"/countUnRead") params:dict success:^(id json) {
        YZLog(@"countUnReadMessage:%@",json);
        if (SUCCESS) {
            int countUnReadMessage = [json[@"count"] intValue];
            UIImage * message_bar = [UIImage imageNamed:@"black_message_bar"];
            if (countUnReadMessage > 0) {//有消息
                UIImage * message_bar_none = [UIImage ImageFromColor:[UIColor clearColor] WithRect:CGRectMake(0, 0, 20, 20)];
                NSArray *images = @[message_bar, message_bar_none];
                self.messageBarButtonItem.image = [UIImage animatedImageWithImages:images duration:1];
            }else
            {
                self.messageBarButtonItem.image = message_bar;
            }
        }
    } failure:^(NSError *error)
    {
        YZLog(@"error = %@",error);
    }];
}

@end
