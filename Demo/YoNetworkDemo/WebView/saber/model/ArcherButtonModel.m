#import "ArcherButtonModel.h"

@implementation ArcherButtonModel
//赋默认值
-(void)setDefaultValue{
    [super setDefaultValue];
    self.title=@"确定";
    self.fontSize=@"14";
    self.fontColor=@"ffffff";
    self.fontStyle=@"0";
    self.normalBg=@"00000000";
    self.enable=@"1";
    self.selected=@"0";
    self.bindAction=@"1";
    self.userInfo=@{};
    self.jvActionModel = [JVActionModel new];
    self.style = @"0";
    self.clickLimitSeconds=@"2";
}

-(void)modelDidCreateFromDictionary{
    [super modelDidCreateFromDictionary];
    if(!self.highlightFontColor) self.highlightFontColor = self.fontColor;
    if(!self.selectedFontColor) self.selectedFontColor = self.fontColor;
    if(!self.disableFontColor) self.disableFontColor = self.fontColor;
    if(!self.highlightBg) self.highlightBg = self.normalBg;
    if(!self.selectedBg) self.selectedBg = self.normalBg;
    if(!self.disableBg) self.disableBg = self.normalBg;
}
@end



