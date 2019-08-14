#import "JVViewModel.h"
#import "JVActionModel.h"
@interface ArcherViewModel : JVViewModel
@property(nonatomic, strong)   NSString*           isTrace;        //可选   0不追踪    1追踪
@property(nonatomic, strong)   NSString*           imgSrc;         //可选   图片src
@property(nonatomic, strong)   NSString*           jsCallBack;     //可选   js的回调方法
@property(nonatomic, strong)   NSString*           bindAction;     //默认0 不bind
@property(nonatomic, strong)   NSString*           backgroundColor;//16进制color值
@property(nonatomic, strong)   NSString*           borderWidth;            //border 宽度
@property(nonatomic, strong)   NSString*           borderRadius;           //border 弧度
@property(nonatomic, strong)   NSString*           borderColor;            //border颜色
@property(nonatomic, strong)   NSString*           alpha;                  //透明度 默认1
@end
