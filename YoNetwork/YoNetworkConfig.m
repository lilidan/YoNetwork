//
//  YoNetworkConfig.m
//  YoNetwork
//
//  Created by sgcy on 2019/8/7.
//

#import "YoNetworkConfig.h"
#import "YoNetworkAgent.h"
#import "AFSecurityPolicy.h"
#import "YoNetworkAgent.h"

static const float kDefaultDelayInSeconds = 1.0f;
static const int kDefaultRetryMaxCount = 0;

@implementation YoNetworkConfig

//+ (YoNetworkConfig *)config {
//    static id sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedInstance = [[self alloc] init];
//    });
//    return sharedInstance;
//}


+ (YoNetworkConfig *)config {
    YoNetworkConfig * instance = [[self alloc] init];
    return instance;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.httpsVerifyLevel = 0;
    }
    return self;
}


@end
