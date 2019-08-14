//
//  BannerRequest.m
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/7.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import "BannerRequest.h"


@implementation EntrustBannerModel

@end

@implementation EntrustBannerResponseModel


@end

@implementation BannerRequest

- (NSString *)requestPath
{
    return @"/trust-pa/service/indexPage/getAdvertis";
}

- (Class)responseClass
{
    return [EntrustBannerResponseModel class];
}

@end
