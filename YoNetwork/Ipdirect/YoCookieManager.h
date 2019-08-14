//
//  JVCookieManager.h
//  iosframework
//
//  Created by zyma on 2017/7/31.
//  Copyright © 2017年 ljs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YoNetworkBaseRequest.h"

typedef BOOL (^HTTPDNSCookieFilter)(NSHTTPCookie *, NSURL *);

@interface YoCookieManager : NSObject

+ (instancetype)sharedInstance;

/**
 指定URL匹配Cookie策略
 
 @param filter 匹配器
 */
- (void)setCookieFilter:(HTTPDNSCookieFilter)filter;

/**
 处理HTTP Reponse携带的Cookie并存储
 
 @param headerFields HTTP Header Fields
 @param requestModel 请求的requestModel
 @return 返回添加到存储的Cookie
 */
- (NSArray<NSHTTPCookie *> *)handleHeaderFields:(NSURLResponse *)urlResponse requestModel:(YoNetworkBaseRequest *)requestModel;

/**
 匹配本地Cookie存储，获取对应URL的request cookie字符串
 
 @param URL 根据匹配策略指定查找URL关联的Cookie
 @return 返回对应URL的request Cookie字符串
 */
- (NSString *)getRequestCookieHeaderForURL:(NSURL *)URL;

/**
 删除存储cookie
 
 @param URL 根据匹配策略查找URL关联的cookie
 @return 返回成功删除cookie数
 */
- (NSInteger)deleteCookieForURL:(NSURL *)URL;

@end

