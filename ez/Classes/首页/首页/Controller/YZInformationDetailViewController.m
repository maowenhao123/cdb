//
//  YZInformationDetailViewController.m
//  ez
//
//  Created by 毛文豪 on 2019/3/27.
//  Copyright © 2019 9ge. All rights reserved.
//

#import "YZInformationDetailViewController.h"
#import "YZGameIdViewController.h"
#import "YZInformationModel.h"
#import "YZShareView.h"
#import "YZWebView.h"
#import "WXApi.h"

@interface YZInformationDetailViewController ()

@property (nonatomic, strong) YZInformationModel *informationModel;
@property (nonatomic, weak) YZWebView *webView;

@end

@implementation YZInformationDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    waitingView_loadingData;
    NSDictionary *dict = @{
        @"recommendId":self.recommendId,
        @"token":Token
    };
    [[YZHttpTool shareInstance] postWithURL:@"/getStoreRecommendInfo" params:dict success:^(id json) {
        YZLog(@"%@",json);
        [MBProgressHUD hideHUDForView:self.view];
        if (SUCCESS) {
            self.informationModel = [YZInformationModel objectWithKeyValues:json[@"recommend"]];
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
- (void)setInformationModel:(YZInformationModel *)informationModel
{
    _informationModel = informationModel;
    
    self.title = self.informationModel.title;
    [self.webView loadHTMLString:self.informationModel.content baseURL:nil];//加载
}

#pragma mark - 请求数据
- (void)setupChilds
{
    //分享
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"order_share"] style:UIBarButtonItemStylePlain target:self action:@selector(share)];
    
    //webView
    CGFloat betButtonH = 40;
    CGFloat webViewH = screenHeight - statusBarH - navBarH - 10 * 2 - betButtonH - [YZTool getSafeAreaBottom];
    if (IsBangIPhone) {
        webViewH = screenHeight - statusBarH - navBarH - 10 - betButtonH - [YZTool getSafeAreaBottom];
    }
    YZWebView * webView =  [[YZWebView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, webViewH)];
    self.webView = webView;
    [self.view addSubview:webView];
    
    
    //立即投注
    YZBottomButton * betButton = [YZBottomButton buttonWithType:UIButtonTypeCustom];
    betButton.y = CGRectGetMaxY(webView.frame) + 10;
    [betButton setTitle:@"立即投注" forState:UIControlStateNormal];
    [betButton addTarget:self action:@selector(betButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:betButton];
}

#pragma mark - 立即投注
- (void)betButtonClick
{
    YZGameIdViewController *destVc = (YZGameIdViewController *)[[[YZTool gameDestClassDict][self.informationModel.gameId] alloc] initWithGameId:self.informationModel.gameId];
    [self.navigationController pushViewController:destVc animated:YES];
}

#pragma mark - 分享
- (void)share
{
    YZShareView * shareView = [[YZShareView alloc]init];
    [shareView show];
    shareView.block = ^(UMSocialPlatformType platformType){//选择平台
        [self shareImageToPlatformType:platformType];
    };
}

- (void)shareImageToPlatformType:(UMSocialPlatformType)platformType
{
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    NSString * spreadPicsUrlStr = self.informationModel.imgPath;
    UIImageView * imageView = [[UIImageView alloc] init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:spreadPicsUrlStr] placeholderImage:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (error) {
            image = [UIImage imageNamed:@"logo"];
        }
        UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:self.informationModel.title descr:self.informationModel.intro thumImage:image];
        shareObject.webpageUrl = self.informationModel.detailUrl;
        messageObject.shareObject = shareObject;
        [WXApi registerApp:WXAppId withDescription:@"彩店宝"];
        //调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:nil completion:^(id data, NSError *error) {
            if (error) {
                NSInteger errorCode = error.code;
                if (errorCode == 2003) {
                    [MBProgressHUD showError:@"分享失败"];
                }else if (errorCode == 2008)
                {
                    [MBProgressHUD showError:@"应用未安装"];
                }else if (errorCode == 2010)
                {
                    [MBProgressHUD showError:@"网络异常"];
                }
            }
        }];
    }];
}


@end
