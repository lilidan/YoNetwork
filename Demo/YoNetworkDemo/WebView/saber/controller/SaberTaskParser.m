#import "SaberTaskParser.h"

@implementation SaberTaskParser
-(instancetype)init{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/*如果没有处理一定要返回NO*/
-(BOOL)parse:(NSDictionary*)taskDic{
    return NO;
}

@end
