#import "JVViewControllerModel.h"
#import "JVUtility.h"

@implementation JVViewControllerModel

-(void)modelDidCreateFromDictionary{
    self.frameRect = [JVUtility rectFromMyFrameStr:self.frameString];
}


@end
