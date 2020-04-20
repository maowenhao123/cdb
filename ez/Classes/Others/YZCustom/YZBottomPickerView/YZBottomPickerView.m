//
//  YZBottomPickerView.m
//  ez
//
//  Created by apple on 16/12/5.
//  Copyright © 2016年 9ge. All rights reserved.
//

#import "YZBottomPickerView.h"

@interface YZBottomPickerView ()<UIPickerViewDataSource,UIPickerViewDelegate>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, copy) NSString *selectedString;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation YZBottomPickerView

- (instancetype)initWithArray:(NSArray *)dataArray index:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.dataArray = dataArray;
        
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = YZColor(0, 0, 0, 0.4);
        
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)];
        [self addGestureRecognizer:tap];
        
        UIView *contentView = [[UIView alloc]initWithFrame:CGRectMake(0, screenHeight, screenWidth, 300)];
        self.contentView = contentView;
        contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:contentView];
        
        //工具栏取消和选择
        UIView * toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, 45)];
        toolView.backgroundColor = YZBackgroundColor;
        [contentView addSubview:toolView];
        
        UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelButton.frame = CGRectMake(YZMargin, 0, 100, toolView.height);
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:YZDrayGrayTextColor forState:UIControlStateNormal];
        cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [cancelButton addTarget:self action:@selector(hide) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:cancelButton];
        
        UIButton * selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectButton.frame = CGRectMake(screenWidth - 100 - YZMargin, 0, 100, toolView.height);
        [selectButton setTitle:@"确定" forState:UIControlStateNormal];
        [selectButton setTitleColor:YZBaseColor forState:UIControlStateNormal];
        selectButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        selectButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [selectButton addTarget:self action:@selector(selectBarClicked) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:selectButton];
        
        //PickerView
        UIPickerView * pickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(toolView.frame), screenWidth, contentView.height - CGRectGetMaxY(toolView.frame))];
        pickerView.backgroundColor = [UIColor whiteColor];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        [contentView addSubview:pickerView];
        
        [pickerView selectRow:index inComponent:0 animated:NO];
        self.selectedString = self.dataArray[index];
    }
    return self;
}

#pragma  mark - function
- (void)selectBarClicked
{
    NSInteger selectedIndex = [self.dataArray indexOfObject:self.selectedString];
    if (self.block) {
        self.block(selectedIndex);
    }
    [self hide];
}

- (void)show
{
    UIView *topView = [KEY_WINDOW.subviews firstObject];
    [topView addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.contentView.y = screenHeight - self.contentView.height;
    }];
}

- (void)hide
{
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
        self.contentView.y = screenHeight;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataArray.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.dataArray[row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 36;
}

#pragma mark - UIPickerViewDelegate
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.textColor = YZBlackTextColor;
        [pickerLabel setTextAlignment:NSTextAlignmentCenter];
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
        [pickerLabel setFont:[UIFont systemFontOfSize:17]];
    }
    pickerLabel.text=[self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedString = self.dataArray[row];
}

@end
