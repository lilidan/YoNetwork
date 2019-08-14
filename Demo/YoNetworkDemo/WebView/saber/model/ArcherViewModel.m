#import "ArcherViewModel.h"

@implementation ArcherViewModel

-(void)setDefaultValue{
    [super setDefaultValue];
    self.isTrace=@"0";
    self.bindAction=@"0";
    self.alpha=@"1";
}

-(void)modelDidCreateFromDictionary{
    [super modelDidCreateFromDictionary];
}
@end
