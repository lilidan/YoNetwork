//
//  JVCookieManager.m
//  iosframework
//
//  Created by zyma on 2017/7/31.
//  Copyright © 2017年 ljs. All rights reserved.
//

#import "YoCookieManager.h"

@implementation YoCookieManager {
    HTTPDNSCookieFilter cookieFilter;
}

- (instancetype)init {
    if (self = [super init]) {
        /**
         此处设置的Cookie和URL匹配策略比较简单，检查URL.host是否包含Cookie的domain字段
         通过调用setCookieFilter接口设定Cookie匹配策略，
         比如可以设定Cookie的domain字段和URL.host的后缀匹配 | URL是否符合Cookie的path设定
         细节匹配规则可参考RFC 2965 3.3节
         */
        cookieFilter = ^BOOL(NSHTTPCookie *cookie, NSURL *URL) {
            if ([URL.host containsString:cookie.domain]) {
                return YES;
            }
            return NO;
        };
    }
    return self;
}

+ (instancetype)sharedInstance {
    static id singletonInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!singletonInstance) {
            singletonInstance = [[super allocWithZone:NULL] init];
        }
    });
    return singletonInstance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    return [self sharedInstance];
}

- (id)copyWithZone:(struct _NSZone *)zone {
    return self;
}

- (void)setCookieFilter:(HTTPDNSCookieFilter)filter {
    if (filter != nil) {
        cookieFilter = filter;
    }
}

- (NSArray<NSHTTPCookie *> *)handleHeaderFields:(NSURLResponse *)urlResponse requestModel:(YoNetworkBaseRequest *)requestModel {
        if (urlResponse && [urlResponse isKindOfClass:[NSHTTPURLResponse class]] ) {
            NSString *requestURL_s = [requestModel baseUrl];
            if (requestURL_s != nil && requestURL_s.length > 0) {
                NSURL *requestURL = [NSURL URLWithString:requestURL_s];
                return  [self handleHeaderFields:[(NSHTTPURLResponse *)urlResponse allHeaderFields] forURL:requestURL];
            }
        }
    return nil;
}

- (NSArray<NSHTTPCookie *> *)handleHeaderFields:(NSDictionary *)headerFields forURL:(NSURL *)URL {
    NSArray *cookieArray = [NSHTTPCookie cookiesWithResponseHeaderFields:headerFields forURL:URL];
    if (cookieArray != nil) {
        NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in cookieArray) {
            if (cookieFilter(cookie, URL)) {
                [cookieStorage setCookie:cookie];
            }
        }
    }
    return cookieArray;
}

- (NSString *)getRequestCookieHeaderForURL:(NSURL *)URL {
    NSArray *cookieArray = [self searchAppropriateCookies:URL];
    if (cookieArray != nil && cookieArray.count > 0) {
        NSDictionary *cookieDic = [NSHTTPCookie requestHeaderFieldsWithCookies:cookieArray];
        if ([cookieDic objectForKey:@"Cookie"]) {
            return cookieDic[@"Cookie"];
        }
    }
    return nil;
}

- (NSArray *)searchAppropriateCookies:(NSURL *)URL {
    NSMutableArray *cookieArray = [NSMutableArray array];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if (cookieFilter(cookie, URL)) {
            [cookieArray addObject:cookie];
        }
    }
    return cookieArray;
}

- (NSInteger)deleteCookieForURL:(NSURL *)URL {
    int delCount = 0;
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieStorage cookies]) {
        if (cookieFilter(cookie, URL)) {
            [cookieStorage deleteCookie:cookie];
            delCount++;
        }
    }
    return delCount;
}


@end
