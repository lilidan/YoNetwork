#import "ArcherViewModel.h"

@interface ArcherButtonModel : ArcherViewModel
/*title设置*/
@property(nonatomic, strong)   NSString*           title;                  //button文案
/*title字体设置*/
@property(nonatomic, strong)   NSString*           fontColor;              //font颜色hex
@property(nonatomic, strong)   NSString*           highlightFontColor;     //font颜色hex
@property(nonatomic, strong)   NSString*           disableFontColor;       //font颜色hex
@property(nonatomic, strong)   NSString*           selectedFontColor;      //font颜色hex
@property(nonatomic, strong)   NSString*           fontStyle;              //font类型  默认0  0-默认类型 1-iconFont(iconfont-framework)
@property(nonatomic, strong)   NSString*           fontSize;               //font尺寸
/*背景色设置*/
@property(nonatomic, strong)   NSString*           normalBg;               //背景颜色
@property(nonatomic, strong)   NSString*           highlightBg;            //背景颜色
@property(nonatomic, strong)   NSString*           disableBg;              //背景颜色
@property(nonatomic, strong)   NSString*           selectedBg;             //背景颜色

/*边框设置，其它边框设置在ArcherViewModel中*/
@property(nonatomic, strong)   NSString*           disableBorderColor;     //禁用的边框颜色

/*状态设置*/
@property(nonatomic, strong)   NSString*           enable;                 //是否可点击  0 无效 1有效 默认1
@property(nonatomic, strong)   NSString*           selected;               //是否选中    0 没选中 1选中 默认0

/*其它参数*/
@property(nonatomic, strong)   NSDictionary*       userInfo;               //用户信息回调过来
@property(nonatomic, strong)   NSString*           style;                  // 0：左箭头   1：叉
@property(nonatomic, strong)   JVActionModel*      jvActionModel;          //view的action参数

@property(nonatomic, strong)   NSString*           clickLimitSeconds;      //默认为2秒   点击的click重复
@property(nonatomic, strong)   NSString*           defaultText;            //默认文字，当iconFont不支持title时，使用该文字显示

@end
