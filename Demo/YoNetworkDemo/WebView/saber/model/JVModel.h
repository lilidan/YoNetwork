#import <UIKit/UIKit.h>

@interface JVModel : NSObject
-(id)initWithDic:(NSDictionary*)dic;
//将dict转换程model
- (void)modelFromDictionary:(NSDictionary*) dict;
+ (NSMutableDictionary *) dictionaryFromModel: (id) theObject;
- (void)modelDidCreateFromDictionary;
-(void)setDefaultValue;
@end

