#import "JVViewModel.h"
#import "JVUtility.h"
@implementation JVViewModel


-(void)modelDidCreateFromDictionary{
    if(self.parentHeight&&self.parentWidth){
        self.frameRect=FORMAT_FRAME_STRING_WITH_PARENT_SIZE(self.frameString,CGSizeMake([self.parentWidth  floatValue],[self.parentHeight floatValue]));
    }else{
        self.frameRect=FORMAT_FRAME_STRING(self.frameString);
    }
}





@end
