//
//  YZInformationTableViewCell.m
//  zc
//
//  Created by dahe on 2020/4/14.
//  Copyright © 2020 9ge. All rights reserved.
//

#import "YZInformationTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "YZDateTool.h"

@interface YZInformationTableViewCell ()

@property (nonatomic, weak) UIImageView *focusImageView;
@property (nonatomic, weak) UILabel * titleLabel;
@property (nonatomic, weak) UILabel * introLabel;
@property (nonatomic, weak) UIImageView *browseTimesImageView;
@property (nonatomic, weak) UILabel * browseTimesLabel;
@property (nonatomic, weak) UILabel * timeLabel;

@end

@implementation YZInformationTableViewCell

//初始化一个cell
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString *ID = @"YZInformationTableViewCellId";
    YZInformationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(cell == nil)
    {
        cell = [[YZInformationTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupChilds];
    }
    return self;
}

- (void)setupChilds
{
    //图片
    UIImageView * focusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(12, 10, 102, 90)];
    self.focusImageView = focusImageView;
    [self addSubview:focusImageView];
    
    CGFloat viewX = CGRectGetMaxX(focusImageView.frame) + 8;
    CGFloat viewW = screenWidth - viewX - YZMargin;
    //标题
    UILabel * titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, focusImageView.y + 3, viewW, 20)];
    self.titleLabel = titleLabel;
    titleLabel.font = [UIFont systemFontOfSize:YZGetFontSize(28)];
    titleLabel.textColor = YZBlackTextColor;
    [self addSubview:titleLabel];
    
    //描述
    UILabel * introLabel = [[UILabel alloc] initWithFrame:CGRectMake(viewX, CGRectGetMaxY(titleLabel.frame) + 2, viewW, 40)];
    self.introLabel = introLabel;
    introLabel.font = [UIFont systemFontOfSize:YZGetFontSize(26)];
    introLabel.textColor = YZDrayGrayTextColor;
    introLabel.numberOfLines = 0;
    [self addSubview:introLabel];
    
    //阅读量
    UIImageView * browseTimesImageView = [[UIImageView alloc] initWithFrame:CGRectMake(viewX, CGRectGetMaxY(introLabel.frame) + 3, 20, 20)];
    self.browseTimesImageView = browseTimesImageView;
    browseTimesImageView.image = [UIImage imageNamed:@"information_browseTimes"];
    [self addSubview:browseTimesImageView];
    
    UILabel * browseTimesLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(browseTimesImageView.frame) + 5, CGRectGetMaxY(introLabel.frame) + 3, 100, 20)];
    self.browseTimesLabel = browseTimesLabel;
    browseTimesLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
    browseTimesLabel.textColor = YZDrayGrayTextColor;
    [self addSubview:browseTimesLabel];
    
    //时间
    UILabel * timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(screenWidth - YZMargin - 100, CGRectGetMaxY(introLabel.frame) + 3, 100, 20)];
    self.timeLabel = timeLabel;
    timeLabel.font = [UIFont systemFontOfSize:YZGetFontSize(24)];
    timeLabel.textColor = YZDrayGrayTextColor;
    timeLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:timeLabel];
    
    //分割线
    UIView * line = [[UIView alloc]initWithFrame:CGRectMake(12, 110 - 1, screenWidth - 12, 1)];
    line.backgroundColor = YZWhiteLineColor;
    [self addSubview:line];
}

#pragma mark - Setting
- (void)setInformationModel:(YZInformationModel *)informationModel
{
    _informationModel = informationModel;
    
    [self.focusImageView sd_setImageWithURL:[NSURL URLWithString:_informationModel.imgPath] placeholderImage:[UIImage imageNamed:@"information_placeholder"]];
    
    self.titleLabel.text = _informationModel.title;
    
    self.introLabel.text = _informationModel.intro;
    
    self.browseTimesLabel.text = [NSString stringWithFormat:@"%@", _informationModel.browseTimes];
    
    self.timeLabel.text = [YZDateTool getTimeByTimestamp:_informationModel.publishTime format:@"yyyy-MM-dd"];
}

@end
