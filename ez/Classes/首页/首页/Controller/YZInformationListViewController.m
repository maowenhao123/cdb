//
//  YZInformationListViewController.m
//  zc
//
//  Created by dahe on 2020/4/14.
//  Copyright © 2020 9ge. All rights reserved.
//

#import "YZInformationListViewController.h"
#import "YZInformationDetailViewController.h"
#import "YZInformationTableViewCell.h"

@interface YZInformationListViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation YZInformationListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"预测推荐";
    [self setupChilds];
    [self getData];
}

#pragma mark - 请求数据
- (void)getData
{
    waitingView_loadingData;
    NSDictionary *dict = @{
        @"token": Token,
    };
    [[YZHttpTool shareInstance] postWithURL:@"/getStoreRecommendList" params:dict success:^(id json) {
        [MBProgressHUD hideHUDForView:self.view];
        YZLog(@"%@", json);
        if (SUCCESS) {
            self.dataArray = [YZInformationModel objectArrayWithKeyValuesArray:json[@"recommends"]];
        }else
        {
            ShowErrorView;
        }
        [self.tableView reloadData];
    } failure:^(NSError *error) {
        [MBProgressHUD hideHUDForView:self.view];
        [self.tableView reloadData];
    }];
}

#pragma mark - 布局视图
- (void)setupChilds
{
    //tableview
    UITableView * tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight - statusBarH - navBarH)];
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
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YZInformationTableViewCell *cell = [YZInformationTableViewCell cellWithTableView:tableView];
    cell.informationModel = self.dataArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 110;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    YZInformationDetailViewController * informationDetailVC = [[YZInformationDetailViewController alloc] init];
    YZInformationModel *informationModel = self.dataArray[indexPath.row];
    informationDetailVC.recommendId = informationModel.id;
    [self.navigationController pushViewController:informationDetailVC animated:YES];
}

#pragma mark - 初始化
- (NSArray *)dataArray
{
    if (_dataArray == nil) {
        _dataArray = [NSArray array];
    }
    return _dataArray;
}

@end
