#import "SaberWrapperView.h"
#import "SaberWrapperViewModel.h"

@implementation SaberWrapperView

-(Class)modelClass{
    return [SaberWrapperViewModel class];
}


-(void)addArcherTarget:(id)target{
    self.saberWrapperViewDelegate = target;
    __weak __typeof(self)weakSelf = self;
    [self.saberWrapperViewDelegate saberWrapperViewPosition:self.model.align.integerValue weakSelf:weakSelf];
}




@end
