//
//  YZHomePageFunctionItemView.m
//  ez
//
//  Created by 毛文豪 on 2018/1/31.
//  Copyright © 2018年 9ge. All rights reserved.
//

#import "YZHomePageFunctionItemView.h"
#import "YZLoginViewController.h"
#import "YZIntegralConversionViewController.h"
#import "YZInformationListViewController.h"
#import "YZRechargeListViewController.h"
#import "UIImageView+WebCache.h"

@interface YZHomePageFunctionItemView ()

@property (nonatomic, weak) UIImageView *logoImageView;//logo
@property (nonatomic, weak) UILabel *titleLabel;

@end

@implementation YZHomePageFunctionItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupChilds];
    }
    return self;
}

- (void)setupChilds
{
    //logo
    CGFloat logoWH = 27;
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.width - logoWH) / 2, 18, logoWH, logoWH)];
    self.logoImageView = logoImageView;
    [self addSubview:logoImageView];
    
    //玩法
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(logoImageView.frame) + 7, self.width, [UIFont systemFontOfSize:YZGetFontSize(24)].lineHeight)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
    titleLabel.textColor = YZBlackTextColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:titleLabel];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
    [self addGestureRecognizer:tap];
}

- (void)setFunctionModel:(YZHomePageFunctionModel *)functionModel
{
    _functionModel = functionModel;
    
    self.logoImageView.image = [UIImage imageNamed:_functionModel.iconName];
    self.titleLabel.text = _functionModel.name;
}

- (void)didTap:(UITapGestureRecognizer *)tap
{
    if ([self.functionModel.name isEqualToString:@"积分兑换"]) {//积分兑换
        [MBProgressHUD showError:@"本功能暂未上线" toView:KEY_WINDOW];
        return;
        
        if (!Token) {
            YZLoginViewController *login = [[YZLoginViewController alloc] init];
            YZNavigationController *nav = [[YZNavigationController alloc] initWithRootViewController:login];
            [self.viewController presentViewController:nav animated:YES completion:nil];
            return;
        }
        YZIntegralConversionViewController * integralConversionVC = [[YZIntegralConversionViewController alloc] init];
        [self.viewController.navigationController pushViewController:integralConversionVC animated:YES];
    }else if ([self.functionModel.name isEqualToString:@"点我充值"])//充值
    {
        if (!Token) {
            YZLoginViewController *login = [[YZLoginViewController alloc] init];
            YZNavigationController *nav = [[YZNavigationController alloc] initWithRootViewController:login];
            [self.viewController presentViewController:nav animated:YES completion:nil];
            return;
        }
        YZRechargeListViewController * rechargeVC = [[YZRechargeListViewController alloc] init];
        [self.viewController.navigationController pushViewController:rechargeVC animated:YES];
    }else if ([self.functionModel.name isEqualToString:@"预测推荐"])//预测推荐
    {
        YZInformationListViewController * informationListVC = [[YZInformationListViewController alloc] init];
        [self.viewController.navigationController pushViewController:informationListVC animated:YES];
    }else
    {
        [MBProgressHUD showError:@"本功能暂未上线" toView:KEY_WINDOW];
        return;
    }
}

@end
