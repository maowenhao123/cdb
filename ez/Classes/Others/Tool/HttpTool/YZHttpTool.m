//
//  YZHttpTool.m
//  ez
//
//  Created by apple on 14-8-7.
//  Copyright (c) 2014年 9ge. All rights reserved.
//
#define requestTimeoutInterval 25

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

#import <AliyunOSSiOS/OSSService.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "YZHttpTool.h"
#import "AFHTTPSessionManager.h"
#import "UIViewController+YZNoNetController.h"
#import "YZLoginViewController.h"
#import "YZDateTool.h"

@implementation YZHttpTool
+ (YZHttpTool *)shareInstance
{
    static YZHttpTool *shareInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        shareInstance = [[[self class] alloc] init];
    });
    return shareInstance;
}
/**
 *  判断网络状态的POST请求
 */
- (void)requestTarget:(UIViewController*)target PostWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self checkNetState]) {//有网的时候去请求数据
        [target hiddenNonetWork];
        [self postWithURL:url params:params success:success failure:failure];
    }else{//没网时显示
        [target showNonetWork];
        [MBProgressHUD hideHUDForView:target.view animated:YES];
    }
}

- (void)requestTarget:(UIViewController*)target PostWithParams:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    if ([self checkNetState]) {//有网的时候去请求数据
        [target hiddenNonetWork];
        [self postWithParams:params success:success failure:failure];
    }else{//没网时显示
        [target showNonetWork];
        [MBProgressHUD hideHUDForView:target.view animated:YES];
    }
}

#pragma mark -  请求数据
- (void) postWithParams:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    mgr.requestSerializer = [AFJSONRequestSerializer serializer];
    mgr.requestSerializer.timeoutInterval = requestTimeoutInterval;
    mgr.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    [formatter setDateFormat:@"YYYYMMddhhmmssSSS"];
    NSString *nowDateStr = [formatter stringFromDate:[NSDate date]];
    
    NSString * posternBaseUrl = [YZUserDefaultTool getObjectForKey:@"PosternBaseUrl"];
    NSString * posternMainChannel = [YZUserDefaultTool getObjectForKey:@"PosternMainChannel"];
    NSString * posternChildChannel = [YZUserDefaultTool getObjectForKey:@"PosternChildChannel"];
    if (YZStringIsEmpty(posternBaseUrl)) {
        posternBaseUrl = baseUrl;
    }
    if (YZStringIsEmpty(posternMainChannel)) {
        posternMainChannel = mainChannel;
    }
    if (YZStringIsEmpty(posternChildChannel)) {
        posternChildChannel = childChannel;
    }
    //发送请求
    NSDictionary *dict = @{
        @"id":nowDateStr,
        @"channel":posternMainChannel,
        @"childChannel":posternChildChannel,
        @"clientVersion":[NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
    };
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    [tempDict addEntriesFromDictionary:params];//拼接参数
    [mgr POST:posternBaseUrl
   parameters:tempDict
     progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            
            failure(error);
            NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
            NSInteger statusCode = response.statusCode;
            YZLog(@"error:%ld",statusCode);
            
            YZLog(@"系统繁忙 - YZHttpTool：%@",[NSString stringWithFormat:@"cmd=%@,error=%@",params[@"cmd"],error]);
            
            NSNumber *cmd = tempDict[@"cmd"];
            NSNumber *cmd1 = @(8026);//普通投注获取当期期次
            NSNumber *cmd2 = @(8027);//获取所有彩种信息
            NSNumber *cmd3 = @(8028);//竞彩足球投注获取当期期次
            if(!([cmd isEqualToNumber:cmd1] || [cmd isEqualToNumber:cmd2] || [cmd isEqualToNumber:cmd3]))//这俩个接口，获取不到数据会每秒提醒一次，故不提醒
            {
                if ([self checkNetState]) {
                    [MBProgressHUD showError:@"加载失败，请稍后再试"];
                }else
                {
                    [MBProgressHUD showError:@"亲~~~网络不给力..."];
                }
            }
        }
    }];
}

- (void)postWithURL:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSString * posternMainChannel = [YZUserDefaultTool getObjectForKey:@"PosternMainChannel"];
    NSString * posternChildChannel = [YZUserDefaultTool getObjectForKey:@"PosternChildChannel"];
    if (YZStringIsEmpty(posternMainChannel)) {
        posternMainChannel = mainChannel;
    }
    if (YZStringIsEmpty(posternChildChannel)) {
        posternChildChannel = childChannel;
    }
    
    NSString * IP = [self getIPAddress:NO];
    if ([IP isEqualToString:@"0.0.0.0"]) {
        IP = [self getIPAddress:YES];
    }
    NSDateFormatter * formatter = [[NSDateFormatter alloc ] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    NSString *nowDateStr = [formatter stringFromDate:[NSDate date]];
    NSString * imei = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSDictionary *dict = @{
        @"ip": IP,
        @"timestamp": nowDateStr,
        @"channel": posternMainChannel,
        @"childChannel": posternChildChannel,
        @"clientVersion": [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"],
        @"id": [YZTool uuidString],
        @"deviceNumber": imei,
    };
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (![tempDict.allKeys containsObject:@"version"]) {
        [tempDict setValue:@"0.0.1" forKey:@"version"];
    }
    [tempDict addEntriesFromDictionary:params];//拼接参数
    NSString * jsonDict = [self toJSONString:tempDict];
    NSString * sign = [NSString stringWithFormat:@"%@123456", jsonDict];
    NSString * signMd5 = [sign md5HexDigest];
    NSString * tempUrl = [NSString stringWithFormat:@"%@%@?sign=%@", baseUrl, url, signMd5];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:tempUrl]];
    request.HTTPMethod = @"POST";
    NSDictionary *headers = @{
      @"Content-Type": @"application/json;charset=UTF-8"
    };
    request.allHTTPHeaderFields = headers;
    NSData *postData = [[NSData alloc] initWithData:[jsonDict dataUsingEncoding:NSUTF8StringEncoding]];
    request.HTTPBody = postData;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    //建立任务
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(),^{//主线程
            if (!error) {
                //解析
                NSMutableDictionary *mDict = [NSMutableDictionary dictionary];
                NSError * jsonError;
                mDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
                if ([mDict[@"retCode"] intValue] == 1004) {
                    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:@"温馨提示" message:mDict[@"retDesc"] preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction * alertAction2 = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        YZLoginViewController *loginVC = [[YZLoginViewController alloc] init];
                        YZNavigationController *loginNVC = [[YZNavigationController alloc] initWithRootViewController:loginVC];
                        [UIApplication sharedApplication].keyWindow.rootViewController = loginNVC;
                    }];
                    [alertController addAction:alertAction2];
                    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:nil];
                }else
                {
                    success(mDict);
                }
            }else
            {
                failure(error);
            }
        });
    }];
    //启动任务
    [task resume];
}

#pragma mark - 获取合买数据
- (void)getUnionBuyStatusWithUserName:(NSString *)userName gameId:(NSString *)gameId sortType:(SortType)sortType fieldType:(FieldType)fieldType  index:(NSInteger)index getSuccess:(void(^)(NSArray *unionBuys))getSuccess getFailure:(void(^)())getFailure
{
    NSMutableDictionary *dict = [@{
        @"cmd":@(8120),
        @"sort":@(1),//1：升序、2：降序
        @"field":@(1),//1：金额排序、2：进度排序、3：战绩排序
        @"pageIndex":@(index),
        @"pageSize":@(10),
    } mutableCopy];
    
    if(userName) [dict setValue:userName forKey:@"userName"];
    if(gameId) [dict setValue:gameId forKey:@"gameId"];
    if(sortType > 0) [dict setValue:@(sortType) forKey:@"sort"];
    if(fieldType > 0) [dict setValue:@(fieldType) forKey:@"field"];
    
    [[YZHttpTool shareInstance] postWithParams:dict success:^(id json) {
        
        YZLog(@"getAllUnionBuyStatusWithUserName - json = %@",json);
        if(SUCCESS)
        {
            getSuccess(json[@"unionBuys"]);
        }else
        {
            [MBProgressHUD showError:json[@"retDesc"]];
            getFailure();
        }
        
    } failure:^(NSError *error) {
        getFailure();
    }];
}

#pragma mark - 上传图片
- (void)uploadWithURL:(NSString *)url image:(UIImage *)image currentIndex:(NSInteger)currentIndex totalCount:(NSInteger)totalCount Success:(void (^)(id json))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent
{
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:KEY_WINDOW animated:YES];
    HUD.mode = MBProgressHUDModeAnnularDeterminate;//圆环作为进度条
    if (totalCount == 1)
    {
        HUD.label.text = @"图片上传中....";
    }else
    {
        HUD.label.text = [NSString stringWithFormat:@"%ld/%ld图片上传中....", (long)currentIndex, totalCount];
    }
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager POST:[NSString stringWithFormat:@"%@%@", baseUrl, url] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        NSData * data = UIImageJPEGRepresentation(image, 1.0);
        CGFloat dataKBytes = data.length/1000.0;
        CGFloat maxQuality = 0.9f;
        CGFloat lastData = dataKBytes;
        while (dataKBytes > 300 && maxQuality > 0.01f) {
            maxQuality = maxQuality - 0.01f;
            data = UIImageJPEGRepresentation(image, maxQuality);
            dataKBytes = data.length / 1000.0;
            if (lastData == dataKBytes) {
                break;
            }else{
                lastData = dataKBytes;
            }
        }
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        // 设置时间格式
        formatter.dateFormat = @"yyyyMMddHHmmss";
        NSString *str = [formatter stringFromDate:[NSDate date]];
        NSString *fileName = [NSString stringWithFormat:@"%@.png", str];
        [formData appendPartWithFileData:data name:@"file" fileName:fileName mimeType:@"image/png"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD.progress = uploadProgress.fractionCompleted;
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
        [HUD hideAnimated:YES];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        failure(error);
        [HUD hideAnimated:YES];
    }];
}

- (void)uploadWithImage:(UIImage *)image currentIndex:(NSInteger)currentIndex totalCount:(NSInteger)totalCount aliOssToken:(NSDictionary *)aliOssToken Success:(void (^)(NSString * picUrl))success Failure:(void (^)(NSError * error))failure Progress:(void(^)(float percent))percent
{
    __block MBProgressHUD *HUD;
    dispatch_async(dispatch_get_main_queue(), ^{
        HUD = [MBProgressHUD showHUDAddedTo:KEY_WINDOW animated:YES];
        HUD.mode = MBProgressHUDModeAnnularDeterminate;//圆环作为进度条
        if (totalCount == 1)
        {
            HUD.label.text = @"图片上传中....";
        }else
        {
            HUD.label.text = [NSString stringWithFormat:@"%ld/%ld图片上传中....", (long)currentIndex, totalCount];
        }
    });
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = aliOssToken[@"bucket"];
    // 设置时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *str = [formatter stringFromDate:[NSDate date]];
    NSString *fileName = [NSString stringWithFormat:@"%@%@.png", aliOssToken[@"path"], str];
    put.objectKey = fileName;
    NSData * data = UIImageJPEGRepresentation(image, 1.0);
    CGFloat dataKBytes = data.length/1000.0;
    CGFloat maxQuality = 0.9f;
    CGFloat lastData = dataKBytes;
    while (dataKBytes > 300 && maxQuality > 0.01f) {
        maxQuality = maxQuality - 0.01f;
        data = UIImageJPEGRepresentation(image, maxQuality);
        dataKBytes = data.length / 1000.0;
        if (lastData == dataKBytes) {
            break;
        }else{
            lastData = dataKBytes;
        }
    }
    put.uploadingData = data; // 直接上传NSData
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        percent(1.0 * totalByteSent / totalBytesExpectedToSend);
        dispatch_async(dispatch_get_main_queue(), ^{
            HUD.progress = 1.0 * totalByteSent / totalBytesExpectedToSend;
        });
    };
    NSString *endpoint = [NSString stringWithFormat:@"%@", aliOssToken[@"url"]];
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:aliOssToken[@"accessKeyId"] secretKeyId:aliOssToken[@"accessKeySecret"] securityToken:aliOssToken[@"securityToken"]];
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        task = [client presignPublicURLWithBucketName:aliOssToken[@"bucket"]
                                        withObjectKey:fileName];
        if (!task.error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hideAnimated:YES];
                success(task.result);
                NSLog(@"result%@", task.result);
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [HUD hideAnimated:YES];
                failure(task.error);
                NSLog(@"error%@", task.error);
            });
        }
        return putTask;
    }];
}

#pragma mark - 网络变化
/**
 *  判断网络状态
 *
 *  @return 返回状态 YES 为有网 NO 为没有网
 */
- (BOOL)checkNetState
{
    /*
     AFNetworkReachabilityStatusUnknown          = -1,
     AFNetworkReachabilityStatusNotReachable     = 0,
     AFNetworkReachabilityStatusReachableViaWWAN = 1,
     AFNetworkReachabilityStatusReachableViaWiFi = 2,
     */
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

#pragma mark - 获取设备当前网络IP地址
- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
        address = addresses[key];
        //筛选出IP地址格式
        if([self isValidatIP:address]) *stop = YES;
    } ];
    return address ? address : @"0.0.0.0";
}

- (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            return YES;
        }
    }
    return NO;
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

- (NSString *)toJSONString:(NSDictionary *)dic {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                   options:NSJSONReadingMutableLeaves | NSJSONReadingAllowFragments
                                                     error:nil];
    
    if (data == nil) {
        return nil;
    }
    
    NSString *string = [[NSString alloc] initWithData:data
                                             encoding:NSUTF8StringEncoding];
    return string;
}

@end
