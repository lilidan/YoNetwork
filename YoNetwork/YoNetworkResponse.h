//
//  YoNetworkResponse.h
//  YoNetwork
//
//  Created by sgcy on 2019/8/6.
//

#import <Foundation/Foundation.h>

@interface YoNetworkResponse : NSObject

@property (nonatomic,strong) NSHTTPURLResponse *response;
@property (nonatomic,strong) id responseObject;

@end
