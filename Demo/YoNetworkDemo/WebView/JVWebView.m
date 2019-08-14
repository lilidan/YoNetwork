#import "JVWebView.h"
#import  <AFNetworking/AFNetworking.h>
#import "Utility.h"
#import "JVUtility.h"
#define COMMON_MODULE_PATH  @"/common"
#define LOCAL_COMMON_MODULE_PATH [NSString stringWithFormat:@"%@%@%@",localPath,webContext,COMMON_MODULE_PATH]
#define FORMAT_RELATIVE_PATH [relativePath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/",webContext] withString:@""]

#define IS_EMPTY_STRING(__STR__)        (__STR__==nil||[__STR__ isEqualToString:@""])



@implementation NSData (Base64)

- (NSData*)formatWithData:(NSData*)data{
    if (data && [data length]>76) {
        
    }return data;
}

+ (NSData *)dataWithBase64EncodedString:(NSString *)string
{
    const char lookup[] =
    {
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99,
        99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 99, 62, 99, 99, 99, 63,
        52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 99, 99, 99, 99, 99, 99,
        99,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
        15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 99, 99, 99, 99, 99,
        99, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
        41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 99, 99, 99, 99, 99
    };
    
    NSData *inputData = [string dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    long long inputLength = [inputData length];
    const unsigned char *inputBytes = [inputData bytes];
    
    long long maxOutputLength = (inputLength / 4 + 1) * 3;
    NSMutableData *outputData = [NSMutableData dataWithLength:maxOutputLength];
    unsigned char *outputBytes = (unsigned char *)[outputData mutableBytes];
    
    int accumulator = 0;
    long long outputLength = 0;
    unsigned char accumulated[] = {0, 0, 0, 0};
    for (long long i = 0; i < inputLength; i++)
    {
        unsigned char decoded = lookup[inputBytes[i] & 0x7F];
        if (decoded != 99)
        {
            accumulated[accumulator] = decoded;
            if (accumulator == 3)
            {
                outputBytes[outputLength++] = (accumulated[0] << 2) | (accumulated[1] >> 4);
                outputBytes[outputLength++] = (accumulated[1] << 4) | (accumulated[2] >> 2);
                outputBytes[outputLength++] = (accumulated[2] << 6) | accumulated[3];
            }
            accumulator = (accumulator + 1) % 4;
        }
    }
    
    //handle left-over data
    if (accumulator > 0) outputBytes[outputLength] = (accumulated[0] << 2) | (accumulated[1] >> 4);
    if (accumulator > 1) outputBytes[++outputLength] = (accumulated[1] << 4) | (accumulated[2] >> 2);
    if (accumulator > 2) outputLength++;
    
    //truncate data to match actual output length
    outputData.length = outputLength;
    return outputLength? outputData: nil;
}

- (NSString *)base64EncodedStringWithWrapWidth:(NSUInteger)wrapWidth
{
    //ensure wrapWidth is a multiple of 4
    wrapWidth = (wrapWidth / 4) * 4;
    
    const char lookup[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
    
    long long inputLength = [self length];
    const unsigned char *inputBytes = [self bytes];
    
    long long maxOutputLength = (inputLength / 3 + 1) * 4;
    maxOutputLength += wrapWidth? (maxOutputLength / wrapWidth) * 2: 0;
    unsigned char *outputBytes = (unsigned char *)malloc(maxOutputLength);
    
    long long i;
    long long outputLength = 0;
    for (i = 0; i < inputLength - 2; i += 3)
    {
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[((inputBytes[i + 1] & 0x0F) << 2) | ((inputBytes[i + 2] & 0xC0) >> 6)];
        outputBytes[outputLength++] = lookup[inputBytes[i + 2] & 0x3F];
        
        //add line break
        if (wrapWidth && (outputLength + 2) % (wrapWidth + 2) == 0)
        {
            outputBytes[outputLength++] = '\r';
            outputBytes[outputLength++] = '\n';
        }
    }
    
    //handle left-over data
    if (i == inputLength - 2)
    {
        // = terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[((inputBytes[i] & 0x03) << 4) | ((inputBytes[i + 1] & 0xF0) >> 4)];
        outputBytes[outputLength++] = lookup[(inputBytes[i + 1] & 0x0F) << 2];
        outputBytes[outputLength++] =   '=';
    }
    else if (i == inputLength - 1)
    {
        // == terminator
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0xFC) >> 2];
        outputBytes[outputLength++] = lookup[(inputBytes[i] & 0x03) << 4];
        outputBytes[outputLength++] = '=';
        outputBytes[outputLength++] = '=';
    }
    
    //truncate data to match actual output length
    outputBytes = realloc(outputBytes, outputLength);
    NSString *result = [[NSString alloc] initWithBytesNoCopy:outputBytes length:outputLength encoding:NSASCIIStringEncoding freeWhenDone:YES];
    
#if !__has_feature(objc_arc)
    [result autorelease];
#endif
    
    return (outputLength >= 4)? result: nil;
}

- (NSString *)base64EncodedStringLF
{
    return [self base64EncodedStringWithWrapWidth:0];
}

@end

@implementation NSString (Base64)

- (NSString *)base64EncodedStringLF
{
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    return [data base64EncodedStringLF];
}
//去掉前面的空格
- (NSString *)stringByTrimmingPrefixWhiteSpace {
    NSUInteger i = 0;
    while (i < self.length && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}


@end


@interface JVWebView (){
    /*************************************************************
     *  比如webview访问地址是
     *  webViewUrl:http://i.lufax.com:8080/m/myaccount/asset/main.html
     *  fileName:main.html
     *  webContext:/m
     *************************************************************/
//    NSInteger level;//iOS Only 0 UIWebView 1 WKWebView
    NSString* webViewUrl;//webView读取的地址
    NSString* fileName;//文件名
    NSString* webContext;//网站的context
    NSOperationQueue* requestQueue;//iOS Only 请求的队列 下载用
    NSDictionary* mPageDict;//缓存的页面参数，防止反复获取
    
    
    BOOL __tLocalCache;
    NSString* __tUrlString;
    NSString* __tHashParam;//"#"跳转参数
    
}

@end



@implementation JVWebView (WebViewActionWatcher)

#pragma mark -
#pragma mark -  同步webview事件到uiwebview
- (BOOL)checkWebUrlLocationChange:(NSURL *)url pageStartURL:(NSURL *)pageStartURL{
    BOOL result = NO;
    if (pageStartURL != nil && url != nil) {
        // 非http的不判定为location变化
        if (![[url scheme] hasPrefix:@"http"]) {
            return NO;
        }
        // 如果url完全一致，不判定为location变化，但是也要loading
        // 1.首次打开
        // 2.刷新
        if ([url.absoluteString isEqualToString:pageStartURL.absoluteString]) {
            return YES;
        }
        if (!([pageStartURL.host isEqualToString:url.host]
              && [pageStartURL.path isEqualToString:url.path])) {
            // location 变化
            [self setWebActionBitMap:WebPageTnterruptActionLocation];
            result = YES;
        }
    }
    return result;
}

- (void)syncWebActionBitMap {
    if (self.level == 1) {
        objc_setAssociatedObject(self.wkWebView,
                                 ASSOCIATED_UIWEBVIEW_ACTION_BITMAP,
                                 [NSNumber numberWithInteger:self.webActionBitMap],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    else {
        objc_setAssociatedObject(self.uiWebView,
                                 ASSOCIATED_UIWEBVIEW_ACTION_BITMAP,
                                 [NSNumber numberWithInteger:self.webActionBitMap],
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

// schema|push_view|h5_hash_change|location|alert
- (void)parseJSCallBackTaskStr:(NSString *)task {
    if (task != nil && task.length > 0) {
        if ([task isEqualToString:@"schema"]) {
            self.webActionBitMap = self.webActionBitMap|(WebPageTnterruptActionSchema);
        }else if ([task isEqualToString:@"push_view"]) {
            self.webActionBitMap = self.webActionBitMap|(WebPageTnterruptActionPushView);
        }else if ([task isEqualToString:@"h5_hash_change"]) {
            self.webActionBitMap = self.webActionBitMap|(WebPageTnterruptActionH5HashChange);
        }
    }
}

- (void)jsBridgeCallBackFilter:(id)object {
    if(object != nil && [object isKindOfClass:[NSDictionary class]]){
        NSString *task = [object objectForKey:@"task"];
        [self parseJSCallBackTaskStr:task];
    }else if([object isKindOfClass:[NSArray class]]){
        NSArray* __arr = (NSArray*)object;
        for(NSDictionary* dictionary in __arr){
            if (dictionary != nil && [dictionary isKindOfClass:[NSDictionary class]]) {
                NSString *task = [dictionary objectForKey:@"task"];
                [self parseJSCallBackTaskStr:task];
            }
        }
    }
}

@end

@implementation JVWebView

#pragma mark - init function
- (id)initWithFrame:(CGRect)frame
           webLevel:(NSInteger)webLevel
       supportSysWK:(NSString *)supportSysWK
  controlCookieTime:(NSString *)controlCookieTime
      configuration:(WKWebViewConfiguration *)configuration {
    self = [super init];
    [self initParam];
    self.supportSysWK = supportSysWK;
    self.controlCookieTime = controlCookieTime;
    [self _webkitLevel:webLevel];
    [self initJVWebView:frame configuration:configuration];
    return self;
}

- (void)initParam {
    self.loadStatus = WebViewNotLoad;
}

- (NSInteger)_webkitLevel:(NSInteger)webLevel {
    // 根据外部参数决定使用哪个 webview 组件 添加了 supportSysWK 字段来控制支持的 iOS 版本
    self.level = webLevel;
    return _level;
}

- (void)initJVWebView:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration {
    if (_level == 1) {
        [self setupWKWebView:frame WithConfiguration:configuration];
    }
    else {
        [self setupUIWebView:frame];
    }
}

- (void)setupWKWebView:(CGRect)frame WithConfiguration:(WKWebViewConfiguration *)configuration {
    if (configuration) {
        self.wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:configuration];
    } else {
        //default configuration
        self.wkWebView = [[WKWebView alloc] initWithFrame:frame configuration:[self _defaultConfiguration]];
    }
    self.wkWebView.backgroundColor = [UIColor clearColor];
    self.wkWebView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.wkWebView.scrollView.showsHorizontalScrollIndicator = NO;
    self.wkWebView.allowsBackForwardNavigationGestures = YES;
    self.wkWebView.navigationDelegate = self;
    self.wkWebView.UIDelegate = self;
    [self syncWebActionBitMap];
    if ([self.controlCookieTime isEqualToString:@"1"]) {
        if (@available(iOS 11.0, *)) {
            WKHTTPCookieStore *cookieStore = self.wkWebView.configuration.websiteDataStore.httpCookieStore;
            [self syncCookiesToWKHTTPCookieStore:cookieStore];
        }
    }
}

- (WKWebViewConfiguration*)_defaultConfiguration {
    WKWebViewConfiguration* config = [WKWebViewConfiguration new];
    // WORKAROUND: Force the creation of the datastore by calling a method on it.
    [config.websiteDataStore fetchDataRecordsOfTypes:[NSSet<NSString *> setWithObject:WKWebsiteDataTypeCookies]
                                   completionHandler:^(NSArray<WKWebsiteDataRecord *> *records) {}];
    // 视频播放器不全屏显示 , iOS 10 以下使用 webkit-playsinline 属性
    config.allowsInlineMediaPlayback = YES;
    // 是否自动播放视频
    if (@available(iOS 10.0, *)) {
        config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
    }
    else {
        config.mediaPlaybackRequiresUserAction = NO;
    }
    
/*         ------ 先关闭 hook 拦截本地资源的功能
//    // 注册 ajax hook 先关闭 hook 功能
//    BOOL isAjaxHook = NO;
//    if (isAjaxHook) {
//        config.userContentController = [WKUserContentController new];
//        [config.userContentController ljs_installHookAjax];
//    }
//    else {
//    // 先关闭拦截功能 add by base 2018.11.16
////        if (@available(iOS 11.0, *)) {
////            NSString *customSheme = @"lufax-local";
////            LufaxSchemeHandler *handler = [[LufaxSchemeHandler alloc] init];
////            [config setURLSchemeHandler:handler forURLScheme:customSheme];
////        } else {
////            // Fallback on earlier versions
////        }
//    }
*/
    return config;
}

- (void)syncCookiesToWKHTTPCookieStore:(WKHTTPCookieStore *)cookieStore  API_AVAILABLE(ios(11.0)){
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    if (cookies.count == 0) return;
    for (NSHTTPCookie *cookie in cookies) {
        [cookieStore setCookie:cookie completionHandler:^{
            if ([cookies.lastObject isEqual:cookie]) {
                [self wkwebviewSetCookieSuccess];
            }
        }];
    }
}

- (void)setupUIWebView:(CGRect)frame {
    self.uiWebView = [[UIWebView alloc] initWithFrame:frame];
    self.uiWebView.dataDetectorTypes= UIDataDetectorTypeNone ;
    self.uiWebView.autoresizingMask = (UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth);
    self.uiWebView.scrollView.showsHorizontalScrollIndicator=NO;
    self.uiWebView.opaque = NO;
    self.uiWebView.backgroundColor = [UIColor clearColor];
    self.uiWebView.delegate = self;
    if ([self.uiWebView respondsToSelector:@selector(setKeyboardDisplayRequiresUserAction:)]) {
        [self.uiWebView setKeyboardDisplayRequiresUserAction:NO];
    }
    //去掉阴影
    for (UIView *shadowView in [self.uiWebView.scrollView subviews]) {
        if ([shadowView isKindOfClass:[UIImageView class]]) {
            shadowView.hidden = YES;
        }
    }
    [self syncWebActionBitMap];
}

- (void)setWebActionBitMap:(NSInteger)webActionBitMap {
    _webActionBitMap = webActionBitMap;
    [self syncWebActionBitMap];
}


#pragma mark - js和Native互相调用
- (void)jsToNativeImpl:(NSString*)jsonStr {
    NSError * error = nil; // 这个变量没用到
    NSObject* object = JSON_OBJ_FROM_STRING(jsonStr);
    if(!error){
        [self jsBridgeCallBackFilter:object];
        if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebView:didReceiveJSNotificationWithObject:)]){
            if(_level==1){
                [self.jvWebViewDelegate jvWebView:self.wkWebView didReceiveJSNotificationWithObject:object];
            }else{
                [self.jvWebViewDelegate jvWebView:self.uiWebView didReceiveJSNotificationWithObject:object];
            }
        }
    }
}

- (void)callJS:(NSString*)jsCode {
    if([jsCode rangeOfString:@"("].location==NSNotFound){
        jsCode=[jsCode stringByAppendingString:@"()"];
    }
    if (_level == 1) {
        [self.wkWebView evaluateJavaScript:jsCode completionHandler:^(id object, NSError *error){
        }];
    }else{
        [self.uiWebView stringByEvaluatingJavaScriptFromString:jsCode];
    }
    
    NSDictionary *dic = [Utility luGreaterThanMinDigitIntegerFromJavaScriptString:jsCode forKeys:@[@"productId",@"product_id",@"id"] defaultKey:@"productId"];
    if (dic && [dic count]>0) {
        NSString *callback = [[jsCode componentsSeparatedByString:@"("]firstObject];
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:dic];
        [event setObject:callback forKey:@"callback"];
        [event setObject:@"productIdTracker" forKey:@"category"];
        if ([self trackUrlFromWebView]) {
            [event setObject:[self trackUrlFromWebView] forKey:@"requestUrl"];
        }
    }
}

- (void)callJavaScriptString:(NSString*)jsCode {
    if (_level == 1) {
        [self.wkWebView evaluateJavaScript:jsCode completionHandler:^(id object, NSError *error){}];
    }
    else{
        [self.uiWebView stringByEvaluatingJavaScriptFromString:jsCode];
    }
}

- (NSString *)trackUrlFromWebView {
    NSString *requestUrl = nil;
    if (self.uiWebView) {
        requestUrl = [self.uiWebView.request.URL absoluteString];
    }else if (self.wkWebView) {
        requestUrl = [self.wkWebView.URL absoluteString];
    }
    return requestUrl;
}

- (void)callJSV2:(NSDictionary*)jsDic {
    NSString* jsCode = [self jsCallBackWrapper:JSON_STRING_FROM_DIC(jsDic)];
    [self callJS:jsCode];
}

- (NSString*)jsCallBackWrapper:(NSString*)paramStr{
    return [NSString stringWithFormat:@"Bridge.appCallback('%@')",[paramStr base64EncodedStringLF]];
}

#pragma mark -
#pragma mark - 加载地址
- (void)loadURLString:(NSString*)urlString{
    [self loadURLString:urlString params:nil isLocalCache:YES];
}

- (void)loadURLString:(NSString*)urlString isLocalCache:(BOOL)isLocalCache{
    [self loadURLString:urlString params:nil isLocalCache:isLocalCache];
}

//iOS由于延迟执行关系，所以要单独一个方法
-(void)loadDelayURLString{
    [self loadURLString:__tUrlString isLocalCache:__tLocalCache];
}

- (void)loadURLString:(NSString*)urlString params:(NSString *)param isLocalCache:(BOOL)isLocalCache{
    
    
    //如果存在hash，则截取
    if([urlString rangeOfString:@"#"].location!=NSNotFound){
        NSArray* __arr = [urlString componentsSeparatedByString:@"#"];
        if(__arr&&__arr.count>0){
            __tHashParam=__arr[1];
        }
    }
    NSURL *url;
    BOOL isLocal=YES;
    NSString* urlStr=urlString;
    __tUrlString=urlStr;
    __tLocalCache=isLocalCache;

    urlString = [urlString stringByReplacingOccurrencesOfString:@"http://jv.com:8080/" withString:@"bundle://"];
    urlString = [urlString stringByReplacingOccurrencesOfString:@"https://jv.com:8080/" withString:@"bundle://"];
    
    //强制是bundle，则要替换，
    if(isLocalCache &&
       [urlString rangeOfString:@"bundle://"].location==NSNotFound &&
       [urlString rangeOfString:@"file://"].location==NSNotFound){
        url=[NSURL URLWithString:urlStr];
        if(!url){
            return;
        }
        NSString* ctx=@"";
        NSArray * relativePathArray = [url.relativePath componentsSeparatedByString:@"/"];
        if (relativePathArray.count > 1) {
            NSString * target = relativePathArray[1];
            ctx = [[@"/" stringByAppendingString:target] stringByAppendingString:@"/"];
        }
        urlString =[@"bundle:/" stringByAppendingString:url.relativePath];
        urlString=[urlString stringByReplacingOccurrencesOfString:ctx withString:@"/hybrid/"];
    }
    
    if([urlString hasPrefix:@"http://" ]||[urlString hasPrefix:@"https://" ])
    {
        isLocal=NO;
    }
    else if([urlString hasPrefix:@"bundle://" ])
    {
        NSString *relationPath
        = [urlString stringByReplacingOccurrencesOfString:@"bundle://" withString:@""];
        
        // 判断bundle://请求是本地hybrid资源，还是其他资源，
        // 如果是hybrid则访问shadow，如果是其他资源则直接访问mainBundle
        NSRange hybridRange = [urlString rangeOfString:@"bundle://hybrid"];
//        if (hybridRange.length > 0 && hybridRange.location == 0)
//        {
//            BundleShadow *shadow = [BundleShadow sharedBundle];
//
//            urlStr = shadow.shadowPath;
//            NSArray *pathComponents = [relationPath componentsSeparatedByString:@"/"];
//            for (NSString *aPathComponent in pathComponents)
//            {
//                urlStr = [urlStr stringByAppendingPathComponent:aPathComponent];
//            }
//
//            // 由于bundle scheme中可能带#等多余的参数，
//            // 需要截取之前的path作为资源路径再进行检查
//            NSString *shadowPath = urlStr;
//            NSRange sharpRange = [shadowPath rangeOfString:@"#"];
//            if (sharpRange.length > 0 && sharpRange.location != NSNotFound)
//            {
//                shadowPath = [shadowPath substringToIndex:sharpRange.location];
//            }
//
//            BundleMapping *aMapping = [BundleShadow findUnzipHybridMapping];
//            if (aMapping == nil)
//            {
//                // mapping任务不存在，则创建一个mapping任务
//                aMapping = [BundleShadow registerUnzipHybridMapping];
//            }
//
//            // 检查默认bundleShadow路径是否存在，如果不存在，则找bundleShadow补偿
//            NSFileManager *fileMgr = [NSFileManager defaultManager];
//            if ([fileMgr fileExistsAtPath:shadowPath] == NO || aMapping.mappingResult == NO)
//            {
//                [shadow executeMapping:aMapping];
//            }
//            else
//            {
//            }
//        }
//        else
//        {
//            urlStr = BUNDLE_WITH_PATH(relationPath);
//        }
//
        urlStr = [NSString stringWithFormat:@"file://%@",urlStr];
    }
    
    if(__tHashParam&&__tHashParam.length>0&&[urlStr rangeOfString:@"#"].location==NSNotFound){
        urlStr = [[urlStr stringByAppendingString:@"#"]stringByAppendingString:__tHashParam];
    }

    url=[NSURL URLWithString:[urlStr stringByTrimmingPrefixWhiteSpace]];
    // init webview 常用参数
    [self __initUrlParams:url.absoluteString relativePath:url.relativePath];
    
    //TODO:可以修改CachePolicy
    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:cachePolicy
                                        timeoutInterval:0];
    
    // 2018-04-09 根据需要为webview的请求添加deviceId（不考虑页面内部的Ajax和302重定向问题）
    NSMutableURLRequest *mutableRequest = [request mutableCopy];
//    [mutableRequest addValue:glUUID?:@"" forHTTPHeaderField:@"x-device-id"];
    request = [mutableRequest copy];
    if (_level == 1) {
        [self checkWkWebviewSupportSystems: mutableRequest];
    }
    else {
        [self.uiWebView loadRequest:request];
    }
}

- (void)checkWkWebviewSupportSystems:(NSMutableURLRequest *)mutableRequest {
    if ([self.supportSysWK isKindOfClass:[NSString class]] && self.supportSysWK.length > 0) {
        CGFloat sys = self.supportSysWK.floatValue;
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= sys) {
            if (sys >= 8.0 && sys < 11) {
                // 添加 cookies
                mutableRequest = [self addCookieForRequestHeaderFields:mutableRequest];
                [self.wkWebView loadRequest:[mutableRequest copy]];
                [self wkwebviewTrack];
            }
            else {
                [self loadRequstWKWebviewWithSupportSystem11:mutableRequest];
            }
        }
        else {
            [self defaultLoadRequestWKWebview: mutableRequest];
        }
    }
    else {
        [self defaultLoadRequestWKWebview: mutableRequest];
    }
}

#pragma mark - WKWebview 只支持 iOS 11 以上
- (void)loadRequstWKWebviewWithSupportSystem11:(NSMutableURLRequest *)mutableRequest {
    if (@available(iOS 11.0, *)) {
        [self loadRequestWKWebviewWithSys11Plus:mutableRequest];
    }
    else {
        [self defaultLoadRequestWKWebview:mutableRequest];
    }
}

- (void)loadRequestWKWebviewWithSys11Plus:(NSMutableURLRequest *)mutableRequest {
    if (@available(iOS 11.0, *)) {
        if ([self.controlCookieTime isEqualToString:@"1"]) {
            [self.wkWebView loadRequest:[mutableRequest copy]];
        }
        else {
            WKHTTPCookieStore *cookieStore = self.wkWebView.configuration.websiteDataStore.httpCookieStore;
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
            if (cookies.count == 0) {
                [self.wkWebView loadRequest:[mutableRequest copy]];
                return;
            }
            for (NSHTTPCookie *cookie in cookies) {
                [cookieStore setCookie:cookie completionHandler:^{
                    if ([cookies.lastObject isEqual:cookie]) {
                        [self.wkWebView loadRequest:[mutableRequest copy]];
                    }
                }];
            }
        }
        [self wkwebviewIOS11PlusTrack];
    }
}

#pragma mark - WKWebview 默认支持 iOS 8 以上
- (void)defaultLoadRequestWKWebview:(NSMutableURLRequest *)mutableRequest {
    if (@available(iOS 11.0, *)) {
        [self loadRequestWKWebviewWithSys11Plus:mutableRequest];
    }
    else {
        // 添加 cookies
        mutableRequest = [self addCookieForRequestHeaderFields:mutableRequest];
        [self.wkWebView loadRequest:[mutableRequest copy]];
        [self wkwebviewTrack];
    }
}

//注入JS now implement by controller
-(void)importJS{
    if([self.jvWebViewDelegate respondsToSelector:@selector(importGlobalJS)]){
        NSString* jsScript = [self.jvWebViewDelegate importGlobalJS];
        if(_level==1){
            [self.wkWebView evaluateJavaScript:jsScript completionHandler:^(id object, NSError *error){}];
        }else{
            [self.uiWebView stringByEvaluatingJavaScriptFromString:jsScript];
        }
    }
}

//读取html的内容
-(void)loadHtmlString:(NSString*)htmlString{
    if(_level==1){
        [self.wkWebView loadHTMLString:htmlString baseURL:nil];
    }else{
        [self.uiWebView loadHTMLString:htmlString baseURL:nil];
    }
}

//读取外部地址，理论上刷新都调用reload
-(void)__loadWebUrl{
    if(webViewUrl&&webViewUrl.length>0){
        [self loadURLString:webViewUrl];
    }
}
//刷新地址
-(void)reload{
    self.loadStatus=WebViewNotLoad;
    [self __loadWebUrl];
}

/**
 * 初始化url信息
 */
-(void)__initUrlParams:(NSString*)path relativePath:(NSString*)relativePath{
    NSArray* arr = [path componentsSeparatedByString:@"/"];
    fileName = [arr objectAtIndex:arr.count-1];
    webViewUrl = path;
    NSArray * relativePathArray = [relativePath componentsSeparatedByString:@"/"];
    if (relativePathArray&&relativePathArray.count > 1) {
        NSString * target = relativePathArray[1];
        webContext = [@"/" stringByAppendingString:target];
    }
}

#pragma mark - 解决首次加载丢失 cookie 问题
- (NSMutableURLRequest *)addCookieForRequestHeaderFields:(NSMutableURLRequest *)mutableRequest {
//    NSArray *cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies;
//    NSMutableArray *mutableCookies = @[].mutableCopy;
//    for (NSHTTPCookie *cookie in cookies) {
//        [mutableCookies addObject:cookie];
//    }
//    // Cookies数组转换为requestHeaderFields
//    NSDictionary *requestHeaderFields = [NSHTTPCookie requestHeaderFieldsWithCookies:(NSArray *)mutableCookies];
//    // 设置请求头
//    mutableRequest.allHTTPHeaderFields = requestHeaderFields;
    [self updateWebViewCookie];
    return mutableRequest;
}

#pragma mark - 解决 ajax 请求 cookie 丢失问题
- (void)updateWebViewCookie {
    WKUserScript * cookieScript = [[WKUserScript alloc] initWithSource:[self cookieString] injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    // 添加Cookie
    [self.wkWebView.configuration.userContentController addUserScript:cookieScript];
}

- (NSString *)cookieString {
    NSMutableString *script = [NSMutableString string];
    [script appendString:@"var cookieNames = document.cookie.split('; ').map(function(cookie) { return cookie.split('=')[0] } );\n"];
    for (NSHTTPCookie *cookie in NSHTTPCookieStorage.sharedHTTPCookieStorage.cookies) {
        // Skip cookies that will break our script
        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
            continue;
        }
        // Create a line that appends this cookie to the web view's document's cookies
        [script appendFormat:@"if (cookieNames.indexOf('%@') == -1) { document.cookie='%@'; };\n", cookie.name, [self javascriptString:cookie]];
    }
    return script;
}

- (NSString *)javascriptString:(NSHTTPCookie *)cookie {
    NSString *string = [NSString stringWithFormat:@"%@=%@;domain=%@;path=%@",
                        cookie.name,
                        cookie.value,
                        cookie.domain,
                        cookie.path ?: @"/"];
    if (cookie.secure) {
        string = [string stringByAppendingString:@";secure=true"];
    }
    return string;
}


#pragma mark -
#pragma mark - UIWebViewDelegate
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    BOOL isRequest=YES;
    NSString* jsNotId = [self __getJSNotificationId:[request URL]];
    NSString* urlStr = [request URL].absoluteString;
    if(jsNotId){
        isRequest=NO;
        NSString* jsonStr = [self.uiWebView stringByEvaluatingJavaScriptFromString:[NSString  stringWithFormat:@"JSBridge_getJsonStringForObjectWithId(%@)", jsNotId]];
        [self jsToNativeImpl:jsonStr];
    }else if([urlStr hasPrefix:@"ios://"]){//iOS特有的，android则应该是方法直接调用，主要是应对某些简单页面没有加载jsBridge.js的页面
        isRequest=NO;
        NSString* jsonStr = [urlStr stringByReplacingOccurrencesOfString:@"ios://" withString:@""];
        jsonStr=[NSString stringWithFormat:@"{\"task\":\"%@\"}",jsonStr];
        [self jsToNativeImpl:jsonStr];
    }else{
        if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebView:shouldStartLoadWithRequest:navigationType:)]){
            isRequest=[self.jvWebViewDelegate jvWebView:webView shouldStartLoadWithRequest:request navigationType:navigationType];
        }
    }
    
    return isRequest;
}

-(void)webViewDidStartLoad:(UIWebView *)webView{
    [self importJS];
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewDidStartLoad:)]){
        [self.jvWebViewDelegate jvWebViewDidStartLoad:webView];
    }
}

-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [self __jvWebViewDidFinishLoad];
    
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewDidFinishLoad:)]){
        [self.jvWebViewDelegate jvWebViewDidFinishLoad:webView];
    }
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewAllFinishLoad:)]){
        [self.jvWebViewDelegate jvWebViewAllFinishLoad:webView];
    }
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [self __jvWebView:webView didFailLoadWithError:error];
}

//注意，webview参数可能为空，是由于缓存模式去请求失败触发的回调
- (void)__jvWebView:(id)webView didFailLoadWithError:(NSError *)error{
    self.loadStatus=WebViewLoadFailed;
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebView:didFailLoadWithError:)]){
        [self.jvWebViewDelegate jvWebView:webView didFailLoadWithError:error];
    }
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewAllFinishLoad:)]){
        [self.jvWebViewDelegate jvWebViewAllFinishLoad:webView];
    }
}

#pragma mark -
#pragma mark - iOS 8(WKWebView) Only WKNavigationDelegate
#pragma mark  WKNavigationDelegate
//决定是否打开页面
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    BOOL isRequest = YES;
    NSString *jsNotId = [self __getJSNotificationId:[navigationAction.request URL]];
    NSString *urlStr = [navigationAction.request URL].absoluteString;
    if (jsNotId) {
        // 符合 js to native 的方法
        isRequest = NO;
        [self handleJSBridgeGetJsonStringForJsNotId:jsNotId];
    }
    else if ([urlStr hasPrefix:@"ios://"]) {
        // iOS特有的，android则应该是方法直接调用，主要是应对某些简单页面没有加载jsBridge.js的页面
        isRequest = NO;
        [self handleSpecialJSBridgeTask:urlStr];
    }
    else {
        if ([self.jvWebViewDelegate respondsToSelector:@selector(jvWebView:shouldStartLoadWithRequest:navigationType:)]) {
            isRequest = [self.jvWebViewDelegate jvWebView:webView shouldStartLoadWithRequest:navigationAction.request navigationType:UIWebViewNavigationTypeOther];
        }
    }
    
    if (isRequest) {
        decisionHandler(WKNavigationActionPolicyAllow);
    } else {
        decisionHandler(WKNavigationActionPolicyCancel);
    }
}

//开始请求页面
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self importJS];
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewDidStartLoad:)]){
        [self.jvWebViewDelegate jvWebViewDidStartLoad:webView];
    }
}

//读取成功
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self __jvWebViewDidFinishLoad];
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewDidFinishLoad:)]){
        [self.jvWebViewDelegate jvWebViewDidFinishLoad:webView];
    }
    if([self.jvWebViewDelegate respondsToSelector:@selector(jvWebViewAllFinishLoad:)]){
        [self.jvWebViewDelegate jvWebViewAllFinishLoad:webView];
    }
}

//地址正确，返回的response有问题
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    [self __jvWebView:webView didFailLoadWithError:error];
    NSDictionary *userInfo = error.userInfo;
    NSMutableDictionary *mutDic = [[NSMutableDictionary alloc] initWithCapacity:5];
    [mutDic addEntriesFromDictionary:userInfo];
    [mutDic addEntriesFromDictionary:@{@"category":@"wkwebview_didFailProvisionalNavigation",
                                       @"title":@"wkwebview_loadrequest"
                                       }];
    [self didFailProvisionalNavigationTarck:(NSDictionary *)mutDic];
}
//地址出错会有问题
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation
      withError:(NSError *)error {
    [self __jvWebView:webView didFailLoadWithError:error];
}

// 处理 JSBrige 桥接
- (void)handleJSBridgeGetJsonStringForJsNotId:(NSString *)jsNotId {
    NSString *jsonStr = [NSString stringWithFormat:@"JSBridge_getJsonStringForObjectWithId(%@)", jsNotId];
    __weak typeof(self) weakSelf = self;
    [self.wkWebView evaluateJavaScript:jsonStr completionHandler:^(id object, NSError * _Nullable error) {
        __strong typeof(self)  strongSelf = weakSelf;
        NSString *jsCallbackStr = (NSString *)object;
        if (jsCallbackStr == (NSString *)[NSNull null]) {
            return ;
        }
        if (IS_EMPTY_STRING(jsCallbackStr)) {
            return ;
        }
        [strongSelf jsToNativeImpl:jsCallbackStr];
    }];
}

// 处理 special jsbridge
- (void)handleSpecialJSBridgeTask:(NSString *)urlStr {
    NSString *jsonStr = [urlStr stringByReplacingOccurrencesOfString:@"ios://" withString:@""];
    jsonStr = [NSString stringWithFormat:@"{\"task\":\"%@\"}",jsonStr];
    [self jsToNativeImpl:jsonStr];
}

#pragma mark WKScriptMessageHandler js to native 这个方法没法用，因为需要兼容旧版本逻辑
//-(void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
//    //    NSLog(@"%@,%@",message.name,message.body);
//    //    NSLog(@"%@,%@",message.webView,message.frameInfo);
//    [self jsToNativeImpl:message.body];
//}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    if (challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }
}

#pragma mark  WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    //    NSString *hostString = frame.request.URL.host;
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    //一定要present
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^(void){
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        //textField.placeholder = defaultText;
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    //一定要present
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);//js的返回值
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);//js的返回值
    }]];
    //一定要present
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:YES completion:^(void){
    }];
}


#pragma mark -
#pragma mark - private function
-(id)webView{
    if(_level==1){
        return self.wkWebView;
    }else{
        return self.uiWebView;
    }
}

-(id)scrollView{
    if(_level==1){
        return self.wkWebView.scrollView;
    }else{
        return self.uiWebView.scrollView;
    }
}

-(void)scrollEnable:(BOOL)enable{
    ((UIScrollView*)[self scrollView]).scrollEnabled=enable;
}


-(void)frame:(CGRect)frame{
    if(_level==1) {
        self.wkWebView.frame=frame;
        //        self.wkWebView.scrollView.contentSize=frame.size;
    }else{
        self.uiWebView.frame=frame;
        //        self.uiWebView.scrollView.contentSize=frame.size;
    }
}

-(CGRect)frame{
    if(_level==1) {
        return self.wkWebView.frame;
    }else{
        return self.uiWebView.frame;
    }
}




-(NSString*)__getJSNotificationId:(NSURL*) p_Url
{
    NSString* strUrl = [p_Url absoluteString];
    NSString* result = nil;
    NSString *lowCaseStrUrl = [strUrl lowercaseString];
    if ([lowCaseStrUrl hasPrefix:@"jsbridge://bridge.lu.com?readnotificationwithid="]) {
        NSRange range = [strUrl rangeOfString:@"="];
        NSInteger index = range.location + range.length;
        result = [strUrl substringFromIndex:index];
    }
    
    NSString *queryStr = [p_Url query];
    
    if (result == nil && [queryStr hasPrefix:@"ReadNotificationWithId="]) {
        NSRange range = [queryStr rangeOfString:@"="];
        NSInteger index = range.location + range.length;
        result = [queryStr substringFromIndex:index];
    }
    
    return result;
}

-(void)__jvWebViewDidFinishLoad{
    self.loadStatus=WebViewLoadSuccess;
    //创建基本css class回调fun
    NSDictionary* deviceInfo = @"";
    NSString* deviceDesc = @"";
    NSString* osVersion = [NSString stringWithFormat:@"ov_%@" ,[deviceInfo objectForKey:@"osVersion"]];
    NSString* widthInPixels = [NSString stringWithFormat:@"w_p_%@" ,[deviceInfo objectForKey:@"widthInPixels"]];
    NSString* heightInPixels = [NSString stringWithFormat:@"h_p_%@" ,[deviceInfo objectForKey:@"heightInPixels"]];
    NSString* width = [NSString stringWithFormat:@"w_%@" ,[deviceInfo objectForKey:@"width"]];
    NSString* height = [NSString stringWithFormat:@"h_%@" ,[deviceInfo objectForKey:@"height"]];
    NSString* ppidesc = [NSString stringWithFormat:@"ppi_%@" ,[deviceInfo objectForKey:@"ppi"]];
    NSString* classStr = [NSString stringWithFormat:@"%@ %@ %@ %@ %@ %@ %@ %@",[deviceInfo objectForKey:@"os"],deviceDesc,osVersion,widthInPixels,heightInPixels,width,height,ppidesc];
    
    NSMutableDictionary* mutDic = [[NSMutableDictionary alloc]initWithDictionary:deviceInfo];
    [mutDic setObject:classStr forKey:@"className"];
    NSString* infoStr = @"";
    if (mutDic && [NSJSONSerialization isValidJSONObject:mutDic]) {
       infoStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:mutDic options:NSJSONWritingPrettyPrinted error:nil]encoding:NSUTF8StringEncoding];
    }
    NSString* jsFun = [NSString stringWithFormat:@"window.JSBridgeRegisterAppInfo&&JSBridgeRegisterAppInfo(%@)",infoStr];
    [self callJS:jsFun];
    //    [self importJS:@"window.LU_MI_URL=\"99999\""];
    [self importJS];
}

-(NSOperationQueue*)requestQueue{
    if(!requestQueue){
        requestQueue=[NSOperationQueue new];
    }
    return requestQueue;
}

-(void)webViewForceReload{
    if(_level==1){
        [self.wkWebView reload];
    }else{
        [self.uiWebView reload];
    }
}


-(NSURLRequest *)__createOneDefaultRequestByUrl:(NSURL*)nsUrl{
    //    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl];
    NSURLRequestCachePolicy cachePolicy = NSURLRequestUseProtocolCachePolicy;
    NSURLRequest* request = [NSURLRequest requestWithURL:nsUrl cachePolicy:cachePolicy timeoutInterval:0];
    return request;
}

-(void)cancel{
    [[self requestQueue] cancelAllOperations];
    //有可能有延时执行的代码，比如下载时候的等待
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


-(void)dealloc{
    if (_level == 1) {
        self.wkWebView.scrollView.delegate = nil;// 防止 iOS 9 崩溃 !!!
    } else {
        //UIWebView
        if (self.uiWebView.loading) {
            [self.uiWebView stopLoading];
        }
        self.uiWebView.delegate = nil;
    }
}

#pragma mark -
#pragma mark - 设置delegate
- (void)setDelegate:(id <UIWebViewDelegate>) newDelegate {
    if([newDelegate conformsToProtocol:@protocol(JVWebViewDelegate)]){
        self.jvWebViewDelegate  = (id<JVWebViewDelegate>) newDelegate;
    }
}

- (id)delegate {
    return self.jvWebViewDelegate;
}

#pragma mark -
#pragma mark - 埋点
- (void)wkwebviewSetCookieSuccess {

}

- (void)wkwebviewIOS11PlusTrack {

}

- (void)wkwebviewTrack {

}

- (void)didFailProvisionalNavigationTarck:(NSDictionary *)recordEvent {
}

@end

