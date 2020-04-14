//
//  YZInformationTableViewCell.h
//  zc
//
//  Created by dahe on 2020/4/14.
//  Copyright © 2020 9ge. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YZInformationModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface YZInformationTableViewCell : UITableViewCell

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@property (nonatomic, strong) YZInformationModel *informationModel;

@end

NS_ASSUME_NONNULL_END
