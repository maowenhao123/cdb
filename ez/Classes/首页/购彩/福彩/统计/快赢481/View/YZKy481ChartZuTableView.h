//
//  YZKy481ChartZuTableView.h
//  ez
//
//  Created by 毛文豪 on 2019/12/2.
//  Copyright © 2019 9ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZKy481ChartZuTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZKy481ChartZuTableView : UITableView

@property (nonatomic, strong) NSArray * dataArray;
@property (nonatomic, strong) YZChartStatsStatus * stats;

@end

NS_ASSUME_NONNULL_END
