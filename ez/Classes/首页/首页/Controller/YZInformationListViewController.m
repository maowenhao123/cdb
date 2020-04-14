//
//  YZInformationListViewController.m
//  zc
//
//  Created by dahe on 2020/4/14.
//  Copyright © 2020 9ge. All rights reserved.
//

#import "YZInformationListViewController.h"
#import "YZInformationTableViewCell.h"

@interface YZInformationListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;

@end

@implementation YZInformationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"预测推荐";
    [self setupChilds];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableview
    UITableView * tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
    self.tableView = tableView;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    tableView.backgroundColor = YZBackgroundColor;
    [tableView setEstimatedSectionHeaderHeightAndFooterHeight];
    [self.view addSubview:tableView];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YZInformationTableViewCell *cell = [YZInformationTableViewCell cellWithTableView:tableView];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

@end
