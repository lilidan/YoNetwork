//
//  YoNetworkAgent.m
//  YoNetwork
//
//  Created by sgcy on 2019/8/6.
//

#import "YoNetworkAgent.h"
#import "AFHTTPSessionManager.h"
#import "YoNetworkBaseRequest.h"
#import <pthread/pthread.h>
#import <objc/runtime.h>
#import "JSONModel.h"
#import "YoNetworkConfig.h"
#import "YoNetworkResponse.h"

static const float kDefaultDelayInSeconds = 1.0f;
static const float kDefaultRetryMaxCount = 0;

@interface YoNetworkAgent()

@property (nonatomic, strong) AFHTTPSessionManager *urlSessionManager;

@property (nonatomic, strong) AFJSONResponseSerializer *jsonResponseSerializer;
@property (nonatomic, strong) AFHTTPResponseSerializer *httpResponseSerializer;
@property (nonatomic, strong) AFSecurityPolicy *securityPolicy;
@property (nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, YoNetworkBaseRequest *> *requestsRecord;
@property (nonatomic, strong) NSMutableSet<YoNetworkBaseRequest *> *retryRequests;
@property (nonatomic, strong) dispatch_queue_t requestOperateQueue;


@end


@implementation YoNetworkAgent

+ (instancetype)sharedAgent {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        AFHTTPResponseSerializer *responseSer = [AFHTTPResponseSerializer new];
        _urlSessionManager = [AFHTTPSessionManager manager];
        _urlSessionManager.operationQueue.maxConcurrentOperationCount = 5;
        _jsonResponseSerializer = [AFJSONResponseSerializer serializer];
        _httpResponseSerializer = [AFHTTPResponseSerializer serializer];
        _requestOperateQueue = dispatch_queue_create("yonetwork_request_operate_queue", DISPATCH_QUEUE_SERIAL);
        _requestsRecord = [[NSMutableDictionary alloc] init];
        _retryRequests = [[NSMutableSet alloc] init];
        self.config = [YoNetworkConfig config];
    }
    return self;
}

- (void)setConfig:(YoNetworkConfig *)config
{
    _config = config;
    if (_config.httpsVerifyLevel == YoNetworkHTTPSVerifyLevelNone) {
        [self closeHttpsCertificateVerify];
    }else if (_config.httpsVerifyLevel == YoNetworkHTTPSVerifyLevelValidCertificate){
        [self closeSSLPinning];
    }else{
        [self openSSLPinning];
    }
}

#pragma mark - requests

- (void)addRequestToRecord:(YoNetworkBaseRequest *)request {
    dispatch_async(_requestOperateQueue, ^{
        _requestsRecord[@(request.task.taskIdentifier)] = request;
    });
}

- (void)removeRequestFromRecord:(YoNetworkBaseRequest *)request {
    dispatch_async(_requestOperateQueue, ^{
        [_requestsRecord removeObjectForKey:@(request.task.taskIdentifier)];
    });
}

- (void)addRequest:(YoNetworkBaseRequest *)request
{
    AFHTTPRequestSerializer *ser = [self requestSerializerForRequest:request];
    NSString *url = [request requestPath];
    url = [[request baseUrl] stringByAppendingString:url];
    id params = [request requestArgument];
    NSError *requestSerializationError = nil;
    NSURLRequest *urlRequest = [ser requestWithMethod:(request.requestMethod == YoNetworkRequestMethodPOST ? @"POST" : @"GET") URLString:url parameters:params error:&requestSerializationError];
    
    //request serialization error
    if (requestSerializationError) {
        request.handler(nil, requestSerializationError);
        return;
    }
    
    NSURLSessionDataTask *task = [_urlSessionManager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        [self handleResponse:response responseObject:responseObject error:error fromRequest:request];
        //release request object
        [self removeRequestFromRequest:request];
    }];
    
    request.task = task;
    [self addRequestToRecord:request];
    [task resume];
}

- (void)cancelRequest:(YoNetworkBaseRequest *)request
{
    [request.task cancel];
    [self removeRequestFromRecord:request];
    [request clearCompletionBlock];
}

- (void)cancelAll:(BOOL)cancelPendingTasks
{
    dispatch_async(_requestOperateQueue, ^{
        NSArray *allKeys = [_requestsRecord allKeys];
        for (NSNumber *key in allKeys) {
            YoNetworkBaseRequest *request = _requestsRecord[key];
            [self cancelRequest:request];
        }
    });
}

- (AFHTTPRequestSerializer *)requestSerializerForRequest:(YoNetworkBaseRequest *)request {
    
    AFHTTPRequestSerializer *requestSerializer;
    if ([request requestSerializerType] == YoNetworkRequestSerializerTypeHTTP) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    }else{
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

#pragma mark - responses

- (void)handleResponse:(NSHTTPURLResponse *)response responseObject:(id)responseObject error:(NSError *)error fromRequest:(YoNetworkBaseRequest *)request {

    //request cancelled
    if (!request) {
        return;
    }
    
    Class responseModelClass = [request responseClass];
    if ([responseModelClass isKindOfClass:[YoNetworkResponse class]]) {
        YoNetworkResponse *reponseContainer = [[responseModelClass alloc] init];
        reponseContainer.response = response;
        reponseContainer.responseObject = responseObject;
        request.handler(reponseContainer, error);
        return;
    }
    
    if (error) {
        [self addRetryRequest:request];
        request.handler(nil, error);
        return;
    }
    
    //http check
    if (response.statusCode < 200 || response.statusCode >= 400) {
        //Wrong
        request.handler(nil, nil);
        return;
    }
    
    if (!responseObject || !responseModelClass) {
        request.handler(responseObject, error);
        return;
    }
    
    //json Serializer
    if ([responseObject isKindOfClass:[NSData class]]) {
        if (request.responseSerializerType == YoNetworkResponseSerializerTypeJSON) {
            responseObject = [self.jsonResponseSerializer responseObjectForResponse:response data:responseObject error:&error];
        }else{
            responseObject = [self.httpResponseSerializer responseObjectForResponse:response data:responseObject error:&error];
        }
        if (error) {
            request.handler(nil, error);
            return;
        }
    }
    
    // logic handler
    responseObject = [request responseLogicHandler:responseObject error:&error];
    if (error) {
        request.handler(nil, error);
        return;
    }
    
    // json model Serializer
    id model;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        model = [[responseModelClass alloc] initWithDictionary:responseObject error:&error];
    }else if ([responseObject isKindOfClass:[NSArray class]]){
        model = [JSONModel arrayOfModelsFromDictionaries:responseObject error:&error];
    }

    if (error) {
        request.handler(nil, error);
    }else{
        request.handler(model, nil);
    }
   
}

- (void)removeRequestFromRequest:(YoNetworkBaseRequest *)request
{
    [self removeRequestFromRecord:request];
    dispatch_async(dispatch_get_main_queue(), ^{
        [request clearCompletionBlock];
    });
}

- (NSStringEncoding)stringEncodingWithResponse:(NSURLResponse *)response {
    // From AFNetworking 2.6.3
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}

#pragma mark - retry

- (AFNetworkReachabilityManager *)reachabilityManager
{
    if (!_reachabilityManager) {
        _reachabilityManager = [AFNetworkReachabilityManager manager];
        __weak typeof(self) weakSelf = self;
        [_reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status >= AFNetworkReachabilityStatusReachableViaWWAN ) {
                [weakSelf retryRequests];
            }
        }];
    }
    return _reachabilityManager;
}

- (void)addRetryRequest:(YoNetworkBaseRequest *)request
{
    if ([request retryForReachablity]) {
        dispatch_async(_requestOperateQueue, ^{
            if (self.retryRequests.count == 0) {
                [self.reachabilityManager startMonitoring];
            }
            [self.retryRequests addObject:request];
        });
    }
}

- (void)retryRequests
{
    for (YoNetworkBaseRequest *request in self.retryRequests) {
        [self addRequest:request];
    }
    dispatch_async(_requestOperateQueue, ^{
        [self.retryRequests removeAllObjects];
        [self.reachabilityManager stopMonitoring];
    });
    
}

#pragma mark - https

- (void)closeSSLPinning{
    _securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [_securityPolicy setAllowInvalidCertificates:NO];
    [_securityPolicy setValidatesDomainName:YES];
    [_urlSessionManager setSecurityPolicy:_securityPolicy];
}

- (void)openSSLPinning{
    _securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
    [_securityPolicy setAllowInvalidCertificates:NO];
    [_securityPolicy setValidatesDomainName:YES];
    [_urlSessionManager setSecurityPolicy:_securityPolicy];
}

- (void)closeHttpsCertificateVerify{
    _securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [_securityPolicy setAllowInvalidCertificates:YES];
    [_securityPolicy setValidatesDomainName:NO];
    [_urlSessionManager setSecurityPolicy:_securityPolicy];
}

@end
