#import "JVLocalModel.h"

@implementation JVLocalModel

//默认值
-(void)setDefaultValue{
    _callback=@"getLocalData";
}

-(void)modelDidCreateFromDictionary{}   // 必须覆写一下，基类中的实现会造成内存泄露
@end
