//
//  YZAdvertModel.h
//  ez
//
//  Created by 毛文豪 on 2018/1/30.
//  Copyright © 2018年 9ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YZAdvertModel : NSObject

@property (nonatomic,copy) NSString *name;
/*
POINT  代表  积分兑换
INFORMATION  代表  预测咨询
PROMOTION  代表  活动中心
HIT  代表  中奖专区
GIFT  代表  彩票红包
OTHERS  代表  其他类型
*/
@property (nonatomic, copy) NSString *redirectType;
@property (nonatomic,copy) NSString *extendParam;
@property (nonatomic,copy) NSString *iconName;
@property (nonatomic,copy) NSString *url;

@end
