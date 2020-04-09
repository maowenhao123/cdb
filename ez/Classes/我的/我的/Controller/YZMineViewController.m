//
//  YZMineViewController.m
//  ez
//
//  Created by 毛文豪 on 2017/9/27.
//  Copyright © 2017年 9ge. All rights reserved.
//

#import "YZMineViewController.h"
#import "YZMineSettingViewController.h"
#import "YZAccountInfoViewController.h"
#import "YZMoneyDetailViewController.h"
#import "YZRechargeRecordViewController.h"
#import "YZWithdrawalRecordViewController.h"
#import "YZWithdrawalViewController.h"
#import "YZRechargeListViewController.h"
#import "YZVoucherViewController.h"
#import "YZMessageViewController.h"
#import "YZLoadHtmlFileController.h"
#import "YZServiceListViewController.h"
#import "YZShareProfitsViewController.h"
#import "YZShopInfoViewController.h"
#import "YZThirdPartyStatus.h"
#import "YZAddImageManage.h"
#import "UIImageView+WebCache.h"
#import "UIButton+YZ.h"

@interface YZMineViewController ()<AddImageManageDelegate>

@property (nonatomic, weak) UIView * guideView;
@property (nonatomic, weak) UIScrollView * scrollView;
@property (nonatomic,weak)  UIImageView *avatarImageView;
@property (nonatomic,weak) UILabel * nickNameLabel;
@property (nonatomic, weak) UILabel * nameCertificationLabel;
@property (nonatomic, weak) UIView *line1;
@property (nonatomic, weak) UILabel * phoneBindingLabel;
@property (nonatomic, strong) NSMutableArray *moneyDetailbtns;
@property (nonatomic, weak) UIButton * rechargeButton;
@property (nonatomic, weak) UIButton * withdrawalButton;
@property (nonatomic, weak) UIButton * voucheButton;
@property (nonatomic,strong) YZUser *user;
@property (nonatomic, weak) MJRefreshGifHeader *header;
@property (nonatomic, strong) YZAddImageManage * addImageManage;

@end

@implementation YZMineViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self loadUserInfo];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = YZBackgroundColor;
    [self setupChilds];
    [self addGuideView];
    waitingView_loadingData;
}

#pragma mark - 请求数据
//断网状态下，此方法必须实现
- (void)noNetReloadRequest
{
    [self loadUserInfo];
}

- (void)loadUserInfo
{
    if (!Token)
    {
        [MBProgressHUD hideHUDForView:self.view];
        [self.header endRefreshing];
        return;
    }
    NSDictionary *dict = @{
                           @"token" : Token
                           };
    [[YZHttpTool shareInstance] postWithURL:@"/getUserInfo" params:dict success:^(id json) {
        YZLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        [self.header endRefreshing];
        if (SUCCESS) {
            //存储用户信息
            YZUser *user = [YZUser objectWithKeyValues:json];
            self.user = user;
            [YZUserDefaultTool saveUser:user];
            [self getMessageCount];
        }else
        {
            ShowErrorView;
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.header endRefreshing];
        YZLog(@"账户error");
    }];
}

- (void)getMessageCount
{
    if (!Token)
    {
        return;
    }
    NSDictionary *dict = @{
                           };
    [[YZHttpTool shareInstance] postWithURL:BaseUrlJiguang(@"/countUnRead") params:dict success:^(id json) {
        if (SUCCESS) {
            int countUnReadMessage = [json[@"count"] intValue];
            NSLog(@"%d", countUnReadMessage);
        }
    } failure:^(NSError *error)
     {
         YZLog(@"error = %@",error);
     }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //设置按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"mine_setting_icon"] style:UIBarButtonItemStylePlain target:self action:@selector(settingBarClick)];
    
    UIScrollView * scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - tabBarH - statusBarH - navBarH)];
    self.scrollView = scrollView;
    [self.view addSubview:scrollView];
    
    //个人信息
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 110)];
    topView.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:topView];
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mineBackViewClick)];
    [topView addGestureRecognizer:tap];
    
    //头像
    UIImageView *avatarImageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 70, 70)];
    self.avatarImageView = avatarImageView;
    avatarImageView.image = [UIImage imageNamed:@"avatar_zc"];
    avatarImageView.layer.masksToBounds = YES;
    avatarImageView.layer.cornerRadius = avatarImageView.width / 2;
    avatarImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer * chooseAvatarTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chooseAvatarDidClick)];
    [avatarImageView addGestureRecognizer:chooseAvatarTap];
    [topView addSubview:avatarImageView];
    
    //昵称
    UILabel * nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 10, 30, screenWidth - (CGRectGetMaxX(avatarImageView.frame) + 10), 30)];
    self.nickNameLabel = nickNameLabel;
    nickNameLabel.text = @"昵称";
    nickNameLabel.textColor = [UIColor blackColor];
    nickNameLabel.font = [UIFont systemFontOfSize:YZGetFontSize(32)];
    [topView addSubview:nickNameLabel];
    
    //实名认证
    UILabel * nameCertificationLabel = [[UILabel alloc] init];
    self.nameCertificationLabel = nameCertificationLabel;
    nameCertificationLabel.textColor = YZDrayGrayTextColor;
    nameCertificationLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    [topView addSubview:nameCertificationLabel];
    
    //分割线1
    UIView * line1 = [[UIView alloc] init];
    self.line1 = line1;
    line1.backgroundColor = YZWhiteLineColor;
    [topView addSubview:line1];
    
    //手机绑定信息
    UILabel * phoneBindingLabel = [[UILabel alloc] init];
    self.phoneBindingLabel = phoneBindingLabel;
    phoneBindingLabel.textColor = YZDrayGrayTextColor;
    phoneBindingLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    [topView addSubview:phoneBindingLabel];
    
    //账户金额
    CGFloat moneyDetailViewW = screenWidth * 0.94;
    CGFloat moneyDetailViewH = (moneyDetailViewW * 122 / 703);
    CGFloat moneyDetailViewX = (screenWidth - moneyDetailViewW) / 2;
    UIImageView * moneyDetailView = [[UIImageView alloc] initWithFrame:CGRectMake(moneyDetailViewX, CGRectGetMaxY(topView.frame) + YZMargin, moneyDetailViewW, moneyDetailViewH)];
    moneyDetailView.image = [UIImage imageNamed:@"mine_money_bg"];
    moneyDetailView.userInteractionEnabled = YES;
    [scrollView addSubview:moneyDetailView];
    
    CGFloat moneyDetailBtnY = 0;
    CGFloat moneyDetailBtnH = moneyDetailView.height;
    CGFloat lineH = 20;
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(moneyDetailView.width * i / 3, moneyDetailBtnY, moneyDetailView.width / 3, moneyDetailBtnH);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.numberOfLines = 2;
        [button addTarget:self action:@selector(moneyDetailButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [moneyDetailView addSubview:button];
        [self.moneyDetailbtns addObject:button];
        if (i != 2) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(moneyDetailView.width / 3 - 1, (moneyDetailBtnH - lineH) / 2, 1, lineH)];
            line.backgroundColor = YZColor(226, 183, 140, 1);
            [button addSubview:line];
        }
    }
    [self setMoneyButtonTitleByBalance:@"0元" bonus:@"0元" grade:@"0"];
    
    //我的钱包
    UIView * walletView = [[UIView alloc] initWithFrame:CGRectMake(moneyDetailViewX, CGRectGetMaxY(moneyDetailView.frame) + YZMargin, moneyDetailViewW, 115)];
    walletView.backgroundColor = [UIColor whiteColor];
    walletView.layer.masksToBounds = YES;
    walletView.layer.cornerRadius = 5;
    [scrollView addSubview:walletView];
    
    UILabel * walletLabel = [[UILabel alloc] init];
    walletLabel.textColor = YZBlackTextColor;
    walletLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    walletLabel.text = @"我的钱包";
    CGSize walletLabelSize = [walletLabel.text sizeWithLabelFont:walletLabel.font];
    walletLabel.frame = CGRectMake(YZMargin, YZMargin, walletLabelSize.width, walletLabelSize.height);
    [walletView addSubview:walletLabel];
    
    //充值提款彩券
    CGFloat rechargeBtnY = 45;
    CGFloat rechargeBtnH = 58;
    for (int i = 0; i < 3; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(walletView.width / 3 * i, rechargeBtnY, walletView.width / 3, rechargeBtnH);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        if (i == 0) {
            self.rechargeButton = button;
            [button setImage:[UIImage imageNamed:@"mine_recharge_icon"] forState:UIControlStateNormal];
            [button setTitle:@"充值" forState:UIControlStateNormal];
        }else if (i == 1)
        {
            self.withdrawalButton = button;
            [button setImage:[UIImage imageNamed:@"mine_withdrawal_icon"] forState:UIControlStateNormal];
            [button setTitle:@"提款" forState:UIControlStateNormal];
        }else if (i == 2)
        {
            self.voucheButton = button;
            [button setImage:[UIImage imageNamed:@"mine_vouche_icon"] forState:UIControlStateNormal];
            [button setTitle:@"彩券" forState:UIControlStateNormal];
        }
        [button setTitleColor:YZBlackTextColor forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(30)];
        [button setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentUp imgTextDistance:10];//图片和文字的间距
        [button addTarget:self action:@selector(walletButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [walletView addSubview:button];
        if (i != 0) {
            UIView * line = [[UIView alloc]initWithFrame:CGRectMake(0, (rechargeBtnH - lineH) / 2, 1, lineH)];
            line.backgroundColor = YZWhiteLineColor;
            [button addSubview:line];
        }
    }
    
    //我的服务
    UIView * functionView = [[UIView alloc] initWithFrame:CGRectMake(moneyDetailViewX, CGRectGetMaxY(walletView.frame) + YZMargin, moneyDetailViewW, 0)];
    functionView.backgroundColor = [UIColor whiteColor];
    functionView.layer.masksToBounds = YES;
    functionView.layer.cornerRadius = 5;
    [scrollView addSubview:functionView];
    
    UILabel * functionLabel = [[UILabel alloc] init];
    functionLabel.textColor = YZBlackTextColor;
    functionLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    functionLabel.text = @"我的服务";
    CGSize functionLabelSize = [functionLabel.text sizeWithLabelFont:functionLabel.font];
    functionLabel.frame = CGRectMake(YZMargin, YZMargin, functionLabelSize.width, functionLabelSize.height);
    [functionView addSubview:functionLabel];
    
    //功能按钮
    CGFloat functionBtnH = 70;
    NSMutableArray * buttonTitles = [NSMutableArray arrayWithArray:@[@"投注详情", @"资金明细", @"充值记录", @"提款记录", @"消息中心", @"购彩帮助", @"彩店信息"]];
    NSMutableArray * buttonImageNames = [NSMutableArray arrayWithArray:@[@"mine_order_zc_icon", @"mine_money_zc_icon", @"mine_recharge_record_zc_icon", @"mine_withdrawal_record_zc_icon", @"mine_message_zc_icon", @"mine_help_zc_icon", @"mine_shop_icon"]];
    BOOL share_open = [YZUserDefaultTool getIntForKey:@"share_open"];
    if (share_open) {
        [buttonTitles addObject:@"邀请好友"];
        [buttonImageNames addObject:@"mine_share_icon"];
    }
    for (int i = 0; i < buttonTitles.count; i++) {
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.frame = CGRectMake(functionView.width / 4 * (i % 4), 40 + (i / 4) * (functionBtnH + 5), functionView.width / 4, functionBtnH);
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
        [button setImage:[UIImage imageNamed:buttonImageNames[i]] forState:UIControlStateNormal];
        [button setTitle:buttonTitles[i] forState:UIControlStateNormal];
        [button setTitleColor:YZBlackTextColor forState:UIControlStateNormal];
        [button setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentUp imgTextDistance:10];//图片和文字的间距
        [button addTarget:self action:@selector(functionButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [functionView addSubview:button];
        functionView.height = CGRectGetMaxY(button.frame) + 5;
    }
    
    scrollView.contentSize = CGSizeMake(screenWidth, CGRectGetMaxY(functionView.frame) + 10);

    //初始化头部刷新控件
    MJRefreshGifHeader *header = [MJRefreshGifHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshViewBeginRefreshing)];
    [YZTool setRefreshHeaderGif:header];
    self.header= header;
    scrollView.mj_header = header;
}

//刷新
- (void)headerRefreshViewBeginRefreshing
{
    [self loadUserInfo];
}

#pragma mark - 设置头像引导
- (void)addGuideView
{
    BOOL haveShow = [YZUserDefaultTool getIntForKey:@"avatar_guideHaveShow"];
    if (haveShow) {
        return;
    }
    //guide
    UIView * guideView = [[UIView alloc] initWithFrame:KEY_WINDOW.bounds];
    self.guideView = guideView;
    [KEY_WINDOW addSubview:guideView];
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeGuideView)];
    [guideView addGestureRecognizer:tap];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, guideView.width, guideView.height)];
    //小圆
    CGPoint center = CGPointMake(self.avatarImageView.centerX, statusBarH + navBarH + self.avatarImageView.centerY);
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath moveToPoint:center];
    [circlePath addArcWithCenter:center radius:self.avatarImageView.width / 2 startAngle:0 endAngle:2 * M_PI clockwise:YES];
    [circlePath closePath];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = YZColor(0, 0, 0, 0.6).CGColor;
    [guideView.layer addSublayer:fillLayer];
    
    UILabel * guideLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, screenWidth - 2 * 20, 100)];
    guideLabel.center = guideView.center;
    guideLabel.text = @"请点击设置您的头像，让更多彩友认识您";
    guideLabel.numberOfLines = 0;
    guideLabel.textColor = [UIColor whiteColor];
    guideLabel.font = [UIFont boldSystemFontOfSize:YZGetFontSize(40)];
    guideLabel.textAlignment = NSTextAlignmentCenter;
    [guideView addSubview:guideLabel];
    
    [YZUserDefaultTool saveInt:1 forKey:@"avatar_guideHaveShow"];
}

- (void)removeGuideView
{
    [UIView animateWithDuration:animateDuration
                     animations:^{
                         self.guideView.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.guideView removeFromSuperview];
                     }];
}

#pragma mark - 设置数据
- (void)setUser:(YZUser *)user
{
    _user = user;
    
    //赋值个人基本信息
    NSString * loginWay = [YZUserDefaultTool getObjectForKey:@"loginWay"];
    YZThirdPartyStatus *thirdPartyStatus = [YZUserDefaultTool thirdPartyStatus];
    if (!YZStringIsEmpty(_user.user.nickName)) {
        self.nickNameLabel.text = _user.user.nickName;
    }else if ([loginWay isEqualToString:@"thirdPartyLogin"] && thirdPartyStatus)//第三方登录
    {
        self.nickNameLabel.text = thirdPartyStatus.name;
    }
    
    if (_user.user.realname) {
        self.nameCertificationLabel.text = @"已认证";
    }else
    {
        self.nameCertificationLabel.text = @"未认证";
    }
    if (_user.user.mobile) {
        self.phoneBindingLabel.text = @"已绑定手机";
    }else
    {
        self.phoneBindingLabel.text = @"未绑定手机";
    }
    
    //赋值彩金、奖金、积分
    NSString *balance = [NSString stringWithFormat:@"%.2f元",[_user.account.balance intValue] / 100.0];
    if ([_user.account.balance intValue] == 0)
    {
        balance = @"0元";
    }
    NSString *bonus = [NSString stringWithFormat:@"%.2f元",[_user.account.bonus intValue] / 100.0];
    if ([_user.account.bonus intValue] == 0)
    {
        bonus = @"0元";
    }
    NSString *grade = [NSString stringWithFormat:@"%d",[_user.account.grade intValue]];
    [self setMoneyButtonTitleByBalance:balance bonus:bonus grade:grade];
    
    //frame
    CGSize nickSize = [self.nickNameLabel.text sizeWithLabelFont:self.nickNameLabel.font];
    CGSize nameSize = [self.nameCertificationLabel.text sizeWithLabelFont:self.nameCertificationLabel.font];
    CGFloat padding = 5;
    CGFloat nickNameY = (81 - nickSize.height - nameSize.height - padding) / 2;
    CGRectMake(CGRectGetMaxX(self.avatarImageView.frame) + 10, nickNameY, nickSize.width, nickSize.height);
    self.nameCertificationLabel.frame = CGRectMake(self.nickNameLabel.x, CGRectGetMaxY(self.nickNameLabel.frame) + padding, nameSize.width, nameSize.height);
    
    self.line1.frame = CGRectMake(CGRectGetMaxX(self.nameCertificationLabel.frame) + 5, self.nameCertificationLabel.y, 1, self.nameCertificationLabel.height);
    
    CGSize mobilePhoneSize = [self.phoneBindingLabel.text sizeWithLabelFont:self.phoneBindingLabel.font];
    self.phoneBindingLabel.frame = CGRectMake(CGRectGetMaxX(self.line1.frame) + 5, self.nameCertificationLabel.y, mobilePhoneSize.width, self.nameCertificationLabel.height);
    
    [self setAvatarWithavAtarUrlString:_user.user.headUrl];
}

- (void)setAvatarWithavAtarUrlString:(NSString *)avatarUrlString
{
    NSString * loginWay = [YZUserDefaultTool getObjectForKey:@"loginWay"];
    YZThirdPartyStatus *thirdPartyStatus = [YZUserDefaultTool thirdPartyStatus];
    if (!YZStringIsEmpty(avatarUrlString)) {
        [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:avatarUrlString] placeholderImage:[UIImage imageNamed:@"avatar_zc"]];
    }else if ([loginWay isEqualToString:@"thirdPartyLogin"] && thirdPartyStatus)//第三方登录
    {
        NSURL *imageUrl = [NSURL URLWithString:thirdPartyStatus.iconurl];
        [self.avatarImageView sd_setImageWithURL:imageUrl placeholderImage:[UIImage imageNamed:@"avatar_zc"]];
    }else
    {
        self.avatarImageView.image = [UIImage imageNamed:@"avatar_zc"];
    }
}

- (void)setMoneyButtonTitleByBalance:(NSString *)balance bonus:(NSString *)bonus grade:(NSString *)grade
{
    NSArray *moneys = [NSArray arrayWithObjects:balance,bonus,grade,nil];
    NSArray * moneyDetailbtnTitles = @[@"彩金", @"奖金", @"积分"];
    for (UIButton * button in self.moneyDetailbtns) {
        NSInteger index = [self.moneyDetailbtns indexOfObject:button];
        NSString * btnStr = [NSString stringWithFormat:@"%@\n%@", moneys[index], moneyDetailbtnTitles[index]];
        NSMutableAttributedString * btnAttStr = [[NSMutableAttributedString alloc]initWithString:btnStr];
        [btnAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:YZGetFontSize(34)] range:NSMakeRange(0, btnAttStr.length - 2)];
        [btnAttStr addAttribute:NSForegroundColorAttributeName value:YZColor(99, 53, 26, 1) range:NSMakeRange(0, btnAttStr.length - 2)];
        [btnAttStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:YZGetFontSize(24)] range:NSMakeRange(btnAttStr.length - 2, 2)];
        [btnAttStr addAttribute:NSForegroundColorAttributeName value:YZColor(153, 108, 74, 1) range:NSMakeRange(btnAttStr.length - 2, 2)];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentCenter;//居中
        paragraphStyle.lineSpacing = 3;
        [btnAttStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, btnAttStr.length)];
        [button setAttributedTitle:btnAttStr forState:UIControlStateNormal];
    }
}

#pragma mark - 按钮点击
- (void)settingBarClick
{
    YZMineSettingViewController * settingVC = [[YZMineSettingViewController alloc]init];
    [self.navigationController pushViewController:settingVC animated:YES];
}

- (void)mineBackViewClick
{
    YZAccountInfoViewController * accountInfoVC = [[YZAccountInfoViewController alloc]init];
    [self.navigationController pushViewController:accountInfoVC animated:YES];
}

- (void)moneyDetailButtonDidClick:(UIButton *)button
{
    YZMoneyDetailViewController *moneyDetailVC = [[YZMoneyDetailViewController alloc] init];
    moneyDetailVC.currentIndex = (int)button.tag;
    [self.navigationController pushViewController:moneyDetailVC animated:YES];
}

- (void)walletButtonDidClick:(UIButton *)button
{
    if (button.tag == 1) {//提款
        if (!_user.user.realname || !_user.user.mobile) {
            UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:@"完善实名信息后才能提款哦" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction * alertAction1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"去完善" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                if (!_user.user.realname && !_user.user.mobile) {
                    YZNamePhoneBindingViewController * namePhoneBindingVC = [[YZNamePhoneBindingViewController alloc]init];
                    [self.navigationController pushViewController:namePhoneBindingVC animated:YES];
                }else if (!_user.user.realname  && _user.user.mobile) {//没有实名认证
                    YZRealNameViewController * realNameVC = [[YZRealNameViewController alloc]init];
                    [self.navigationController pushViewController:realNameVC animated:YES];
                }else if (!_user.user.mobile && _user.user.realname) {
                    YZPhoneBindingViewController * PhoneBindingVC = [[YZPhoneBindingViewController alloc]init];
                    [self.navigationController pushViewController:PhoneBindingVC animated:YES];
                }
            }];
            [alertController addAction:alertAction1];
            [alertController addAction:alertAction2];
            [self presentViewController:alertController animated:YES completion:nil];
        }else
        {
            //提现
            YZWithdrawalViewController * withdrawalVC = [[YZWithdrawalViewController alloc]init];
            [self.navigationController pushViewController:withdrawalVC animated:YES];
        }
    }else if (button.tag == 0)//充值
    {
        YZRechargeListViewController *rechargeVc = [[YZRechargeListViewController alloc] initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:rechargeVc animated:YES];
    }else
    {
        YZVoucherViewController * voucherVC = [[YZVoucherViewController alloc]init];
        [self.navigationController pushViewController:voucherVC animated:YES];
    }
}

- (void)functionButtonDidClick:(UIButton *)button
{
    if (button.tag == 0)
    {
        NSBlockOperation *op1 = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self.navigationController popToRootViewControllerAnimated:NO];
            });
        }];
        NSBlockOperation *op2 = [NSBlockOperation blockOperationWithBlock:^{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:RefreshRecordNote object:@(0)];
            });
        }];
        [op2 addDependency:op1];
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [queue waitUntilAllOperationsAreFinished];
        [queue addOperation:op1];
        [queue addOperation:op2];
    }else if (button.tag == 1)
    {
        YZMoneyDetailViewController *moneyDetailVC = [[YZMoneyDetailViewController alloc]init];
        [self.navigationController pushViewController:moneyDetailVC animated:YES];
    }else if (button.tag == 2)
    {
        YZRechargeRecordViewController * rechargeRecordVC = [[YZRechargeRecordViewController alloc]init];
        [self.navigationController pushViewController:rechargeRecordVC animated:YES];
    }else if (button.tag == 3)
    {
        YZWithdrawalRecordViewController * withdrawalRecordVC = [[YZWithdrawalRecordViewController alloc]init];
        [self.navigationController pushViewController:withdrawalRecordVC animated:YES];
    }else if (button.tag == 4)
    {
        YZMessageViewController * messageVC = [[YZMessageViewController alloc]init];
        [self.navigationController pushViewController:messageVC animated:YES];
    }else if (button.tag == 5)
    {
        YZLoadHtmlFileController *htmlVc = [[YZLoadHtmlFileController alloc] initWithFileName:@"help.htm"];
        htmlVc.title = @"购彩帮助";
        [self.navigationController pushViewController:htmlVc animated:YES];
    }else if (button.tag == 6)
    {
        YZShopInfoViewController * shopInfoVC = [[YZShopInfoViewController alloc]init];
        [self.navigationController pushViewController:shopInfoVC animated:YES];
    }else if (button.tag == 7)
    {
        YZShareProfitsViewController * shareProfitsVC = [[YZShareProfitsViewController alloc]init];
        [self.navigationController pushViewController:shareProfitsVC animated:YES];
    }
}

#pragma mark - 修改头像
- (void)chooseAvatarDidClick
{
    self.addImageManage = [[YZAddImageManage alloc] init];
    self.addImageManage.viewController = self;
    self.addImageManage.delegate = self;
    [self.addImageManage addImage];
}

- (void)imageManageCropImage:(UIImage *)image
{
    NSDictionary *dict = @{
                           @"type": @"user",
                           };
    [[YZHttpTool shareInstance] postWithURL:BaseUrlInformation(@"/getAliOssToken") params:dict success:^(id json) {
        YZLog(@"getAliOssToken:%@",json);
        if (SUCCESS){
            [[YZHttpTool shareInstance] uploadWithImage:image currentIndex:0 totalCount:1 aliOssToken:json[@"aliOssToken"] Success:^(NSString * picUrl) {
                [self setUserHeadPortraitWithUserHeadPortrait:picUrl image:image];
            } Failure:^(NSError *error) {
                [MBProgressHUD showError:@"上传图片失败"];
            }  Progress:^(float percent) {
                
            }];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        YZLog(@"error = %@",error);
    }];
}

- (void)setUserHeadPortraitWithUserHeadPortrait:(NSString *)userHeadPortrait image:(UIImage *)image
{
    NSDictionary *dict = @{
                           @"userHeadPortrait": userHeadPortrait
                           };
    [[YZHttpTool shareInstance] postWithURL:BaseUrlInformation(@"/setUserHeadPortrait") params:dict success:^(id json) {
        YZLog(@"setUserHeadPortrait:%@",json);
        if (SUCCESS){
            self.avatarImageView.image = image;
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        YZLog(@"error = %@",error);
    }];
}

#pragma mark - 初始化
- (NSMutableArray *)moneyDetailbtns
{
    if (_moneyDetailbtns == nil) {
        _moneyDetailbtns = [NSMutableArray array];
    }
    return _moneyDetailbtns;
}

@end
