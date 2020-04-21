//
//  YZHttpTool.h
//  ez
//
//  Created by apple on 14-8-7.
//  Copyright (c) 2014年 9ge. All rights reserved.
//
typedef enum : NSUInteger {
    sortTypeAscending = 1,//1：升序
    sortTypeDescending = 2,//2：降序
} SortType;

typedef enum : NSUInteger {
    fieldTypeOrderByMoney = 1,//1：金额排序
    fieldTypeOrderByProgress = 2,//2：进度排序
    fieldTypeOrderByRecord = 3,//3：战绩排序
} FieldType;


typedef enum : NSUInteger {
    AccountRecordTypeMyBet = 0,//我的投注
    AccountRecordTypeMyScheme = 1,//我的追号
    AccountRecordTypeMyUnionBuy = 3,//我的合买
} AccountRecordType;

typedef enum : NSUInteger {
    ChooseNumberByBirthday = 1,
    ChooseNumberByPhone = 2,
    ChooseNumberByLuckyNumber = 3,
} ChooseNumberType;

#define mainChannel @"sta"

////预发布环境
//#define baseUrl @"http://www1.51mcp.com"
//#define shareBaseUrl @"http://stage.ez1898.com"
//#define mcpUrl [NSString stringWithFormat:@"%@/portal/gateway",baseUrl]
//#define childChannel @"zc_taylor"

//正式环境
#define jgBaseUrl @"http://www1.51mcp.com"
#define baseUrl @"http://admin.jifengo.online/gateway"
#define shareBaseUrl @"https://cp.ez1898.com"
#define childChannel @"sta_ios"

////测试环境
//#define baseUrl @"http://c.ez1898.com"
//#define shareBaseUrl @"http://test.ez1898.com"
//#define mcpUrl [NSString stringWithFormat:@"%@/portral/gateway",baseUrl]
//#define childChannel @"zhongcai_ios"

//URL
#define baseH5Url @"http://s.51mcp.com"

#define BaseUrl(param) [NSString stringWithFormat:@"%@/%@", jgBaseUrl, param]
//极光推送url
#define BaseUrlJiguang(param) [NSString stringWithFormat:@"%@/jiguang%@",jgBaseUrl,param]
//代金券url
#define BaseUrlCoupon(param) [NSString stringWithFormat:@"%@/coupon%@",jgBaseUrl,param]
//轮播图
#define BaseUrlAdvert(param) [NSString stringWithFormat:@"%@/advert%@",jgBaseUrl,param]
//竞彩开奖
#define BaseUrlJingcai(param) [NSString stringWithFormat:@"%@/jingcai%@",jgBaseUrl,param]
//充值方式
#define BaseUrlSalesManager(param) [NSString stringWithFormat:@"%@/sales-manager%@",jgBaseUrl,param]
//中奖轮播
#define BaseUrlNotice(param) [NSString stringWithFormat:@"%@/notice%@",jgBaseUrl,param]
//竞彩比赛详情
#define BaseUrlFootball(param) [NSString stringWithFormat:@"%@/football%@",jgBaseUrl,param]
//环信
#define BaseUrlEasemob(param) [NSString stringWithFormat:@"%@/easemob%@",jgBaseUrl,param]
//分享
#define BaseUrlShare(param) [NSString stringWithFormat:@"%@/promotion%@", jgBaseUrl, param]
//预测
#define BaseUrlInformation(param) [NSString stringWithFormat:@"%@/information%@", jgBaseUrl, param]
//积分
#define BaseUrlPoint(param) [NSString stringWithFormat:@"%@/point%@", jgBaseUrl, param]
//彩友圈
#define BaseUrlCircle(param) [NSString stringWithFormat:@"%@/information-platform%@", jgBaseUrl, param]

#import <Foundation/Foundation.h>
#import "MJExtension.h"

@interface YZHttpTool : NSObject

+ (YZHttpTool *)shareInstance;
/**
 *  判断网络状态的POST请求
 */
- (void)requestTarget:(UIViewController*)target PostWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure;
- (void)requestTarget:(UIViewController*)target PostWithParams:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure;
/**
 *  发送一个POST请求
 *
 *  @param url     请求路径
 *  @param params  请求参数
 *  @param success 请求成功后的回调
 *  @param failure 请求失败后的回调
 */
- (void)postWithParams:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
- (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id json))success failure:(void (^)(NSError *error))failure;
//合买大厅获取合买数据
- (void)getUnionBuyStatusWithUserName:(NSString *)userName gameId:(NSString *)gameId sortType:(SortType)sortType fieldType:(FieldType)fieldType  index:(NSInteger)index getSuccess:(void(^)(NSArray *unionBuys))getSuccess getFailure:(void(^)())getFailure;
#pragma mark - 图片上传
- (void)uploadWithURL:(NSString *)url image:(UIImage *)image currentIndex:(NSInteger)currentIndex totalCount:(NSInteger)totalCount Success:(void (^)(id json))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent;
- (void)uploadWithImage:(UIImage *)image currentIndex:(NSInteger)currentIndex totalCount:(NSInteger)totalCount aliOssToken:(NSDictionary *)aliOssToken Success:(void (^)(NSString * picUrl))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent;
#pragma mark - 获取设备当前网络IP地址
- (NSString *)getIPAddress:(BOOL)preferIPv4;

@end
