#import "JVModel.h"
typedef NS_ENUM(NSInteger, JV_ACTION) {
    JV_ACTION_NOTHING=-1,/*底层不做任何处理，由子类处理*/
    JV_ACTION_POP_VC,/*根据count决定pop的层次*/
    JV_ACTION_POP_VC_BY_TAG,/*返回到指定的tag vcmodel.alias*/
    JV_ACTION_POP_TO_ROOT,/*返回栈顶*/
    JV_ACTION_POP_CLOSE_ACTIVITY/*Android only 关闭当前Activity,iOS处理方式同JV_ACTION_POP_TO_ROOT*/
};

typedef NS_ENUM(NSInteger, JV_AFTER_ACTION) {
    JV_AFTER_ACTION_NOTHING=-1,/*不做任何事情*/
    JV_AFTER_ACTION_REFRESH/*POP完毕后刷新顶部vc*/
};


@interface JVActionModel : JVModel
@property(nonatomic, strong) NSString* actionId;// JVAction.h JV_ACTION  默认为-1  pop_vc
@property(nonatomic, strong) NSString* callback;// 用来作为回调的参数


@property(nonatomic, strong) NSString* popCount;//actionId=0 表示pop的次数 默认为1
@property(nonatomic, strong) NSString* popTag;//actionId=1 表示pop到某个vc的位置
@property(nonatomic, strong) NSString* animated;//actionId in (0,1)时；默认为 1
@property(nonatomic, strong) NSString* afterPopAction;//pop完毕后的动作  -1 无动作 0刷新当前栈顶vc 默认-1


/*private*/
@property NSInteger intPopCount;
@property BOOL bolAnimated;
@end
