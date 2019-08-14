//
//  JVUtility.m
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/13.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import "JVUtility.h"

@implementation JVUtility

+(NSString*)camelCase:(NSString*)origStr{
    NSArray* __arr = [origStr componentsSeparatedByString:@"_"];
    NSMutableString* str=[NSMutableString string];
    
    for(NSInteger i =0;i<__arr.count;i++){
        [str appendString:[[__arr objectAtIndex:i] capitalizedString]];
    }
    
    return str;
};

+(CGRect)rectFromMyFrameStr:(NSString*)frameStr{
    return [self rectFromMyFrameStr:frameStr parentSize:CGSizeMake(APP_WIDTH, APP_HEIGHT)];
}

+(CGRect)rectFromMyFrameStr:(NSString*)frameStr parentSize:(CGSize)parentSize{
    CGRect rect = CGRectZero;
    NSArray* array = [frameStr componentsSeparatedByString:@","];//left top width height
    if(array.count==4){
        NSMutableString* retStr = [[NSMutableString alloc]init];
        NSInteger index = 0;
        
        for(NSString* len in array){
            if([len rangeOfString:@"+"].location!=NSNotFound){
                NSArray* __singleLens = [len componentsSeparatedByString:@"+"];
                CGFloat f1=[self formatMyLenStr:__singleLens[0]  parent:index%2==0?parentSize.width:parentSize.height];
                CGFloat f2=[self formatMyLenStr:__singleLens[1]  parent:index%2==0?parentSize.width:parentSize.height];
                [retStr appendFormat:@"%.2f,",f1+f2];
            }else if([len rangeOfString:@"-"].location!=NSNotFound&&[len rangeOfString:@"-"].location>0){
                //如果以负数开始则跳过
                NSArray* __singleLens = [len componentsSeparatedByString:@"-"];
                CGFloat f1=[self formatMyLenStr:__singleLens[0]  parent:index%2==0?parentSize.width:parentSize.height];
                CGFloat f2=[self formatMyLenStr:__singleLens[1]  parent:index%2==0?parentSize.width:parentSize.height];
                [retStr appendFormat:@"%.2f,",f1-f2];
            }else{
                NSString* __len = len;
                if([len isEqualToString:@"-2"]&&(index==2||index==3)){
                    __len=@"0";
                }else if([len isEqualToString:@"-1"]&&(index==2||index==3)){
                    __len=@"100%";
                }
                CGFloat f1=[self formatMyLenStr:__len parent:index%2==0?parentSize.width:parentSize.height];
                [retStr appendFormat:@"%.2f,",f1];
            }
            index++;
        }
        array =[retStr componentsSeparatedByString:@","];//left top width height
        rect = CGRectMake([array[0] floatValue],[array[1] floatValue],[array[2] floatValue],[array[3] floatValue]);
    }
    return rect;
}

+(CGFloat)formatMyLenStr:(NSString*)lenStr parent:(CGFloat)parentLen{
    if([lenStr rangeOfString:@"%"].location!=NSNotFound){//如果是百分号
        return parentLen*[lenStr floatValue]/100.0f;
    }else{
        if([lenStr rangeOfString:@"r"].location!=NSNotFound){
            return [self adapterSize:[[lenStr stringByReplacingOccurrencesOfString:@"r" withString:@""] floatValue]];
        }else{
            return lenStr.floatValue;
        }
    }
}



//根据APP尺寸做尺寸放大
+(CGFloat)adapterSize:(CGFloat)val{
    if(APP_WIDTH==375){
        return ceilf(val*1.125f);
    }else if(APP_WIDTH==414){
        return ceilf(val*1.25f);
    }else{
        return val;
    }
}

//jsontStr to Dictionary
+ (NSDictionary*)dictionaryFromJSONString:(NSString*)jsonStr{
    NSError * error = nil;
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    NSMutableDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (![jsonDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if(error){
        return nil;
    }else{
        return jsonDic;
    }
}

+ (CGSize)sizeForText:(NSString *)text font:(UIFont *)font {
    
    if (text == nil) {
        return CGSizeZero;
    }
    
    return [text sizeWithAttributes:@{NSFontAttributeName : font}];
}

+ (UIFont *)fontWithFontName:(NSString *)name size:(CGFloat)size;{
    
    CGFloat adaptedSize = size;
    
    return [UIFont fontWithName:name size:adaptedSize];
}

//Dictionary to jsontStr
+ (NSString*)stringFromDictionary:(NSDictionary*)dict{
    if (dict == nil || ![dict isKindOfClass:[NSDictionary class]] || dict.count == 0 || ![NSJSONSerialization isValidJSONObject:dict])
        return nil;
    NSError * error = nil;
    NSString* jsonStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dict options:0 error:&error]encoding:NSUTF8StringEncoding];
    if(error){
        return nil;
    }else{
        return jsonStr;
    }
}

//jsontStr to Dictionary
+ (id)objectFromJSONString:(NSString*)jsonStr{
    NSError * error = nil;
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if(error){
        return nil;
    }else{
        return jsonObject;
    }
}

//jsontStr to Dictionary
- (NSDictionary*)dictionaryFromJSONString:(NSString*)jsonStr{
    NSError * error = nil;
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    NSMutableDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (![jsonDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if(error){
        return nil;
    }else{
        return jsonDic;
    }
}


+ (UIColor *)colorWithHex:(NSString *)hexColor
{
    if(hexColor.length==3){
        hexColor=[[hexColor stringByAppendingString:hexColor] stringByAppendingString:hexColor];
    }else if(hexColor.length==2){
        hexColor=[[[hexColor stringByAppendingString:hexColor]stringByAppendingString:hexColor]stringByAppendingString:hexColor];
    }
    
    if(hexColor.length==8){
        unsigned int alpha;
        NSRange range;
        range.length = 2;
        range.location = 0;
        [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&alpha];
        hexColor=[hexColor substringFromIndex:2];
        return [self colorWithHex:hexColor alpha:(float)(alpha / 255.0f)];
    }else{
        return [self colorWithHex:hexColor alpha:1.0f];
    }
}

+ (UIColor *)colorWithHex:(NSString *)hexColor alpha:(CGFloat)a
{
    unsigned int red,green,blue;
    NSRange range;
    range.length = 2;
    range.location = 0;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    range.location = 2;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    range.location = 4;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green / 255.0f) blue:(float)(blue / 255.0f) alpha:a];
}


//将color转成Image
+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


+(NSInteger)decimalFromHexStr:(NSString*)hexStr{
    unsigned int outVal;
    NSScanner* scanner = [NSScanner scannerWithString:hexStr];
    [scanner scanHexInt:&outVal];
    return outVal;
}


+(NSString*)iconFontFromHexStr:(NSString*)fontStr{
    return [NSString stringWithFormat:@"%C", (unichar)[JVUtility decimalFromHexStr:fontStr]];
}


@end
