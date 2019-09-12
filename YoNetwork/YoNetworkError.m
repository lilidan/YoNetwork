//
//  NSURLErrorChinese.m
//  YoNetwork
//
//  Created by sgcy on 2019/9/11.
//

#import "YoNetworkError.h"

NSErrorDomain const YoNetworkHTTPErrorDomain = @"YoNetworkHTTPErrorDomain";
NSErrorDomain const YoNetworkLogicErrorDomain = @"YoNetworkLogicErrorDomain";

@implementation NSError(Chinese)

- (NSError *)chineseError
{
    NSString *result = self.localizedDescription;
    switch (self.code) {
        case NSURLErrorUnknown:
            result = @"未知错误";
            break;
        case NSURLErrorCancelled:
            result = @"请求已取消";
            break;
        case NSURLErrorBadURL:
        case NSURLErrorUnsupportedURL:
            result = @"请求URL异常";
            break;
        case NSURLErrorTimedOut:
            result = @"请求超时";
            break;
        case NSURLErrorCannotFindHost:
        case NSURLErrorDNSLookupFailed:
            result = @"DNS解析失败，请稍后再试";
            break;
        case NSURLErrorCannotConnectToHost:
        case NSURLErrorNetworkConnectionLost:
            result = @"无法连接到服务器";
            break;
        case NSURLErrorNotConnectedToInternet:
            result = @"网络连接有问题，请检查手机是否联网";
            break;
        case NSURLErrorBadServerResponse:
            result = @"服务器返回错误";
            break;
        case NSURLErrorUserCancelledAuthentication:
        case NSURLErrorUserAuthenticationRequired:
            result = @"用户校验失败，请重新登录";
            break;
        case NSURLErrorSecureConnectionFailed:
        case NSURLErrorServerCertificateHasBadDate:
        case NSURLErrorServerCertificateUntrusted:
        case NSURLErrorServerCertificateHasUnknownRoot:
        case NSURLErrorServerCertificateNotYetValid:
        case NSURLErrorClientCertificateRejected:
        case NSURLErrorClientCertificateRequired:
            result = @"SSL校验失败，请检查SSL证书";
            break;
        default:
            break;
    }
    NSMutableDictionary *mutUserInfo = [self.userInfo mutableCopy];
    [mutUserInfo setObject:result forKey:NSLocalizedDescriptionKey];
    return [NSError errorWithDomain:self.domain code:self.code userInfo:[mutUserInfo copy]];
}

@end
