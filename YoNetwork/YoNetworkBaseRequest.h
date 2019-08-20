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



@interface YoNetworkBaseRequest : NSObject

@property (nonatomic,copy) YoNetworkResultBlock handler;
@property (nonatomic,strong) NSURLSessionTask *task;

@property (nonatomic,strong) id requestArgument;
@property (nonatomic,strong) NSString *requestPath;
@property (nonatomic,strong) NSString *baseUrl;
@property (nonatomic,assign) YoNetworkRequestMethod requestMethod;


- (void)send:(YoNetworkResultBlock)handler;
- (void)clearCompletionBlock;

- (NSString *)baseUrl;
- (NSString *)requestPath;
- (id)requestArgument;

- (Class)responseClass;
- (Class)agentClass;

- (YoNetworkRequestMethod)requestMethod;
- (YoNetworkRequestSerializerType)requestSerializerType;
- (YoNetworkResponseSerializerType)responseSerializerType;
- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
- (NSTimeInterval)requestTimeoutInterval;
- (id)responseLogicHandler:(id)responseObject error:(__autoreleasing NSError **)error;

- (BOOL)allowsCellularAccess;
- (BOOL)retryForReachablity;

@end
