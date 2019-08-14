//
//  Utility.m
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/12.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import "Utility.h"
#define kIntegerMinDigit     7

@implementation Utility


//查找string里有keys中任意的一个key的值为大于8位的整数
+(NSDictionary *)luGreaterThanMinDigitIntegerFromJavaScriptString:(NSString *)string
                                                          forKeys:(NSArray *)keys
                                                       defaultKey:(NSString *)defaKey
{
    if (string == nil || keys.count==0) {
        return nil;
    }
    NSMutableDictionary *needDigit = [NSMutableDictionary new];
    NSString *digitParameter = [self luFetchDigitParameterInJSONFromJavaScriptString:string jsonKeys:keys];
    if (digitParameter && digitParameter.length>0 && defaKey) {
        [needDigit setObject:digitParameter forKey:defaKey];
    }
    
    if (needDigit.count == 0) { //参数中直接传数字的情况
        NSString *directDigit = [self luFetchDigitParameterDirectnessFromJavaScriptString:string];
        if (directDigit && directDigit.length>0 && defaKey) {
            [needDigit setObject:directDigit forKey:defaKey];
        }
    }
    
    return needDigit;
}

+ (NSString *)luFetchDigitParameterInJSONFromJavaScriptString:(NSString *)string jsonKeys:(NSArray *)keys
{
    NSString *digitParameter = nil;
    for (NSString *curKey in keys) {
        if ([string rangeOfString:curKey].location != NSNotFound) {
            NSArray *components = [string componentsSeparatedByString:curKey];
            if (components.count>1) {
                NSString *valueString = components[1];
                valueString = [self luReplaceSpecialSymbolWithString:valueString];
                valueString = [self luFetchCurrentValueCorrespondingTheKey:valueString];
                if ([self isGreaterThanEightIntegerWithString:valueString]) {
                    digitParameter = [valueString copy];
                    break;
                }
            }
        }
    }
    return digitParameter;
}

+ (NSString *)luFetchDigitParameterDirectnessFromJavaScriptString:(NSString *)string
{
    NSString *valueString = nil;
    NSArray *components = [string componentsSeparatedByString:@"("];
    if (components.count>1) {
        NSString *parameterString = components[1];
        parameterString = [self luReplaceSpecialSymbolWithString:parameterString];
        NSArray *allParameters = [parameterString componentsSeparatedByString:@","];
        for (NSString *curParameter in allParameters) {
            if ([self isGreaterThanEightIntegerWithString:curParameter]) {
                valueString = [curParameter copy];
                break;
            }
        }
    }
    return valueString;
}

+ (NSString *)luFetchCurrentValueCorrespondingTheKey:(NSString *)valueString {
    if ([valueString hasPrefix:@":"]) { //json串格式("key1":"value1","key2":"value2")
        valueString = [[valueString componentsSeparatedByString:@","]firstObject];
        valueString = [valueString stringByReplacingOccurrencesOfString:@":" withString:@""];
    }
    return valueString;
}

+ (BOOL)isGreaterThanEightIntegerWithString:(NSString *)string
{
    if (string == nil || string.length==0) {
        return NO;
    }
    return ([Utility isPureIntegerNumberCharacters:string] && string.length>kIntegerMinDigit);
}


//判断是否为正整数
+ (BOOL)isPureIntegerNumberCharacters:(NSString *)string
{
    NSScanner* scan = [NSScanner scannerWithString:string];
    NSInteger val;
    BOOL isInteger = [scan scanInteger:&val] && [scan isAtEnd];
    return (isInteger && ([string integerValue]>0));
}

+ (NSString *)luReplaceSpecialSymbolWithString:(NSString *)originalString
{
    if (originalString!=nil && originalString.length > 0) {
        originalString = [originalString stringByReplacingOccurrencesOfString:@"\"" withString:@""]; //去掉\"
        originalString = [originalString stringByReplacingOccurrencesOfString:@"}" withString:@""];  //去掉}
        originalString = [originalString stringByReplacingOccurrencesOfString:@")" withString:@""];  //去掉)
        originalString = [originalString stringByReplacingOccurrencesOfString:@"'" withString:@""];  //去掉‘
    }
    return originalString;
}


@end
