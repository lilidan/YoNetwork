//
//  YoNetworkAgent.h
//  YoNetwork
//
//  Created by sgcy on 2019/8/6.
//

#import <Foundation/Foundation.h>
@class YoNetworkBaseRequest;
@class YoNetworkConfig;

@interface YoNetworkAgent : NSObject

@property (nonatomic, strong) YoNetworkConfig *config;


///  Get the shared agent.
+ (instancetype)sharedAgent;

///  Add request to session and start it.
- (void)addRequest:(YoNetworkBaseRequest *)request;

///  Cancel a request that was previously added.
- (void)cancelRequest:(YoNetworkBaseRequest *)request;

///  Cancel all requests that were previously added.
- (void)cancelAll:(BOOL)cancelPendingTasks;

@end
