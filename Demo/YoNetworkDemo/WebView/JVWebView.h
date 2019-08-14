#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
#import <objc/runtime.h>

typedef enum
{
    WebViewLoadFailed=-1,
    WebViewNotLoad = 0,
    WebViewLoadSuccess = 1,
} WebViewLoadStatus;


typedef enum : NSUInteger {
    WebPageTnterruptActionSchema        = 1<<0,
    WebPageTnterruptActionPushView      = 1<<1,
    WebPageTnterruptActionH5HashChange  = 1<<2,
    WebPageTnterruptActionLocation      = 1<<3,
    WebPageTnterruptActionAlert         = 1<<4
} WebPageTnterruptActionBitMap;

#define ASSOCIATED_UIWEBVIEW_ACTION_BITMAP @"Associated_uiwebview_action_bitmap"

@protocol JVWebViewDelegate<NSObject>
@required
/**
 * 生命周期
 */
//是否开始读取URL iOS Only
- (BOOL)jvWebView:(id)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
//成功开始读取
- (void)jvWebViewDidStartLoad:(id)webView;
//成功读取
- (void)jvWebViewDidFinishLoad:(id)webView;
//读取失败
- (void)jvWebView:(id)webView didFailLoadWithError:(NSError *)error;
//无论成功或者失败的回调
- (void)jvWebViewAllFinishLoad:(id)webView;


//iOS Only
//js call native
- (void)jvWebView:(id)webview didReceiveJSNotificationWithObject:(NSObject*) dictionary;
- (void)jvWebView:(id)webview didReceiveJSNotificationWithDictionary:(NSDictionary*) dictionary;

@optional
- (NSString*)importGlobalJS;//加载全局js 触发点是加载完毕webview

@end


@interface JVWebView : NSObject<WKNavigationDelegate,WKUIDelegate,UIWebViewDelegate>
@property(nonatomic,strong) WKWebView*              wkWebView;/*iOS8+*/
@property(nonatomic,strong) UIWebView*              uiWebView;/*7.000000f-*/
@property(nonatomic,weak)   id<JVWebViewDelegate>   jvWebViewDelegate;
@property(nonatomic)        WebViewLoadStatus       loadStatus; /*webview的读取状态*/

@property(nonatomic,assign) BOOL                    skipUTF8Encoding;/*是否跳过UTF8编码  YES 是  NO 否  默认否即进行UTF8编码*/
//@property(nonatomic)        NSString*               bridgeVersion;
@property(nonatomic,assign) NSInteger      level;// 0 UIWebView 1 WKWebView
@property (nonatomic, copy) NSString *supportSysWK; // 控制 wkwebview 可支持的 iOS 版本
@property (nonatomic, copy) NSString *controlCookieTime; // 控制 cookie 的种入时机 1:初始化是种入cookie , 否，request 时种入 cookie

/**
 * 白屏打点去造点事件 按位运算 默认值是0
 * schema|push_view|h5_hash_change|location|alert
 */
@property(nonatomic,assign) NSInteger               webActionBitMap;

//-(id)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);
- (id)initWithFrame:(CGRect)frame
           webLevel:(NSInteger)webLevel
       supportSysWK:(NSString *)supportSysWK
  controlCookieTime:(NSString *)controlCookieTime
      configuration:(WKWebViewConfiguration *)configuration NS_AVAILABLE_IOS(8_0);


- (void)loadURLString:(NSString*)urlString;
- (void)loadURLString:(NSString*)urlString isLocalCache:(BOOL)isLocalCache;
- (void)loadHtmlString:(NSString*)htmlString;

- (void)callJavaScriptString:(NSString*)jsCode;
-(void)callJS:(NSString*)jsCode;
-(void)callJSV2:(NSDictionary*)jsDic;
-(void)frame:(CGRect)frame;
-(CGRect)frame;
-(void)reload;
-(void)webViewForceReload;//强制重新加载url

-(id)webView;
-(id)scrollView;
-(void)scrollEnable:(BOOL)enable;
//-(BOOL)isBridgeV2;

-(void)cancel;// 如果controller dealloc 必须调用！！！！！！

@end


@interface JVWebView (WebViewActionWatcher)

- (BOOL)checkWebUrlLocationChange:(NSURL *)url pageStartURL:(NSURL *)pageStartURL;

@end


