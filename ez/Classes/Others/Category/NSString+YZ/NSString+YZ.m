//
//  NSString+YZ.m
//  ez
//
//  Created by apple on 14-11-3.
//  Copyright (c) 2014年 9ge. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+YZ.h"

@implementation NSString (YZ)

- (NSString *)md5HexDigest
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, (CC_LONG)strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [hash appendFormat:@"%02X", result[i]];
    }
    NSString *mdfiveString = [hash lowercaseString];
    return mdfiveString;
}

- (NSString *)URLEncodedString
{
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                             (CFStringRef)self,
                                                                                             NULL,
                                                                                             CFSTR("!*'();:@&=+$,%#[]/"),
                                                                                             kCFStringEncodingUTF8));
    return result;
}

- (NSMutableAttributedString *)attributedString:(NSDictionary *)attrs WithRange:(NSRange)range
{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self];
    if(range.location < self.length)
    {
        [attStr addAttributes:attrs range:range];
    }
    return attStr;
}

- (NSMutableAttributedString *)attributedStringWithAttributs:(NSDictionary *)attrs firstString:(NSString *)firstString secondString:(NSString *)secondString
{
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:self];
    NSRange range1 = [self rangeOfString:firstString];
    NSRange range2 = [self rangeOfString:secondString];
    [attStr addAttributes:attrs range:NSMakeRange(range1.location + 1, range2.location - range1.location - 1)];
    return attStr;
}

- (CGSize)sizeWithLabelFont:(UIFont *)font
{
    return [self sizeWithFont:font maxSize:CGSizeMake(screenWidth, screenHeight)];
}

- (CGSize)sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    CGSize size = [self boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    return size;
}

@end
