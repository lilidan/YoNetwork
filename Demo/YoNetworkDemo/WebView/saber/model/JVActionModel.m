#import "JVActionModel.h"

@implementation JVActionModel
//默认值
-(void)setDefaultValue{
    _popCount=@"1";
    _actionId=@"-1";
    _animated=@"1";
    _afterPopAction=@"-1";
}

-(void)modelDidCreateFromDictionary{
    _intPopCount=[_popCount integerValue];
    _bolAnimated= [_animated isEqualToString:@"1"]?YES:NO;
}
@end
