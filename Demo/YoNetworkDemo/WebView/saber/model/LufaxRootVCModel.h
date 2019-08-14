#import "SaberRootVCModel.h"

@interface LufaxRootVCModel : SaberRootVCModel
@property (nonatomic, strong) NSString *localParams;   //业务需要传递给render时候额外的参数 比如需要userInfo,deviceInfo,appInfo等
@property (nonatomic, strong) NSString *bottomTabBarStatus;   //0隐藏底部tab   1显示底部tab
@property (nonatomic, strong) NSString *popCallbackJS;  // 返回上一页时的回调函数 默认nil
@property (nonatomic, strong) NSString *fakePresent;    // 0:无效果     1:模拟present(从下弹出、左上角显示叉、不可右滑返回)    默认:0
@property (nonatomic, strong) NSString *trackScreenName;    // 当前页面埋点screen名称
@property (nonatomic, strong) NSString *lastPageDataStringFromUrl;    // 在url中配置的lastPageData
@property (nonatomic, strong) NSString *webViewTransparency;    // 0~1,当值不为1时将上一个容器的内容在当前容器显示并设置对应透明度

/*SPA DATA */
@property (nonatomic, strong) NSDictionary *naviBar;
@property (nonatomic, strong) NSDictionary *leftNaviItem;
@property (nonatomic, strong) NSDictionary *rightNaviItem;
@property (nonatomic, strong) NSDictionary *rightMenu;
@property (nonatomic, strong) NSDictionary *centerNaviItem;
@property (nonatomic, strong) NSDictionary *bottomView;
@property (nonatomic, strong) NSDictionary *pageDic;
@property (nonatomic, assign) BOOL     isWhiteBg; //这个字段主要是以前native主动使用，以后还是用下面字段 isWhiteTitleBar

@property (nonatomic, strong) NSString *isWhiteTitleBar; //注意：这个字段是为了兼容hybrid的push view并且和安卓保持一致

@property (nonatomic, strong) NSString *hideNativeLoading; //1:不使用native的loading 0/empty/nil:使用native的loading

@property (nonatomic, strong) NSString     *showCancelButton;  //展示一键关闭容器按钮(BOOL值改成string，适配iphone4s)
@end
