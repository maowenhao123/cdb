//
//  YZKy481ChartYongTableView.m
//  ez
//
//  Created by dahe on 2019/12/2.
//  Copyright © 2019 9ge. All rights reserved.
//

#import "YZKy481ChartYongTableView.h"
#import "YZKy481ChartLineView.h"

@interface YZKy481ChartYongTableView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) YZKy481ChartLineView * lineView;//线

@end

@implementation YZKy481ChartYongTableView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = YZBackgroundColor;
        self.delegate = self;
        self.dataSource = self;
        self.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self setEstimatedSectionHeaderHeightAndFooterHeight];
        
        YZKy481ChartLineView * lineView = [[YZKy481ChartLineView alloc] init];
        self.lineView = lineView;
        lineView.backgroundColor = [UIColor clearColor];
        [self addSubview:lineView];
    }
    return self;
}

- (void)setDataArray:(NSArray *)dataArray
{
    _dataArray = dataArray;
    
    [self reloadData];
    
    self.lineView.hidden = YES;
    NSString * showLineStr = [YZTool getChartSettingByTitle:@"折线"];
    if ([showLineStr isEqualToString:@"显示折线"]) {
        self.lineView.hidden = NO;
    }
    self.lineView.chartCellTag = self.chartCellTag;
    self.lineView.frame = CGRectMake(LeftLabelW2, CellH2, screenWidth, CellH2 * _dataArray.count);
    self.lineView.statusArray = _dataArray;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSString * tongjiStr = [YZTool getChartSettingByTitle:@"统计"];
    NSInteger tongjiCount = 0;
    if ([tongjiStr isEqualToString:@"显示统计"]) {//显示统计
        tongjiCount = 4;
    }
    return self.dataArray.count > 0 ? (self.dataArray.count + tongjiCount) : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YZKy481ChartYongTableViewCell * cell = [YZKy481ChartYongTableViewCell cellWithTableView:tableView];
    if(indexPath.row % 2 != 0)
    {
        cell.backgroundColor = YZChartBackgroundColor;
    }else
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.chartCellTag = self.chartCellTag;
    NSString * termCountStr = [YZTool getChartSettingByTitle:@"期数"];
    int termCount = [[termCountStr substringWithRange:NSMakeRange(1, termCountStr.length - 2)] intValue];
    if (indexPath.row < self.dataArray.count) {
        cell.dataStatus = self.dataArray[indexPath.row];
    }else
    {
        if (indexPath.row == self.dataArray.count)
        {
            cell.chartStatisticsTag = KChartCellTagCount;
        }else if (indexPath.row == self.dataArray.count + 1)
        {
            cell.chartStatisticsTag = KChartCellTagAvgMiss;
        }else if (indexPath.row == self.dataArray.count + 2)
        {
            cell.chartStatisticsTag = KChartCellTagMaxMiss;
        }else if (indexPath.row == self.dataArray.count + 3)
        {
            cell.chartStatisticsTag = KChartCellTagMaxSeries;
        }
        YZChartSortStatsStatus *stats;
        if (termCount == 30) {
            stats = self.stats.renxuan.stat30;
        }else if (termCount == 50)
        {
            stats = self.stats.renxuan.stat50;
        }else if (termCount == 100)
        {
            stats = self.stats.renxuan.stat100;
        }else if (termCount == 200)
        {
            stats = self.stats.renxuan.stat200;
        }
        cell.status = stats;
    }
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, CellH2)];
    headerView.backgroundColor = YZChartBackgroundColor;
    for(int i = 0; i < 9; i++)
    {
        UILabel *label = [[UILabel alloc] init];
        if (i == 0) {
            label.frame = CGRectMake(0, 0, LeftLabelW2, CellH2);
            label.text = @"期次";
            label.textColor = YZChartTitleColor;
        }else
        {
            label.frame = CGRectMake(LeftLabelW2 + CellH2 * (i - 1), 0, CellH2, CellH2);
            label.text = [NSString stringWithFormat:@"%02d", i];
            label.textColor = YZChartTitleColor;
        }
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
        label.layer.borderColor = [UIColor lightGrayColor].CGColor;
        label.layer.borderWidth = 0.25;
        [headerView addSubview:label];
    }
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return CellH2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return CellH2;
}

@end
