#import "JVModel.h"

@interface JVViewControllerModel : JVModel
@property (nonatomic, strong)  NSString*           frameString;/*50%+10,30%,100%,90*/
@property (nonatomic, strong)  NSString*           alias;/*别名用来跳转*/
@property (nonatomic, strong) NSString*           className;
@property (nonatomic, assign)  CGRect      frameRect;
@end
