//
//  NSString+YZ.h
//  ez
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (YZ)

/**
 * md5加密
 */
- (NSString *)md5HexDigest;
/**
 * url编码
 */
- (NSString *)URLEncodedString;
/**
 * 获取attributedString
 */
- (NSMutableAttributedString *)attributedString:(NSDictionary *)attrs WithRange:(NSRange)range;
/**
 * 给字符串俩字间加属性
 */
- (NSMutableAttributedString *)attributedStringWithAttributs:(NSDictionary *)attrs firstString:(NSString *)firstString secondString:(NSString *)secondString;
/**
 *
 *  @param font    字体大小
 *
 *  @return 返回文字所占用的label宽高
 */
- (CGSize)sizeWithLabelFont:(UIFont *)font;
/**
 *
 *  @param font    字体大小
 *  @param maxSize 文字受限区域
 *
 *  @return 返回文字所占用的label宽高
 */
- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end
