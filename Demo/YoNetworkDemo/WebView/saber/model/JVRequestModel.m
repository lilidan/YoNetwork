#import "JVRequestModel.h"

@implementation JVResponseModel


@end

@interface JVRequestModel ()

@property (nonatomic, strong, readwrite) NSDictionary *metrics;
@property (nonatomic, readwrite) NSUUID *__requestID;
@property (nonatomic, strong) NSDate *__startTime;       // 服务开始时间
@property (nonatomic, assign) NSTimeInterval __responseTime;    // 服务结束时间
@property (nonatomic, copy) NSString *__ip;
@property (nonatomic, assign) BOOL __retry; // YES:失败重发 NO:失败不从发 ，默认值是NO
@property (nonatomic, assign) NSInteger __retryMaxCount; // 是否重发最大次数，默认重发2次
@property (nonatomic, assign) NSInteger __currentRertyCount; // 当前重试次数
@end

@implementation JVRequestModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.__requestID = [NSUUID UUID];
    }
    return self;
}

//默认值
-(void)setDefaultValue{
    _task=@"init";
    _method=@"GET";
    _isCache = @"1";
    _isShowLoading=@"1";
    _isLoadingMask=@"0";
    _loadingContent=@"";
    _callback=@"render";
    _postData=@{};
    _headers=@{};
    _version=@"1";
}

-(void)modelDidCreateFromDictionary{}

- (NSString *)requestURL{
    return self.url;
}

- (NSString *)requestMethod{
    return self.method;
}

- (NSDictionary *)requestData{
    return self.postData;
}

- (NSTimeInterval)timeoutInterval{
    return 15;
}

- (NSMutableDictionary *)httpHeaders{
    return [self.headers mutableCopy];
}

- (NSUUID *)requestID{
    return self.__requestID;
}

- (void)setStartTime:(NSDate *)startTime{
    self.__startTime = startTime;
}

- (NSDate *)startTime{
    return self.__startTime;
}

- (void)setResponseTime:(NSTimeInterval)responseTime{
    self.__responseTime = responseTime;
}

- (NSTimeInterval)responseTime{
    return self.__responseTime;
}

- (void)setTransactionMetrics:(NSDictionary *)transactionMetrics {
    _metrics = transactionMetrics;
}

- (NSDictionary *)transactionMetrics {
    return _metrics;
}

- (NSString *)remoteIP{
    return self.__ip;
}

- (void)setRemoteIP:(NSString *)IP{
    self.__ip = IP;
}

- (void)setIfRetry:(BOOL)retry{
    self.__retry = retry;
}

- (BOOL)ifRetry{
    return self.__retry;
}

- (void)setMaxRetryCount:(NSInteger)maxRetryCount{
    self.__retryMaxCount = maxRetryCount;
}

- (NSInteger)maxRetryCount{
    return self.__retryMaxCount;
}

- (void)setCurrentRetryCount:(NSInteger)currentRertyCount{
    self.__currentRertyCount = currentRertyCount;
}

- (NSInteger)currentRetryCount{
    return self.__currentRertyCount;
}


- (id)copyWithZone:(nullable NSZone *)zone{
    JVRequestModel *model = [[[self class] allocWithZone:zone] init];
    model.task = self.task;
    model.method  = self.method;
    model.url  = self.url;
    model.postData  = self.postData;
    model.callback  = self.callback;
    model.errorCallback  = self.errorCallback;
    model.finishCallback  = self.finishCallback;
    model.isShowLoading  = self.isShowLoading;
    model.isLoadingMask  = self.isLoadingMask;
    model.loadingContent  = self.loadingContent;
    model.userInfo  = self.userInfo;
    model.headers  = self.headers;
    model.isCache  = self.isCache;
    model.withTokenCode  = self.withTokenCode;
    model.mappMsgLevel  = self.mappMsgLevel;
    model.version  = self.version;
    model.sessionId  = self.sessionId;
    model.origUrl  = self.origUrl;
    model.__requestID = self.__requestID;
    model.__startTime  = self.__startTime;
    model.__responseTime  = self.__responseTime;
    model.metrics = self.metrics;
    model.__retryMaxCount = self.__retryMaxCount;
    model.__retry = self.__retry;
    model.__currentRertyCount = self.__currentRertyCount;
    return model;
}

@end
