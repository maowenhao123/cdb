//
//  YZUser.h
//  ez
//
//  Created by apple on 14-10-28.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZWeixin.h"

@interface YZAccount : NSObject

@property (nonatomic, strong) NSNumber *balance;//彩金
@property (nonatomic, strong) NSNumber *bonus;//奖金
@property (nonatomic, strong) NSNumber *grade;//积分
@property (nonatomic, strong) NSNumber *deposit;
@property (nonatomic, strong) NSNumber *total;

@end

@interface YZUserInfo : NSObject

@property (nonatomic, copy) NSString *age;
@property (nonatomic, copy) NSString *cardNo;//身份证号码
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *realName;//真实姓名
@property (nonatomic, copy) NSString *sex;
@property (nonatomic, copy) NSString *headUrl;//头像url

@end

@interface YZUser : NSObject

@property (nonatomic, strong) YZAccount *account;
@property (nonatomic, copy) NSString *userId;//用户id
@property (nonatomic, strong) NSArray *banks;//银行信息
@property (nonatomic, assign) BOOL modifyPwd;//是否已经设置密码
@property (nonatomic, strong) YZUserInfo *user;//用户信息
@property (nonatomic, strong) YZWeixin *weixin;

@end

