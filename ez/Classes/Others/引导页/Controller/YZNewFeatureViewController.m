//
//  YZNewFeatureViewController.m
//  ez
//
//  Created by apple on 14-7-31.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#import "YZNewFeatureViewController.h"
#import "YZLoginViewController.h"
#import "YZTabBarViewController.h"

@interface YZNewFeatureViewController ()

@end

@implementation YZNewFeatureViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupScrollView];
}

#pragma mark - 添加UISrollView
- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.delaysContentTouches = NO;
    scrollView.frame = self.view.bounds;
    [self.view addSubview:scrollView];

    CGFloat imageW = scrollView.frame.size.width;
    CGFloat imageH = scrollView.frame.size.height;
    NSInteger newfeatureImageCount = 3;
    for (int index = 0; index < newfeatureImageCount;index++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        // 设置图片
        NSString *name = [NSString stringWithFormat:@"guidePage%d_6P_zc", index + 1];
        if (iPhone5)
        {
            name = [NSString stringWithFormat:@"guidePage%d_5_zc", index + 1];
        }else if (iPhone6)
        {
            name = [NSString stringWithFormat:@"guidePage%d_6_zc", index + 1];
        }else if (iPhone6P)
        {
            name = [NSString stringWithFormat:@"guidePage%d_6P_zc", index + 1];
        }else if (iPhoneX)
        {
            name = [NSString stringWithFormat:@"guidePage%d_X_zc", index + 1];
        }else if (iPhoneXR)
        {
            name = [NSString stringWithFormat:@"guidePage%d_XR_zc", index + 1];
        }else if (iPhoneXSMax)
        {
            name = [NSString stringWithFormat:@"guidePage%d_XMax_zc", index + 1];
        }
        imageView.image = [UIImage imageNamed:name];
        // 设置frame
        CGFloat imageX = index * imageW;
        imageView.frame = CGRectMake(imageX, 0, imageW, imageH);
        
        [scrollView addSubview:imageView];
        
        // 在最后一个图片上面添加按钮
        if (index == newfeatureImageCount - 1) {
            [self setupLastImageView:imageView];
        }
    }
    scrollView.contentSize = CGSizeMake(imageW * newfeatureImageCount, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.bounces = NO;
}

#pragma mark -  添加按钮到最后一个图片
- (void)setupLastImageView:(UIImageView *)imageView
{
    imageView.userInteractionEnabled = YES;
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat buttonW = 300;
    CGFloat buttonX = (screenWidth - buttonW) / 2;
    startButton.frame = CGRectMake(buttonX, screenHeight * 0.7, buttonW, screenHeight * 0.3);
    startButton.center = CGPointMake(screenWidth / 2, startButton.center.y);

    [startButton addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:startButton];
}
#pragma mark - 开始
- (void)start
{
    // 显示状态栏
    [UIApplication sharedApplication].statusBarHidden = NO;
    if (Token) {
        [UIApplication sharedApplication].keyWindow.rootViewController = [[YZTabBarViewController alloc] init];
    }else
    {
        YZLoginViewController *loginVC = [[YZLoginViewController alloc] init];
        YZNavigationController *loginNVC = [[YZNavigationController alloc] initWithRootViewController:loginVC];
        [UIApplication sharedApplication].keyWindow.rootViewController = loginNVC;
    }
}

@end
