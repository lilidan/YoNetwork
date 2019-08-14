//
//  JVUtility.h
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/13.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import <UIKit/UIKit.h>

#define APP_HEIGHT              [UIScreen mainScreen].bounds.size.height
#define APP_WIDTH               [UIScreen mainScreen].bounds.size.width

#define JSON_DIC_FROM_STRING(__STR__)   [JVUtility dictionaryFromJSONString:__STR__]
#define JSON_OBJ_FROM_STRING(__STR__)   [JVUtility objectFromJSONString:__STR__]
#define JSON_STRING_FROM_DIC(__DIC__)   [JVUtility stringFromDictionary:__DIC__]


#define JVFONT(__SIZE__)          [UIFont systemFontOfSize:__SIZE__]
#define COLOR_HEX(HEX)                      [JVUtility colorWithHex:HEX]
#define IMAGE_WITH_COLOR(__HEX__)           [JVUtility imageWithColor:COLOR_HEX(__HEX__)]
#define JV_ICON_FONT(__FONT_NAME__,__SIZE__) [UIFont fontWithName:__FONT_NAME__ size:__SIZE__]

#define ICON_FONT(aSize)            [JVUtility fontWithFontName:@"iconfont" size:aSize]
#define ICON_FONT_V2(aSize)         [JVUtility fontWithFontName:@"iconfontv2" size:aSize]


#define FORMAT_FRAME_STRING(__STR__)   [JVUtility rectFromMyFrameStr:__STR__]
#define FORMAT_FRAME_STRING_WITH_PARENT_SIZE(__STR__,__PARENT_SIZE__) [JVUtility rectFromMyFrameStr:__STR__ parentSize:__PARENT_SIZE__]


#define ARCHER_INIT_BASIC_MODEL \
self.frame=self.model.frameRect;                                                    \
NSArray* __arr = [self.model.frameString componentsSeparatedByString:@","];         \
if([__arr[2] isEqualToString:@"-2"]||[__arr[3] isEqualToString:@"-2"]){             \
[self sizeToFit];}                                                              \
if(self.model.tag)self.tag=[self.model.tag integerValue];\
if(self.model.backgroundColor){self.backgroundColor =COLOR_HEX(self.model.backgroundColor);}\
else{self.backgroundColor =[UIColor clearColor];}


@interface JVUtility : NSObject

+(NSString*)camelCase:(NSString*)origStr;

+ (CGRect)rectFromMyFrameStr:(NSString*)frameStr;
+(CGRect)rectFromMyFrameStr:(NSString*)frameStr parentSize:(CGSize)parentSize;

+ (NSDictionary*)dictionaryFromJSONString:(NSString*)jsonStr;
+ (NSString*)stringFromDictionary:(NSDictionary*)dict;
+ (id)objectFromJSONString:(NSString*)jsonStr;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)a;
+ (UIColor *)colorWithHex:(NSString *)hexColor;

+ (CGSize)sizeForText:(NSString *)text font:(UIFont *)font;
+(NSString*)iconFontFromHexStr:(NSString*)fontStr;
+ (UIFont *)fontWithFontName:(NSString *)name size:(CGFloat)size;

@end

