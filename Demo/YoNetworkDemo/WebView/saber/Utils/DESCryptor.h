//
//  DESCryptor.h
//  webApp
//
//  Created by gaoanjie on 14-4-28.
//  Copyright (c) 2014年 lufax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DESCryptor : NSObject

/**
 加密字符串

 @param text 要加密的文字
 @param key 密钥
 @return 加密好的密文
 */
+ (NSString*)base64StringFromText:(NSString*)text key:(NSString*)key;


/**
 解密字符串

 @param base64 密文
 @param key 密钥
 @return 解密的明文
 */
+ (NSString*)textFromBase64String:(NSString*)base64 key:(NSString*)key;


/**
 加密Data
 
 @param sourceData 要加密的Data
 @param key 密钥
 @return 加密好的密文
 */
+ (NSString*)base64StringFromData:(NSData*)sourceData withKey:(NSString*)key;


/**
 解密Data
 
 @param sourceText 密文
 @param key 密钥
 @return 解密的Data
 */
+ (NSData*)dataFromBase64String:(NSString*)sourceText withKey:(NSString*)key; // 解密 NSData


/**
 Deprecated！请使用base64StringFromData:withKey:

 @param sourceData 要加密的数据
 @param key 密钥
 @return 加密好的data
 */
+ (NSData*)encryptData:(NSData*)sourceData withKey:(NSString*)key;


/**
 Deprecated! 请使用base64StringFromData:withKey:  和一直配套的dataFromBase64String:withKey:

 @param sourceData 密文
 @param key 密钥
 @return 明文数据
 */
+ (NSData*)decryptData:(NSData*)sourceData withKey:(NSString*)key;
@end
