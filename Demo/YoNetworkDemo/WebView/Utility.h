//
//  Utility.h
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/12.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Utility : NSObject


+(NSDictionary *)luGreaterThanMinDigitIntegerFromJavaScriptString:(NSString *)string
                                                          forKeys:(NSArray *)keys
                                                       defaultKey:(NSString *)defaKey;

@end

NS_ASSUME_NONNULL_END
