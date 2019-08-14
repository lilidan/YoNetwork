//
//  YoNetworkConfig.h
//  YoNetwork
//
//  Created by sgcy on 2019/8/7.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, YoNetworkHTTPSVerifyLevel) {
    YoNetworkHTTPSVerifyLevelNone = 0,
    YoNetworkHTTPSVerifyLevelValidCertificate,
    YoNetworkHTTPSVerifyLevelSSLPinning
};

@interface YoNetworkConfig : NSObject

+ (instancetype)config;

@property (nonatomic, assign) NSString *baseUrl;
@property (nonatomic, assign) YoNetworkHTTPSVerifyLevel httpsVerifyLevel;

@end
