//
//  YZShopInfoViewController.m
//  zc
//
//  Created by dahe on 2020/3/31.
//  Copyright © 2020 9ge. All rights reserved.
//

#import "YZShopInfoViewController.h"

@interface YZShopInfoViewController ()

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *phoneLabel;
@property (nonatomic, weak) UILabel *addressLabel;
@property (nonatomic, weak) UIImageView *erCodeImageView;

@end

@implementation YZShopInfoViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = [UIColor whiteColor];
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
    [navBar setTitleTextAttributes:textAttrs];
    [navBar setBackgroundImage:[UIImage ImageFromColor:YZColor(249, 96, 66, 1)] forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = [UIImage new];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    UINavigationBar *navBar = self.navigationController.navigationBar;
    navBar.tintColor = YZBlackTextColor;
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = YZBlackTextColor;
    [navBar setTitleTextAttributes:textAttrs];
    [navBar setBackgroundImage:[UIImage ImageFromColor:[UIColor whiteColor] WithRect:CGRectMake(0, 0, screenWidth, statusBarH + navBarH)] forBarMetrics:UIBarMetricsDefault];
    navBar.shadowImage = nil;
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleDefault;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = YZColor(249, 96, 66, 1);
    self.title = @"店铺二维码";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //内容
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(YZMargin, YZMargin, screenWidth - 2 * YZMargin, 450)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    [self.view addSubview:contentView];
    
    //顶部 店铺信息
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.width, 120)];
    topView.backgroundColor = YZColor(246, 246, 246, 1);
    [contentView addSubview:topView];
    
    //头像
    UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 60, 60)];
    self.avatarImageView = avatarImageView;
    avatarImageView.image = [UIImage imageNamed:@"avatar_zc"];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    [topView addSubview:avatarImageView];
    
    for (int i = 0; i < 2; i++) {
        UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 10, 20 + (17 + 13) * i, 17, 17)];
        if (i == 0) {
            iconImageView.image = [UIImage imageNamed:@"shop_phone_icon"];
        }else
        {
            iconImageView.image = [UIImage imageNamed:@"shop_address_icon"];
        }
        [topView addSubview:iconImageView];
        
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(iconImageView.frame) + 5, iconImageView.y, topView.width - (CGRectGetMaxX(iconImageView.frame) + 5), 17)];
        if (i == 0)
        {
            self.phoneLabel = label;
            label.text = @"123*****123";
        }else
        {
            self.addressLabel = label;
            label.text = @"河南省洛阳市******";
        }
        label.textColor = YZBlackTextColor;
        label.font = [UIFont systemFontOfSize:YZGetFontSize(30)];
        [topView addSubview:label];
    }
    
    UILabel * payLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 10, CGRectGetMaxY(self.addressLabel.frame) + 13, 80, 20)];
    payLabel.text = @"本店支持：";
    payLabel.textColor = YZDrayGrayTextColor;
    payLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    [topView addSubview:payLabel];
    
    for (int i = 0; i < 3; i++) {
        UIImageView *payImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(payLabel.frame) + (20 + 5) * i, payLabel.y, 20, 20)];
        if (i == 0) {
            payImageView.image = [UIImage imageNamed:@"shop_weixin_icon"];
        }else if (i == 1)
        {
            payImageView.image = [UIImage imageNamed:@"shop_alipay_icon"];
        }else if (i == 2)
        {
            payImageView.image = [UIImage imageNamed:@"shop_yun_icon"];
        }
        [topView addSubview:payImageView];
    }
    
    //二维码
    UILabel *erCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZMargin, CGRectGetMaxY(topView.frame) + 30, contentView.width - 2 * YZMargin, 20)];
    erCodeLabel.text = @"扫一扫二维码，立即购彩";
    erCodeLabel.textAlignment = NSTextAlignmentCenter;
    erCodeLabel.textColor = YZDrayGrayTextColor;
    erCodeLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    [contentView addSubview:erCodeLabel];
    
    CGFloat erCodeImageViewWH = 160;
    UIImageView *erCodeImageView = [[UIImageView alloc] initWithFrame:CGRectMake((contentView.width - erCodeImageViewWH) / 2, CGRectGetMaxY(erCodeLabel.frame) + 10, erCodeImageViewWH, erCodeImageViewWH)];
    self.erCodeImageView = erCodeImageView;
    erCodeImageView.backgroundColor = YZColor(247, 246, 251, 1);
    [contentView addSubview:erCodeImageView];
    
    //按钮
    CGFloat buttonW = 118;
    CGFloat buttonH = 33;
    CGFloat buttonPadding = (contentView.width - 2 * buttonW) / 3;
    for (int i = 0; i < 2; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(buttonPadding + (buttonPadding + buttonW) * i, CGRectGetMaxY(erCodeImageView.frame) + 40, buttonW, buttonH);
        if (i == 0) {
            [button setBackgroundImage:[UIImage imageNamed:@"shop_share_btn"] forState:UIControlStateNormal];
        }else
        {
            [button setBackgroundImage:[UIImage imageNamed:@"shop_save_erCode_btn"] forState:UIControlStateNormal];
        }
        [button addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [contentView addSubview:button];
    }
}

- (void)buttonDidClick:(UIButton *)button
{
    
}

@end
