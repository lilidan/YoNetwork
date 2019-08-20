//
//  YoNetworkBaseRequest.m
//  YoNetwork
//
//  Created by sgcy on 2019/8/6.
//

#import "YoNetworkBaseRequest.h"
#import <objc/runtime.h>
#import "JSONModelClassProperty.h"
#import "JSONValueTransformer.h"
#import "YoNetworkAgent.h"
#import "YoNetworkConfig.h"

static NSArray* allowedJSONTypes = nil;
static NSArray* allowedPrimitiveTypes = nil;
static JSONValueTransformer* valueTransformer = nil;
static Class YoNetworkBaseRequestClass = NULL;

@implementation YoNetworkBaseRequest

- (YoNetworkAgent *)agent
{
    return [[self agentClass] sharedAgent];
}

- (void)send:(YoNetworkResultBlock)handler
{
    _handler = handler;
    [self.agent addRequest:self];
}

- (void)clearCompletionBlock
{
    self.handler  = nil;
}

- (nullable id)requestArgument
{
    return _requestArgument ?: [self toDictionary];
}

- (NSString *)requestPath
{
    return _requestPath ?: @"";
}

- (NSString *)baseUrl
{
    return _baseUrl ?: [self.agent.config baseUrl];
}


- (YoNetworkRequestMethod)requestMethod
{
    return _requestMethod;
}

- (Class)responseClass
{
    return nil;
}

- (Class)agentClass
{
    return [YoNetworkAgent class];
}


- (NSTimeInterval)requestTimeoutInterval
{
    return 60;
}

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary{
    return nil;
}


- (YoNetworkRequestSerializerType)requestSerializerType
{
    return YoNetworkRequestSerializerTypeJSON;
}

- (YoNetworkResponseSerializerType)responseSerializerType
{
    return YoNetworkResponseSerializerTypeJSON;
}


- (BOOL)allowsCellularAccess
{
    return YES;
}

- (id)responseLogicHandler:(id)responseObject error:(NSError *__autoreleasing *)error
{
    return responseObject;
}

- (BOOL)retryForReachablity
{
    return NO;
}

#pragma mark - for json model

+(void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        @autoreleasepool {
            allowedJSONTypes = @[
                                 [NSString class], [NSNumber class], [NSDecimalNumber class], [NSArray class], [NSDictionary class], [NSNull class], //immutable JSON classes
                                 [NSMutableString class], [NSMutableArray class], [NSMutableDictionary class] //mutable JSON classes
                                 ];
            
            allowedPrimitiveTypes = @[
                                      @"BOOL", @"float", @"int", @"long", @"double", @"short",
                                      //and some famous aliases
                                      @"NSInteger", @"NSUInteger",
                                      @"Block"
                                      ];
            valueTransformer = [[JSONValueTransformer alloc] init];
            YoNetworkBaseRequestClass = NSClassFromString(NSStringFromClass(self));
        }
    });
}

-(void)__setup__
{
    //JMLog(@"Inspect class: %@", [self class]);
    
    NSMutableDictionary* propertyIndex = [NSMutableDictionary dictionary];
    
    //temp variables for the loops
    Class class = [self class];
    NSScanner* scanner = nil;
    NSString* propertyType = nil;
    
    // inspect inherited properties up to the JSONModel class
    while (class != [YoNetworkBaseRequest class]) {
        //JMLog(@"inspecting: %@", NSStringFromClass(class));
        
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        
        //loop over the class properties
        for (unsigned int i = 0; i < propertyCount; i++) {
            
            JSONModelClassProperty* p = [[JSONModelClassProperty alloc] init];
            
            //get property name
            objc_property_t property = properties[i];
            const char *propertyName = property_getName(property);
            p.name = @(propertyName);
            
            //JMLog(@"property: %@", p.name);
            
            //get property attributes
            const char *attrs = property_getAttributes(property);
            NSString* propertyAttributes = @(attrs);
            NSArray* attributeItems = [propertyAttributes componentsSeparatedByString:@","];
            
            //ignore read-only properties
            if ([attributeItems containsObject:@"R"]) {
                continue; //to next property
            }
            
            //check for 64b BOOLs
            if ([propertyAttributes hasPrefix:@"Tc,"]) {
                //mask BOOLs as structs so they can have custom converters
                p.structName = @"BOOL";
            }
            
            scanner = [NSScanner scannerWithString: propertyAttributes];
            //JMLog(@"attr: %@", [NSString stringWithCString:attrs encoding:NSUTF8StringEncoding]);
            [scanner scanUpToString:@"T" intoString: nil];
            [scanner scanString:@"T" intoString:nil];
            
            //check if the property is an instance of a class
            if ([scanner scanString:@"@\"" intoString: &propertyType]) {
                
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@"\"<"]
                                        intoString:&propertyType];
                
                //JMLog(@"type: %@", propertyClassName);
                p.type = NSClassFromString(propertyType);
                p.isMutable = ([propertyType rangeOfString:@"Mutable"].location != NSNotFound);
                p.isStandardJSONType = [allowedJSONTypes containsObject:p.type];
                
                //read through the property protocols
                while ([scanner scanString:@"<" intoString:NULL]) {
                    
                    NSString* protocolName = nil;
                    
                    [scanner scanUpToString:@">" intoString: &protocolName];
                    
                    if ([protocolName isEqualToString:@"Optional"]) {
                        p.isOptional = YES;
                    } else if([protocolName isEqualToString:@"Ignore"]) {
                        p = nil;
                    } else {
                        p.protocol = protocolName;
                    }
                    
                    [scanner scanString:@">" intoString:NULL];
                }
                
            }
            //the property must be a primitive
            else {
                
                //the property contains a primitive data type
                [scanner scanUpToCharactersFromSet:[NSCharacterSet characterSetWithCharactersInString:@","]
                                        intoString:&propertyType];
                
                //get the full name of the primitive type
                propertyType = valueTransformer.primitivesNames[propertyType];
                
                if (![allowedPrimitiveTypes containsObject:propertyType]) {
                    //type not allowed - programmer mistaken -> exception
                    @throw [NSException exceptionWithName:@"JSONModelProperty type not allowed"
                                                   reason:[NSString stringWithFormat:@"Property type of %@.%@ is not supported by JSONModel.", self.class, p.name]
                                                 userInfo:nil];
                }
                
            }
            
            NSString *nsPropertyName = @(propertyName);
            //few cases where JSONModel will ignore properties automatically
            if ([propertyType isEqualToString:@"Block"]) {
                p = nil;
            }
            
            //add the property object to the temp index
            if (p && ![propertyIndex objectForKey:p.name]) {
                [propertyIndex setValue:p forKey:p.name];
            }
            
        }
        
        free(properties);
        
        //ascend to the super of the class
        //(will do that until it reaches the root class - JSONModel)
        class = [class superclass];
    }
    
    //finally store the property index in the static property index
    objc_setAssociatedObject(
                             self.class,
                             &kClassPropertiesKey,
                             [propertyIndex copy],
                             OBJC_ASSOCIATION_RETAIN // This is atomic
                             );
}

static const char * kClassPropertiesKey;

//returns a list of the model's properties
-(NSArray*)__properties__
{
    //fetch the associated object
    NSDictionary* classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    if (classProperties) return [classProperties allValues];
    
    //if here, the class needs to inspect itself
    [self __setup__];
    
    //return the property list
    classProperties = objc_getAssociatedObject(self.class, &kClassPropertiesKey);
    return [classProperties allValues];
}


-(NSDictionary*)toDictionary
{
    NSArray* properties = [self __properties__];
    NSMutableDictionary* tempDictionary = [NSMutableDictionary dictionaryWithCapacity:properties.count];
    
    id value;
    
    //loop over all properties
    for (JSONModelClassProperty* p in properties) {
        
        //fetch key and value
        NSString* keyPath = p.name;
        value = [self valueForKey: p.name];
        
        if ([keyPath rangeOfString:@"."].location != NSNotFound) {
            //there are sub-keys, introduce dictionaries for them
            [self __createDictionariesForKeyPath:keyPath inDictionary:&tempDictionary];
        }
        
        
        //export nil when they are not optional values as JSON null, so that the structure of the exported data
        //is still valid if it's to be imported as a model again
        if (isNull(value)) {
            
            if (value == nil)
            {
                [tempDictionary removeObjectForKey:keyPath];
            }
            else
            {
                [tempDictionary setValue:[NSNull null] forKeyPath:keyPath];
            }
            continue;
        }
        
            // 2) check for standard types OR 2.1) primitives
            if (p.structName==nil && (p.isStandardJSONType || p.type==nil)) {
                
                //generic get value
                [tempDictionary setValue:value forKeyPath: keyPath];
                
                continue;
            }
        }
    
    return [tempDictionary copy];
}

-(void)__createDictionariesForKeyPath:(NSString*)keyPath inDictionary:(NSMutableDictionary**)dict
{
    //find if there's a dot left in the keyPath
    NSUInteger dotLocation = [keyPath rangeOfString:@"."].location;
    if (dotLocation==NSNotFound) return;
    
    //inspect next level
    NSString* nextHierarchyLevelKeyName = [keyPath substringToIndex: dotLocation];
    NSDictionary* nextLevelDictionary = (*dict)[nextHierarchyLevelKeyName];
    
    if (nextLevelDictionary==nil) {
        //create non-existing next level here
        nextLevelDictionary = [NSMutableDictionary dictionary];
    }
    //recurse levels
    [self __createDictionariesForKeyPath:[keyPath substringFromIndex: dotLocation+1]
                            inDictionary:&nextLevelDictionary ];
    
    //create the hierarchy level
    [*dict setValue:nextLevelDictionary  forKeyPath: nextHierarchyLevelKeyName];
}

@end
