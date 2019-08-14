#import "JVViewControllerModel.h"
#import "JVRequestModel.h"
@interface SaberRootVCModel : JVViewControllerModel{
}

@property (nonatomic, strong) JVRequestModel *requestModel;

/*外部参数*/
@property (nonatomic, strong) NSString *webUrl;         //进入页面时候的url,可以是bundle://也可以是http://或者https://的头部(必设)  TEST:
@property (nonatomic, strong) NSString *webViewLoadType;//0 表示默认情况，是localCache模式  1表示强制读取外部URL(如pdf，会员权益等该参数必须设置为1)

@property (nonatomic, strong) NSDictionary *lastPageData;   //上一页面的参数
@property (nonatomic, strong) NSString *refreshType;    //0 不刷新  1仅下拉刷新  2上下拉刷新 3自动刷新，并且有top按钮   默认 1
@property (nonatomic, strong) NSString *jsCallbackWhenNoRequest;//当没有初始请求时，回调的callback,默认为"render",第一个参数是init的string值
@property (nonatomic, strong) NSString *pullDownCallBack;//下拉刷新时候的回调，如果没有设置，则表示默认使用model的request

@property (nonatomic, assign) NSInteger webLevel; // 0 UIWebView  1 WKWebView add by huangtianbao 2018.10.25

//navi bar style
@property (nonatomic, strong) NSString *naviBarStyle;   //是否显示头部view    0 隐藏 1 显示系统  默认1
@property (nonatomic, strong) NSString *naviBarTitle;   //navibar头部文字
@property (nonatomic, strong) NSDictionary *naviBarTitleDict;//navibar头部view自定义
@property (nonatomic, strong) NSString *naviBarBackBtn; //是否隐藏返回按钮     0 隐藏 1 系统   默认1
@property (nonatomic, strong) NSString *naviBarBackBtnType;//返回按钮的类型，目前只有lufax的单返回类型 0 Lufax类型

@property (nonatomic, strong) NSDictionary *backBtnDic;//返回按钮的参数
@property (nonatomic, strong) NSDictionary *rightBtnDic;//右边按钮的参数


#pragma mark   iOS Only present相关的参数
@property (nonatomic, strong) NSString *presentTransitionType;//默认-1  对应TRANSITION_TYPE
@property (nonatomic, strong) NSString *presentInteractionTransitionType;//默认-1  对应INTERACTION_TYPE
@property (nonatomic, strong) NSString *isNaviRootVCWhenPresent;//presentvc的时候是否作为rootViewController的rootVC   0不作为 1作为 默认为0
//iOS only
@property (nonatomic, strong) NSString *jvWebviewMarginTop;   //jvwebview的顶部偏移量
@property (nonatomic, strong) NSString *jvWebviewMarginBottom;//jvwebview的底部偏移量

@property (nonatomic, strong) NSString *version;  //bridge版本
@property (nonatomic, strong) NSString *skipUTF8Encoding; //是否在加载webUrl时跳过UTF8编码     0 否 1 是   默认0
@property (nonatomic, strong) NSString *marketingToCommon;  //@"1"是以前用LuMarketingViewController，现在用CommonTaskViewController

@property (nonatomic, assign) BOOL h5HasTrackedScreen;  //h5已经打点了

@end
