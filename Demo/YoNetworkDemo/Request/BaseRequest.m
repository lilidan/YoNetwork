//
//  BaseRequest.m
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/7.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import "BaseRequest.h"

@implementation BaseRequest

- (NSString *)baseUrl
{
    return @"http://nts-app.stg16.lutest.pingan.com";
}

//- (NSString *)baseUrl
//{
//    return @"https://nts-app.pingan.com";
//}

- (YoNetworkRequestSerializerType)requestSerializerType
{
    return YoNetworkRequestSerializerTypeHTTP;
}

- (id)responseLogicHandler:(id)responseObject error:(NSError *__autoreleasing *)error
{
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        id result = [responseObject valueForKey:@"result"];
        NSString *message = [responseObject valueForKey:@"message"];
        NSString *code = [responseObject valueForKey:@"code"];
        if ([code isEqualToString:@"0000"]) {
            return result;
        }else{
            *error = [NSError errorWithDomain:@"NetworkLogicError" code:[code integerValue] userInfo:@{NSLocalizedDescriptionKey:message}];
            return nil;
        }
    }
    *error = [NSError errorWithDomain:@"NetworkLogicError" code:-1000 userInfo:@{NSLocalizedDescriptionKey:@""}];
    return nil;
}

@end

