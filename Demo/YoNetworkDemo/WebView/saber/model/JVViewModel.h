#import "JVModel.h"

@interface JVViewModel : JVModel
@property(nonatomic, strong)  NSString*           frameString;/*50%+10,30%,100%,90*/
@property(nonatomic, strong)  NSString*           tag;
@property(nonatomic, strong)  NSString*           alias;
@property(nonatomic, strong)  NSString*           parentWidth;    //父宽度
@property(nonatomic, strong)  NSString*           parentHeight;   //父高度

@property(assign)  CGRect      frameRect; //原始的rect 实际的view的frame可能是放大过的


@end
