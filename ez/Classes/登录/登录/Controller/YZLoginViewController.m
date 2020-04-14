//
//  YZLoginViewController.m
//  ez
//
//  Created by apple on 14-8-8.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#define historyAccountViewY 119

#import <TencentOpenAPI/TencentOAuth.h>
#import <TYRZSDK/TYRZSDK.h>
#import "YZLoginViewController.h"
#import "YZRegisterViewController.h"
#import "YZSecretChangeViewController.h"
#import "YZLoginAccountTableViewCell.h"
#import "YZStatusCacheTool.h"
#import "YZMessageLoginViewController.h"
#import "YZThirdPartyBindingViewController.h"
#import "YZLeftViewTextField.h"
#import "YZValidateTool.h"
#import "UIButton+YZ.h"
#import "YZThirdPartyStatus.h"
#import "JSON.h"
#import "WXApi.h"

@interface YZLoginViewController ()

@property (nonatomic, weak) YZLeftViewTextField *accountTextField;
@property (nonatomic, weak) YZLeftViewTextField *pwdTextField;
@property (nonatomic, weak) UIButton *loginbutton;
@property (nonatomic,weak) UIButton * showPasswordButton;
@property (nonatomic, weak) UIButton *switchbtn;

@end

@implementation YZLoginViewController

#pragma mark - 控制器的生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户登录";
    [self setupChildViews];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)backAction
{
    UIViewController *controller = self;
    while(controller.presentingViewController != nil){
        controller = controller.presentingViewController;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupChildViews
{
    self.navigationItem.leftBarButtonItem  = [UIBarButtonItem itemWithIcon:@"back_btn_flat" highIcon:@"back_btn_flat" target:self action:@selector(backAction)];
    
    //login
    UIImageView * logoImageView = [[UIImageView alloc] init];
    CGFloat logoImageViewW = 197;
    CGFloat logoImageViewH = 107;
    logoImageView.frame = CGRectMake((screenWidth - logoImageViewW) / 2, 50, logoImageViewW, logoImageViewH);
    logoImageView.image = [UIImage imageNamed:@"login_ad_zc"];
    [self.view addSubview:logoImageView];
    
    //登录界面
    UIView *loginview = [[UIView alloc] initWithFrame:CGRectMake(screenWidth * 0.1, CGRectGetMaxY(logoImageView.frame) + 40, screenWidth * 0.8, 55 * 2)];
    loginview.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:loginview];
    
    //账号输入框:
    YZLeftViewTextField *accountTextField = [[YZLeftViewTextField alloc]initWithFrame:CGRectMake(0, 0, loginview.width, 55)];
    self.accountTextField = accountTextField;
    accountTextField.placeholder = @"手机号";
    accountTextField.borderStyle = UITextBorderStyleNone;
    accountTextField.font = [UIFont systemFontOfSize:YZGetFontSize(30)];
    accountTextField.textColor = YZBlackTextColor;
    accountTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [loginview addSubview:accountTextField];
    
    UIImageView * leftImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    leftImageView1.image = [UIImage imageNamed:@"login_passWord_icon"];
    accountTextField.leftView = leftImageView1;
    accountTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //分割线
    UIView *seperator1 = [[UIView alloc] init];
    seperator1.frame = CGRectMake(0, 55 - 1, loginview.width, 1);
    seperator1.backgroundColor = YZWhiteLineColor;
    [loginview addSubview:seperator1];
    
    //密码输入框:
    YZLeftViewTextField *pwdTextField = [[YZLeftViewTextField alloc]initWithFrame:CGRectMake(0, 55, loginview.width, 55)];
    self.pwdTextField = pwdTextField;
    pwdTextField.borderStyle = UITextBorderStyleNone;
    pwdTextField.placeholder = @"登录密码";
    pwdTextField.font = [UIFont systemFontOfSize:YZGetFontSize(30)];
    pwdTextField.textColor = YZBlackTextColor;
    pwdTextField.secureTextEntry = YES;
    pwdTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [loginview addSubview:pwdTextField];
    
    UIImageView * leftImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 18, 18)];
    leftImageView2.image = [UIImage imageNamed:@"login_passWord_icon"];
    pwdTextField.leftView = leftImageView2;
    pwdTextField.leftViewMode = UITextFieldViewModeAlways;
    
    //分割线
    UIView *seperator2 = [[UIView alloc] init];
    seperator2.frame = CGRectMake(0, 55 * 2 - 1, loginview.width, 1);
    seperator2.backgroundColor = YZWhiteLineColor;
    [loginview addSubview:seperator2];
    
    //自动登录按钮
    UIButton *switchbtn = [[UIButton alloc] init];
    self.switchbtn = switchbtn;
    [switchbtn setImage:[UIImage imageNamed:@"bet_weixuanzhong"] forState:UIControlStateNormal];
    [switchbtn setImage:[UIImage imageNamed:@"bet_xuanzhong"] forState:UIControlStateSelected];
    [switchbtn setImage:[UIImage imageNamed:@"bet_xuanzhong"] forState:UIControlStateHighlighted];
    switchbtn.selected = YES;
    [switchbtn setTitle:@"自动登录" forState:UIControlStateNormal];
    [switchbtn setTitleColor:YZBlackTextColor forState:UIControlStateNormal];
    switchbtn.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    switchbtn.frame = CGRectMake(loginview.x, CGRectGetMaxY(loginview.frame) + 10, 85, 20);
    [switchbtn setButtonTitleWithImageAlignment:UIButtonTitleWithImageAlignmentLeft imgTextDistance:5];
    int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
    if (autoLoginType == 0) {//默认自动登录
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:2 forKey:@"autoLogin"];
        [defaults synchronize];
    }
    if(autoLoginType == 1)
    {
        switchbtn.selected = NO;
    }else
    {
        switchbtn.selected = YES;//默认值或者设置位自动
    }
    [switchbtn addTarget:self action:@selector(clickswitch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchbtn];
    
    //忘记密码
    UIButton *forgetButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat forgetButtonY = CGRectGetMaxY(loginview.frame) + 10;
    forgetButton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    [forgetButton setTitleColor:YZBlueBallColor forState:UIControlStateNormal];
    [forgetButton setTitle:@"忘记密码" forState:UIControlStateNormal];
    CGSize forgetButtonSize = [forgetButton.currentTitle sizeWithLabelFont:forgetButton.titleLabel.font];
    forgetButton.frame = CGRectMake(CGRectGetMaxX(loginview.frame) - forgetButtonSize.width, forgetButtonY, forgetButtonSize.width, 20);
    [forgetButton addTarget:self action:@selector(forgetButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forgetButton];
    
    //登录按钮
    YZBottomButton *loginbutton = [YZBottomButton buttonWithType:UIButtonTypeCustom];
    self.loginbutton = loginbutton;
    loginbutton.frame = CGRectMake(loginview.x, CGRectGetMaxY(forgetButton.frame) + 50, loginview.width, loginbutton.height);
    [loginbutton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [loginbutton setTitle:@"登录" forState:UIControlStateNormal];
    [loginbutton addTarget:self action:@selector(loginBtnPressed) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:loginbutton];
    
    //注册按钮
    UIButton *registerbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerbtn.frame = CGRectMake(loginbutton.x, CGRectGetMaxY(loginbutton.frame) + 20, loginbutton.width, loginbutton.height);
    registerbtn.backgroundColor = [UIColor whiteColor];
    [registerbtn setTitleColor:YZBlackTextColor forState:UIControlStateNormal];
    [registerbtn setTitle:@"注册" forState:UIControlStateNormal];
    registerbtn.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    [registerbtn addTarget:self action:@selector(quickLoginDidClick:) forControlEvents:UIControlEventTouchUpInside];
    registerbtn.layer.masksToBounds = YES;
    registerbtn.layer.cornerRadius = 3;
    registerbtn.layer.borderWidth = 0.8;
    registerbtn.layer.borderColor = YZGrayLineColor.CGColor;
    [self.view addSubview:registerbtn];
    
    UIButton * messageLoginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    messageLoginButton.tag = 1;
    [messageLoginButton setTitle:@"短信验证码登录" forState:UIControlStateNormal];
    [messageLoginButton setTitleColor:YZColor(83, 83, 83, 1) forState:UIControlStateNormal];
    messageLoginButton.titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    messageLoginButton.frame = CGRectMake(registerbtn.x, CGRectGetMaxY(registerbtn.frame) + 12, registerbtn.width, 20);
    [messageLoginButton addTarget:self action:@selector(buttonDidClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:messageLoginButton];
    
    //第三方登录
    CGFloat thirdPartyBtnWH = 35;
    
    UILabel * promptLabel = [[UILabel alloc]init];
    promptLabel.text = @"合作账户登录";
    promptLabel.font = [UIFont systemFontOfSize:YZGetFontSize(22)];
    promptLabel.textColor = YZColor(134, 134, 134, 1);
    CGSize promptSize = [promptLabel.text sizeWithLabelFont:promptLabel.font];
    CGFloat promptLabelX = (screenWidth - promptSize.width) / 2;
    CGFloat promptLabelY = screenHeight - statusBarH - navBarH - [YZTool getSafeAreaBottom] - thirdPartyBtnWH - 40 - promptSize.height;
    promptLabel.frame = CGRectMake(promptLabelX, promptLabelY, promptSize.width, promptSize.height);
    [self.view addSubview:promptLabel];
    
    UIView * line1 = [[UIView alloc]initWithFrame:CGRectMake(50, 0, promptLabel.x - 50 - 10, 1)];
    line1.center = CGPointMake(line1.center.x, promptLabel.center.y);
    line1.backgroundColor = YZGrayLineColor;
    [self.view addSubview:line1];
    
    UIView * line2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(promptLabel.frame) + 10, 0, screenWidth - CGRectGetMaxX(promptLabel.frame) - 10 - 50, 1)];
    line2.center = CGPointMake(line2.center.x, promptLabel.center.y);
    line2.backgroundColor = YZGrayLineColor;
    [self.view addSubview:line2];
    
    //登录按钮
    NSMutableArray *thirdPartyBtnImages = [NSMutableArray array];
    NSMutableArray *thirdPartyBtnSelectedImages = [NSMutableArray array];
    if ([WXApi isWXAppInstalled]) {//如果安装微信
        [thirdPartyBtnImages addObject:@"login_weixin_icon"];
        [thirdPartyBtnSelectedImages addObject:@"login_weixin_icon_selected"];
    }
    
    if ([TencentOAuth iphoneQQInstalled]) {//如果安装QQ
        [thirdPartyBtnImages addObject:@"login_qq_icon"];
        [thirdPartyBtnSelectedImages addObject:@"login_qq_icon_selected"];
    }
    //微博
    [thirdPartyBtnImages addObject:@"login_sina_icon"];
    [thirdPartyBtnSelectedImages addObject:@"login_sina_icon_selected"];
    
    CGFloat padding = (screenWidth - thirdPartyBtnImages.count * thirdPartyBtnWH) / (thirdPartyBtnImages.count + 1);//边距
    UIButton * lastThirdPartyBtn;
    for (int i = 0; i < thirdPartyBtnImages.count; i++) {
        CGFloat thirdPartyBtnY = screenHeight  - [YZTool getSafeAreaBottom] - thirdPartyBtnWH - statusBarH - navBarH - 25;
        UIButton *thirdPartyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        thirdPartyBtn.frame = CGRectMake(CGRectGetMaxX(lastThirdPartyBtn.frame) + padding, thirdPartyBtnY, thirdPartyBtnWH, thirdPartyBtnWH);
        [thirdPartyBtn setImage:[UIImage imageNamed:thirdPartyBtnImages[i]] forState:UIControlStateNormal];
        [thirdPartyBtn setImage:[UIImage imageNamed:thirdPartyBtnSelectedImages[i]] forState:UIControlStateHighlighted];
        if ([thirdPartyBtnImages[i] isEqual:@"login_weixin_icon"]) {
            thirdPartyBtn.tag = 101;
        }else if ([thirdPartyBtnImages[i] isEqual:@"login_qq_icon"])
        {
            thirdPartyBtn.tag = 102;
        }else if ([thirdPartyBtnImages[i] isEqual:@"login_sina_icon"])
        {
            thirdPartyBtn.tag = 103;
        }
        [thirdPartyBtn addTarget:self action:@selector(thirdPartyBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:thirdPartyBtn];
        lastThirdPartyBtn = thirdPartyBtn;
    }
    
    //如果记住了账号密码,就显示密码
    accountTextField.text = [YZUserDefaultTool getObjectForKey:@"userName"];
    if([YZUserDefaultTool getObjectForKey:@"userPwd"])
    {
        pwdTextField.text = [YZUserDefaultTool getObjectForKey:@"userPwd"];
    }
}

#pragma mark - 点击按钮
- (void)buttonDidClick:(UIButton *)button
{
    if (button.tag == 0) {//忘记密码?
        [self forgetButtonPressed];
    }else//短信验证码登录
    {
        [self messageLogin];
    }
}

- (void)showPasswordButtonDidClick:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected) {
        self.pwdTextField.secureTextEntry = NO;
    } else
    {
        self.pwdTextField.secureTextEntry = YES;
    }
}

- (void)clickswitch:(UIButton *)btn
{
    btn.selected = !btn.selected;
    int autoLoginType = 0;
    if(btn.selected)
    {
        autoLoginType = 2;
    }else
    {
        autoLoginType = 1;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:autoLoginType forKey:@"autoLogin"];
    [defaults synchronize];
}

-(void)messageLogin
{
    YZMessageLoginViewController *messageLoginVC = [[YZMessageLoginViewController alloc] init];
    [self.navigationController pushViewController:messageLoginVC animated:YES];
}

-(void)quickLoginDidClick:(UIButton *)button
{
    UACustomModel *model = [[UACustomModel alloc] init];
    model.currentVC = self;//必传
    model.navReturnImg = [UIImage imageNamed:@"black_back_bar"];
    model.navColor = [UIColor whiteColor];
    model.navText = [[NSAttributedString alloc]initWithString:@"一键登录" attributes:@{NSForegroundColorAttributeName:YZBlackTextColor,NSFontAttributeName:[UIFont boldSystemFontOfSize:17]}];
    [UASDKLogin.shareLogin getAuthorizationWithModel:model complete:^(NSDictionary * _Nonnull sender) {
        NSLog(@"%@", sender);
        NSString *resultCode = sender[@"resultCode"];
        if ([resultCode isEqualToString:@"103000"]) {
            [self quickLoginWithToken:sender[@"token"]];
        }else if ([resultCode isEqualToString:@"200087"])
        {
            
        }else//失败去注册页面
        {
            [MBProgressHUD hideHUDForView:self.view];
            if ([button.currentTitle isEqualToString:@"注册"]) {
                [self gotoRegister];
            }else
            {
                [MBProgressHUD showError:sender[@"desc"]];
            }
        }
    }];
}

- (void)gotoRegister
{
    YZRegisterViewController *registerVc = [[YZRegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVc animated:YES];
}

- (void)quickLoginWithToken:(NSString *)token
{
    NSString * imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString * IP = [[YZHttpTool shareInstance] getIPAddress:NO];
    if ([IP isEqualToString:@"0.0.0.0"]) {
        IP = [[YZHttpTool shareInstance] getIPAddress:YES];
    }
    NSDictionary *dict = @{
        @"cmd":@(10638),
        @"version": @"0.0.1",
        @"ip": IP,
        @"imei":imei,
        @"token": token
    };
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        YZLog(@"json = %@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if(SUCCESS)
        {
            //保存用户信息
            YZUser *user = [YZUser objectWithKeyValues:json];
            [YZUserDefaultTool saveUser:user];
            [YZUserDefaultTool saveObject:@"accountLogin" forKey:@"loginWay"];
            [YZUserDefaultTool saveObject:json[@"token"] forKey:@"token"];
            //发送登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
            [self loadUserInfo];
            [YZTool setAlias];
            [self backAction];
        }else
        {
            ShowErrorView
            [MBProgressHUD hideHUDForView:self.view];
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

- (void)forgetButtonPressed
{
    YZSecretChangeViewController *secretVc = [[YZSecretChangeViewController alloc] init];
    [self.navigationController pushViewController:secretVc animated:YES];
}

#pragma  mark - 点击登录按钮
- (void)loginBtnPressed
{
    [self.view endEditing:YES];
    if (YZStringIsEmpty(self.accountTextField.text)) {
        [MBProgressHUD showError:@"请输入用户名"];
        return;
    }
    if (YZStringIsEmpty(self.pwdTextField.text)) {
        [MBProgressHUD showError:@"请输入密码"];
        return;
    }
    if(![YZValidateTool validateUserName:self.accountTextField.text])
    {
        [MBProgressHUD showError:@"您输入的用户名格式不对"];
        return;
    }
    if(![YZValidateTool validatePassword:self.pwdTextField.text])
    {
        [MBProgressHUD showError:@"您输入的密码格式不对"];
        return;
    }
    [MBProgressHUD showMessage:@"正在登录,客官请稍后" toView:self.view];
    NSDictionary *dict = @{
        @"phone":self.accountTextField.text,
        @"password":self.pwdTextField.text
    };
    [[YZHttpTool shareInstance] postWithURL:@"/login" params:dict success:^(id json)
    {
        YZLog(@"json = %@",json);
        [MBProgressHUD hideHUDForView:self.view];
        //检查账号密码返回数据
        [self checkloginWith:json];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}
- (void)checkloginWith:(id)json
{
    if(SUCCESS)
    {//成功登录
        //保存用户信息
        YZUser *user = [YZUser objectWithKeyValues:json];
        [YZUserDefaultTool saveUser:user];
        [YZUserDefaultTool saveObject:@"accountLogin" forKey:@"loginWay"];
        [YZUserDefaultTool saveObject:json[@"token"] forKey:@"token"];
        //根据保存密码按钮状态，保存密码
        [YZUserDefaultTool saveObject:self.accountTextField.text forKey:@"userName"];//userAccount
        //更新自动登录状态
        int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
        if(autoLoginType == 2)
        {
            [YZUserDefaultTool saveObject:self.pwdTextField.text forKey:@"userPwd"];
        }else
        {
            [YZUserDefaultTool removeObjectForKey:@"userPwd"];
        }
        //发送登录成功通知
        [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
        [self loadUserInfo];
        [YZTool setAlias];
        [self backAction];
    }else
    {
        ShowErrorView
        [MBProgressHUD hideHUDForView:self.view];
    }
}

#pragma mark - 第三方登录
- (void)thirdPartyBtnDidClick:(UIButton *)btn
{
    if (btn.tag == 100) {//手机号一键登录
        [self quickLoginDidClick:btn];
        return;
    }
    //微信注册
    [WXApi registerApp:WXAppId withDescription:@"彩店宝"];
    UMSocialPlatformType platformType;
    if (btn.tag == 101)
    {
        platformType = UMSocialPlatformType_WechatSession;
    }else if (btn.tag == 102)
    {
        platformType = UMSocialPlatformType_QQ;
    }else {
        platformType = UMSocialPlatformType_Sina;
    }
    [[UMSocialManager defaultManager] getUserInfoWithPlatform:platformType currentViewController:nil completion:^(id result, NSError *error) {
        if (!error) {
            [self getBindStatusWithUserInfoResponse:result platformType:platformType];
        }else
        {
            [MBProgressHUD showError:@"授权失败"];
        }
    }];
}
//获取绑定信息
- (void)getBindStatusWithUserInfoResponse:(UMSocialUserInfoResponse *)resp  platformType:(UMSocialPlatformType)platformType
{
    if (!resp || !resp.uid || !resp.openid) {
        return;
    }
    NSString * paramJson;
    NSNumber *type;
    if (platformType == UMSocialPlatformType_WechatSession) {
        paramJson = [@{@"uId":resp.uid,@"openId":resp.openid} JSONRepresentation];
        type = @(2);
    }else if (platformType == UMSocialPlatformType_QQ)
    {
        paramJson = [@{@"uId":resp.uid,@"openId":resp.openid} JSONRepresentation];
        type = @(1);
    }else if (platformType == UMSocialPlatformType_Sina)//微博登录只需uid
    {
        paramJson = [@{@"uId":resp.uid} JSONRepresentation];
        type = @(3);
    }
    NSString * imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    waitingView
    NSDictionary *dict = @{
        @"cmd":@(10630),
        @"type":type,
        @"param":paramJson,
        @"imei":imei
    };
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        YZLog(@"json = %@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            [self checkThirdPartyLoginWithUserInfoResponse:resp json:json type:type param:paramJson imei:imei];
        }else
        {
            ShowErrorView
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
    }];
}

- (void)checkThirdPartyLoginWithUserInfoResponse:(UMSocialUserInfoResponse *)resp json:(id)json type:(NSNumber *)type param:(NSString *)param imei:(NSString *)imei
{
    if (SUCCESS) {
        YZThirdPartyStatus *thirdPartyStatus = [[YZThirdPartyStatus alloc]init];
        thirdPartyStatus.name = resp.name;
        thirdPartyStatus.iconurl = resp.iconurl;
        thirdPartyStatus.gender = resp.gender;
        thirdPartyStatus.uid = resp.uid;
        thirdPartyStatus.openid = resp.openid;
        thirdPartyStatus.refreshToken = resp.refreshToken;
        thirdPartyStatus.expiration = resp.expiration;
        thirdPartyStatus.accessToken = resp.accessToken;
        thirdPartyStatus.platformType = resp.platformType;
        thirdPartyStatus.originalResponse = resp.originalResponse;
        if([json[@"bindStatus"] isEqualToNumber:@(0)])//未绑定
        {
            //检查账号密码返回数据
            YZThirdPartyBindingViewController * thirdPartyBindingVC = [[YZThirdPartyBindingViewController alloc]init];
            thirdPartyBindingVC.type = type;
            thirdPartyBindingVC.param = param;
            thirdPartyBindingVC.imei = imei;
            thirdPartyBindingVC.thirdPartyStatus = thirdPartyStatus;
            [self.navigationController pushViewController:thirdPartyBindingVC animated:YES];
        }else
        {
            [YZUserDefaultTool saveObject:json[@"token"] forKey:@"token"];
            [YZUserDefaultTool saveObject:@"thirdPartyLogin" forKey:@"loginWay"];
            [YZUserDefaultTool saveThirdPartyStatus:thirdPartyStatus];
            //更新自动登录状态
            int autoLoginType = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"autoLogin"];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:autoLoginType forKey:@"autoLogin"];
            [defaults synchronize];
            //用于绑定Alias的
            [YZTool setAlias];
            //发送登录成功通知
            [[NSNotificationCenter defaultCenter] postNotificationName:loginSuccessNote object:nil];
            [self loadUserInfo];
            [self backAction];
        }
    }else
    {
        ShowErrorView;
    }
}
- (void)loadUserInfo
{
    if (!Token)
    {
        return;
    }
    NSDictionary *dict = @{
        @"token" : Token
    };
    [[YZHttpTool shareInstance] postWithURL:@"/getUserInfo" params:dict success:^(id json)
    {
        YZLog(@"%@",json);
        if (SUCCESS) {
            //存储用户信息
            YZUser *user = [YZUser objectWithKeyValues:json];
            [YZUserDefaultTool saveUser:user];
        }
    } failure:^(NSError *error) {
        YZLog(@"账户error");
    }];
}

@end
