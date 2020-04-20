//
//  YZShopInfoViewController.m
//  zc
//
//  Created by dahe on 2020/3/31.
//  Copyright © 2020 9ge. All rights reserved.
//

#import "YZShopInfoViewController.h"
#import "YZShopModel.h"

@interface YZShopInfoViewController ()

@property (nonatomic, weak) UIView * topView;
@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UILabel *phoneLabel;
@property (nonatomic, weak) UILabel *addressLabel;
@property (nonatomic, weak) UILabel * payLabel;
@property (nonatomic, weak) UIImageView *erCodeImageView;
@property (nonatomic, strong) YZShopModel * shopModel;

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
    [self getShopInfo];
}

#pragma mark - 请求数据
- (void)getShopInfo
{
    waitingView_loadingData;
    NSDictionary *dict = @{
        @"storeId":@"1",
        @"token":Token
    };
    [[YZHttpTool shareInstance] postWithURL:@"/getStoreInfo" params:dict success:^(id json) {
        YZLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            YZShopModel *shopModel = [YZShopModel objectWithKeyValues:json[@"store"]];
            shopModel.payList = [YZShopPayModel objectArrayWithKeyValuesArray:json[@"store"][@"payList"]];
            self.shopModel = shopModel;
        }else
        {
            ShowErrorView;
        }
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        YZLog(@"账户error");
    }];
}

#pragma mark - Setting
- (void)setShopModel:(YZShopModel *)shopModel
{
    _shopModel = shopModel;
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_shopModel.headUrl] placeholderImage:[UIImage imageNamed:@"avatar_zc"]];
    self.phoneLabel.text = _shopModel.phone;
    self.addressLabel.text = _shopModel.address;
    CGSize addressLabelSize = [self.addressLabel.text sizeWithFont:self.addressLabel.font maxSize:CGSizeMake(self.addressLabel.width, MAXFLOAT)];
    CGFloat addressLabelH = addressLabelSize.height;
    if (addressLabelH < 17) {
        addressLabelH = 17;
    }
    self.addressLabel.height = addressLabelH;
    self.payLabel.y = CGRectGetMaxY(self.addressLabel.frame) + 13;
    
    for (int i = 0; i < _shopModel.payList.count; i++) {
        YZShopPayModel * payModel = _shopModel.payList[i];
        UIImageView *payImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.payLabel.frame) + (20 + 5) * i, self.payLabel.y, 20, 20)];
        [payImageView sd_setImageWithURL:[NSURL URLWithString:payModel.imgUrl]];
        [self.topView addSubview:payImageView];
        
        self.topView.height = CGRectGetMaxY(payImageView.frame) + 12;
    }
    self.erCodeImageView.image = [self generateQRCodeWithString:_shopModel.url];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //内容
    UIView * contentView = [[UIView alloc] initWithFrame:CGRectMake(YZMargin, YZMargin, screenWidth - 2 * YZMargin, 470)];
    contentView.backgroundColor = [UIColor whiteColor];
    contentView.layer.cornerRadius = 5;
    contentView.layer.masksToBounds = YES;
    [self.view addSubview:contentView];
    
    //顶部 店铺信息
    UIView * topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentView.width, 120)];
    self.topView = topView;
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
        }else
        {
            self.addressLabel = label;
            label.numberOfLines = 0;
        }
        label.textColor = YZBlackTextColor;
        label.font = [UIFont systemFontOfSize:YZGetFontSize(30)];
        [topView addSubview:label];
    }
    
    UILabel * payLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(avatarImageView.frame) + 10, CGRectGetMaxY(self.addressLabel.frame) + 13, 80, 20)];
    self.payLabel = payLabel;
    payLabel.text = @"本店支持：";
    payLabel.textColor = YZDrayGrayTextColor;
    payLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    [topView addSubview:payLabel];
    
    //二维码
    UILabel *erCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(YZMargin, CGRectGetMaxY(topView.frame) + 50, contentView.width - 2 * YZMargin, 20)];
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

- (UIImage *)generateQRCodeWithString:(NSString *)string
{
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    CIImage *image = [filter outputImage];
    UIImage *img = [self createNonInterpolatedUIImageFormCIImage:image withSize:screenWidth];
    UIGraphicsBeginImageContext(img.size);
    [img drawInRect:CGRectMake(0, 0, img.size.width, img.size.height)];
    UIImage *centerImg = [UIImage imageNamed:@"logo"];
    CGFloat centerW = img.size.width * 0.25;
    CGFloat centerH = centerW;
    CGFloat centerX = (img.size.width-centerW)*0.5;
    CGFloat centerY = (img.size.height -centerH)*0.5;
    [centerImg drawInRect:CGRectMake(centerX, centerY, centerW, centerH)];
    UIImage *finalImg=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return finalImg;
}

- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

@end
