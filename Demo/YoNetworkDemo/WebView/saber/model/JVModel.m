#import "JVModel.h"
#import <objc/runtime.h>
@implementation JVModel
-(id)init{
    self = [super init];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

-(id)initWithDic:(NSDictionary*)dic{
    self = [super init];
    if (self) {
        [self setDefaultValue];
        [self modelFromDictionary:dic];
    }
    return self;
}

//abstract no implement!!!!
-(void)setDefaultValue{}
//abstract no implement!!!!
-(void)modelDidCreateFromDictionary{
//    @throw [NSException exceptionWithName:NSInternalInconsistencyException
//                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
//                                 userInfo:nil];
}
//查看class是否拥有这个属性
- (BOOL)checkPropertyName:(NSString *)name {
    unsigned int propCount, i;
    objc_property_t* properties = class_copyPropertyList([self class], &propCount);
    for (i = 0; i < propCount; i++) {
        objc_property_t prop = properties[i];
        const char *propName = property_getName(prop);
        if(propName) {
            NSString *_name = [NSString stringWithCString:propName encoding:NSUTF8StringEncoding];
            if ([name isEqualToString:_name]) {
                //一定要释放
                free(properties);
                return YES;
            }
        }
    }
    //一定要释放
    free(properties);
    return NO;
}
//按照dict给类设置属性
- (void)modelFromDictionary:(NSDictionary*) dict{
    for (NSString *key in [dict allKeys]) {
        id value = [dict objectForKey:key];
        if ([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSNumber class]]||[value isKindOfClass:[NSArray class]]) {
//            if ([self checkPropertyName:key]){
//                @try{
                    if([value isKindOfClass:[NSNumber class]]){
                        value = [NSString stringWithFormat:@"%@",value];
                    }
                    
                    [self setValue:value forKey:key];
//                }@catch(NSException* e){
////                    DLog(@"!!!!!!Exception!!!!!!!no key find--->key:%@--->value:%@",key,value);
//                }
//                @finally{}
//            }
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            //如果对象有初始化，则调用它的序列化
            id subObj = [self valueForKey:key];
            if([subObj isKindOfClass:[JVModel class]]){
                [subObj modelFromDictionary:value];
            }else{
                [self setValue:value forKey:key];
            }
        }
        
    }
    
    [self modelDidCreateFromDictionary];
}


- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
    
}

+ (NSMutableDictionary *) dictionaryFromModel: (id) theObject
{
    //递归的时候如果传进来是
    if([theObject isKindOfClass:[NSString class]]||[theObject isKindOfClass:[NSNumber class]]){
        return theObject;
    }
    NSMutableDictionary * tmpDic = [[NSMutableDictionary alloc] init];
    if (theObject ==nil)
    {
        return tmpDic;
    }
    //get all the property fields names
    NSString *className =NSStringFromClass([theObject class]);
    const char *cClassName = [className UTF8String];
    id theClass = objc_getClass(cClassName);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(theClass, &outCount);
    NSMutableArray *propertyNames = [[NSMutableArray alloc] initWithCapacity:1];
    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *propertyNameString = [[NSString alloc] initWithCString:property_getName(property)
                                                                encoding:NSUTF8StringEncoding];
        [propertyNames addObject:propertyNameString];
        // NSLog(@"%s %s\n",property_getName(property), property_getAttributes(property));
    }
    for (NSString *key in propertyNames)
    {
        //返回值
        SEL selector = NSSelectorFromString(key);
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id value = [theObject performSelector:selector];
#pragma clang diagnostic pop
        if (value == nil){
            value = [NSNull null];
            [tmpDic setObject:value forKey:key];
            continue;
        }
        //[finalDict setObject:value forKey:key];
        if ([value isKindOfClass:[NSString class]]||[value isKindOfClass:[NSNumber class]]){
            [tmpDic setObject:value forKey:key];
        }else if ([value isKindOfClass:[NSArray class]]){
            NSMutableArray * valueArray = [[NSMutableArray alloc] init];
            NSArray * aArray = (NSArray *)value;
            for (int i =0; i < [aArray count]; i++){
                [valueArray addObject:[JVModel dictionaryFromModel:[aArray objectAtIndex:i]]];
            }
            [tmpDic setObject:valueArray forKey:key];
        }else {
            [tmpDic setObject:[JVModel dictionaryFromModel:value] forKey:key];
        }
    }
    return tmpDic;
}
@end
