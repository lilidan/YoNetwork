//
//  BannerRequest.h
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/7.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseRequest.h"
#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN



@protocol EntrustBannerModel  <NSObject>

@end

@interface EntrustBannerModel : JSONModel

@property (nonatomic,strong,readwrite) NSString<Optional> *funcCode;
@property (nonatomic,strong,readwrite) NSString<Optional> *cfgChannel;
@property (nonatomic,strong,readwrite) NSString<Optional> *adId;
@property (nonatomic,strong,readwrite) NSString<Optional> *riskTemplateNo;
@property (nonatomic,strong,readwrite) NSString<Optional> *adName;
@property (nonatomic,strong,readwrite) NSString<Optional> *url;
@property (nonatomic,strong,readwrite) NSString<Optional> *imagePath;

@end


@interface EntrustBannerResponseModel : JSONModel

@property (nonatomic,strong,readwrite) NSArray<EntrustBannerModel,Optional> *bannerAdvertis;
@property (nonatomic,strong,readwrite) NSArray<EntrustBannerModel,Optional> *underAdvertis;

@end


@interface BannerRequest : BaseRequest

@property (nonatomic,strong,readwrite) NSString *funcCodeList;
@property (nonatomic,strong,readwrite) NSString *cfgChannels;
@property (nonatomic,assign,readwrite) int testInt;

@end

NS_ASSUME_NONNULL_END
