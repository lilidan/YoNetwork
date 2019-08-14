//
//  DESCryptor.m
//  webApp
//
//  Created by gaoanjie on 14-4-28.
//  Copyright (c) 2014年 lufax. All rights reserved.
//

#import "DESCryptor.h"
#import <CommonCrypto/CommonCryptor.h>
#import "NSData+Base64.h"

@implementation DESCryptor

+ (NSString*)base64StringFromText:(NSString*)text key:(NSString*)key
{
    if (text && text.length > 0) {
        NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
        return [self base64StringFromData:data withKey:key];
    }
    else {
        return nil;
    }
}

+ (NSString*)textFromBase64String:(NSString*)base64 key:(NSString*)key
{
    NSData* clearData = [self dataFromBase64String:base64 withKey:key];
    if (clearData.length > 0) {
        return [[NSString alloc] initWithData:clearData encoding:NSUTF8StringEncoding];
    }else{
        return nil;
    }
}

+ (NSData*)encryptData:(NSData*)sourceData withKey:(NSString*)key{
    if(sourceData == nil){
        return nil;
    }
    
    return [self DESEncrypt:sourceData WithKey:key];
}

+ (NSString*)base64StringFromData:(NSData*)sourceData withKey:(NSString*)key{
    NSData* data =  [self encryptData:sourceData withKey:key];
    if(data){
        return [data base64EncodedStringLF];
    }else{
        return nil;
    }
    
}

+ (NSData*)decryptData:(NSData*)sourceData withKey:(NSString*)key {
    if(sourceData.length == 0){
        return nil;
    }else{
        return [self DESDecrypt:sourceData WithKey:key];
    }
}

+ (NSData*)dataFromBase64String:(NSString*)sourceText withKey:(NSString*)key{
    if (sourceText.length == 0) {
        return nil;
    }
    
    NSData * data = [NSData dataWithBase64EncodedString:sourceText];
    return [self decryptData:data withKey:key];
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES加密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesEncrypted);
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
    }
    
    free(buffer);
    return nil;
}

/******************************************************************************
 函数名称 : + (NSData *)DESEncrypt:(NSData *)data WithKey:(NSString *)key
 函数描述 : 文本数据进行DES解密
 输入参数 : (NSData *)data
 (NSString *)key
 输出参数 : N/A
 返回参数 : (NSData *)
 备注信息 : 此函数不可用于过长文本
 ******************************************************************************/
+ (NSData *)DESDecrypt:(NSData *)data WithKey:(NSString *)key
{
    char keyPtr[kCCKeySizeAES256+1];
    bzero(keyPtr, sizeof(keyPtr));
    
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    NSUInteger dataLength = [data length];
    
    size_t bufferSize = dataLength + kCCBlockSizeAES128;
    void *buffer = malloc(bufferSize);
    
    size_t numBytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmDES,
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, kCCBlockSizeDES,
                                          NULL,
                                          [data bytes], dataLength,
                                          buffer, bufferSize,
                                          &numBytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
    }
    
    free(buffer);
    return nil;
}

@end
