//
//  YoNetworkBaseRequest.h
//  YoNetwork
//
//  Created by sgcy on 2019/8/6.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YoNetworkRequestSerializerType) {
    YoNetworkRequestSerializerTypeHTTP = 0,
    YoNetworkRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, YoNetworkResponseSerializerType) {
    YoNetworkResponseSerializerTypeHTTP,
    YoNetworkResponseSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, YoNetworkRequestMethod) {
    YoNetworkRequestMethodGET,
    YoNetworkRequestMethodPOST
};

typedef void(^YoNetworkResultBlock)(id,NSError *);


// for a kind of request
@protocol YoNetworkBaseRequestProtocol <NSObject>

- (NSString *)baseUrl;
- (YoNetworkRequestMethod)requestMethod;
- (YoNetworkRequestSerializerType)requestSerializerType;
- (YoNetworkResponseSerializerType)responseSerializerType;
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
- (NSTimeInterval)requestTimeoutInterval;
- (BOOL)allowsCellularAccess;
- (id)responseLogicHandler:(id)responseObject error:(__autoreleasing NSError **)error;

@end


@interface YoNetworkBaseRequest : NSObject<YoNetworkBaseRequestProtocol>

@property (nonatomic,copy) YoNetworkResultBlock handler;
@property (nonatomic,strong) NSURLSessionTask *task;

- (void)send:(YoNetworkResultBlock)handler;
- (void)clearCompletionBlock;

// for each request
- (nullable id)requestArgument;
- (NSString *)requestPath;
- (Class)responseClass;
- (Class)agentClass;

- (BOOL)retryForReachablity;

@end
