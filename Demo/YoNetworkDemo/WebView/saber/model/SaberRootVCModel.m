#import "SaberRootVCModel.h"
@implementation SaberRootVCModel

-(id)init{
    self = [super init];
    if (self) {
        [self setDefaultValue];
    }
    return self;
}

//赋默认值
-(void)setDefaultValue{
    [super setDefaultValue];
    self.presentTransitionType=@"-1";
    self.presentInteractionTransitionType=@"-1";
    self.isNaviRootVCWhenPresent=@"0";
    self.refreshType=@"1";
    self.jsCallbackWhenNoRequest=@"render";
    self.naviBarStyle=@"1";
    self.naviBarBackBtn=@"1";
    self.naviBarBackBtnType=@"0";
    self.lastPageData=@{};
    self.webViewLoadType=@"0";
    self.jvWebviewMarginBottom=@"0";
    self.jvWebviewMarginTop=@"0";
    self.skipUTF8Encoding=@"0";
    self.marketingToCommon = @"0";
    self.h5HasTrackedScreen = NO;
    self.backBtnDic=@{@"frameString":@"0,0,40,44",
                      @"jvActionModel":@{@"actionId":@"0"},
                      @"bindAction":@"1"};
}

-(void)modelDidCreateFromDictionary{
    [super modelDidCreateFromDictionary];
}
@end
