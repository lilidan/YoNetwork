//
//  NSURLErrorChinese.h
//  YoNetwork
//
//  Created by sgcy on 2019/9/11.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSErrorDomain const YoNetworkHTTPErrorDomain;
FOUNDATION_EXTERN NSErrorDomain const YoNetworkLogicErrorDomain;

@interface NSError(Chinese)

- (NSError *)chineseError;

@end
