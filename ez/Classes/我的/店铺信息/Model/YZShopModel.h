//
//  YZShopModel.h
//  zc
//
//  Created by dahe on 2020/4/14.
//  Copyright © 2020 9ge. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YZShopPayModel : NSObject

@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *imgUrl;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;

@end

@interface YZShopModel : NSObject

@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *headUrl;
@property (nonatomic, copy) NSString *id;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *notice;
@property (nonatomic, copy) NSString *phone;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSArray *payList;

@end

NS_ASSUME_NONNULL_END
