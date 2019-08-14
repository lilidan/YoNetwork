#import "JVWebView.h"
#import "SaberRootViewController.h"
#import "SaberRefreshView.h"
#import "ArcherButton.h"
#import "SaberWrapperView.h"
#import "SaberTaskParser.h"
#import "JVUtility.h"
#import "LFXUIAssistor.h"
#import "JVRequestModel.h"

@interface SaberRootViewController ()<UIScrollViewDelegate,SaberRefreshViewDataSource,ArcherButtonDelegate,SaberWrapperViewDelegate>{
    BOOL isJSRendered;//是否调用过一次入口Render,true的情况下才能放心回调JS
    CGRect lastContentViewRect;//webview的最近一次的rect,如果相等
    NSMutableDictionary*  taskParserDic;//parser的容器类
    
}

@end

@implementation SaberRootViewController

/*初始化*/
- (void)initParam:(NSDictionary*)params
{
    [super initParam:params];
}

- (void)initModel:(NSDictionary*)params
{
    self.model = [[[self modelClass] alloc]init];
    [self.model modelFromDictionary:params];
}

/*返回当前controller的model的class*/
-(Class)modelClass{
    return [SaberRootVCModel class];
}

#pragma mark ---- viewDidLoad 上拉下拉组件初始化
-(void)initRefreshView{
    if(![self.model.refreshType isEqualToString:@"0"]){
        SaberRefreshView* __refreshView = [[SaberRefreshView alloc]initWithDictionary:@{@"refreshY":@"60",@"refreshType":self.model.refreshType,@"frameStr":NSStringFromCGRect([self.jvWebView frame])}];
        __refreshView.myDatasource=self;
        [__refreshView setListContentView:[self.jvWebView webView]];
        [self.view addSubview:__refreshView];
        self.refreshView=__refreshView;
    }
}

#pragma mark ---- viewDidLoad navigation top bar ui
-(void)initNavigationBar{
    //1---》是否显示topbar
    if([self.model.naviBarStyle isEqualToString:@"1"]){
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        //头部的title显示
        if(self.model.naviBarTitleDict){
            //如果是字典类型，用UI Engine去解析view,比如头部上是要筛选框的类型
            [self parseTitleView:self.model.naviBarTitleDict];
        }else if(self.model.naviBarTitle&&self.model.naviBarTitle.length>0){
            NSString *title = self.model.naviBarTitle;
            
            NSMutableString *mString = [[NSMutableString alloc] initWithString:title];
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:18];
            label.text = [mString copy];
            [label sizeToFit];
            
            while (CGRectGetWidth(label.frame) > 250) {
                [mString deleteCharactersInRange:NSMakeRange(mString.length-1, 1)];
                label.text = [mString copy];
                [label sizeToFit];
            }
            
            if ([title isEqualToString:[mString copy]]) {
                self.title=title;
            } else {
                self.title=[NSString stringWithFormat:@"%@...", mString];
            }
        }
    }else if([self.model.naviBarStyle isEqualToString:@"0"]){
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
    //2---》自定义返回按钮的ui
    switch ([self.model.naviBarBackBtnType integerValue]){
        case LUFAX_TYPE:{
            [self __lufaxNaviType];
        }
            break;
    }
    //3---》头部返回按钮隐藏
    if([self.model.naviBarBackBtn isEqualToString:@"0"]){
        self.navigationItem.leftBarButtonItem=nil;
        [self.navigationItem setHidesBackButton:YES];
    }
}

//initNavigationBar内部调用lufax的返回按钮类型，只有箭头没有文字
-(void)__lufaxNaviType{
    UIImage *defaultBackgroundImage = [JVUtility imageWithColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:defaultBackgroundImage forBarMetrics:UIBarMetricsDefault];
    //设置title的样式
    NSDictionary *attributes=[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:18],NSFontAttributeName, nil];
    [self.navigationController.navigationBar setTitleTextAttributes:attributes];    //自定义返回按钮
    SaberBackButton* backBtn = [[SaberBackButton alloc]initWithDictionary:self.model.backBtnDic];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    [backBtn addArcherTarget:self];
    
    if(self.model.rightBtnDic){
        ArcherButton* rightBtn = [[ArcherButton alloc]initWithDictionary:self.model.rightBtnDic];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
        [rightBtn addArcherTarget:self];
    }
    
}

#pragma mark -
#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNavigationBar];//创建头部
    [self initWebView];//创建webView
    [self initRefreshView];//创建refreshView,上拉下拉控件
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self callViewWillAppearJS];//回调js模块的机会
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [self.jvWebView cancel];
    [self myDealloc];
}

#pragma mark -
#pragma mark - webview的UI初始化
- (void)initWebView {
    if(self.model.webUrl.length>0) {
        LFXUIAssistor *uiAssistor = [LFXUIAssistor sharedAssistor];
        CGFloat topBarHeight = (self.navigationController.navigationBarHidden) ?
                                0 : uiAssistor.heightOfTopBar;
        
        CGRect webViewFrm = CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT - topBarHeight);
        // pageID 决定使用哪个 webLevel
        
        
        self.jvWebView = [[JVWebView alloc] initWithFrame:webViewFrm
                                                 webLevel:0
                                             supportSysWK:nil
                                        controlCookieTime:nil
                                            configuration:nil];
        self.jvWebView.jvWebViewDelegate= self;
        self.jvWebView.skipUTF8Encoding = [self.model.skipUTF8Encoding boolValue];
        
        [self.view addSubview:[self.jvWebView webView]];
    }
}

#pragma mark - JVWebViewDelegate
//是否开始读取URL
- (BOOL)jvWebView:(id)webview shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
//  hash会触发这个生命周期，但是不会触发后面的，所以这个初始化参数要放在后面的生命周期
//    isJSRendered=NO;
    return YES;
}
//成功开始读取
- (void)jvWebViewDidStartLoad:(id)webView{
    isJSRendered = NO;
}
//成功读取
- (void)jvWebViewDidFinishLoad:(id)webView{
    //before render
    [self resizeJVWebview];
    [self __beforeRender];
    
    [self __callJSWhenNoRequest];
    isJSRendered=YES;
    
}
//读取失败
- (void)jvWebView:(id)webView didFailLoadWithError:(NSError *)error{

}
//无论成功或者失败的回调
- (void)jvWebViewAllFinishLoad:(id)webView{

}

//js call natvie
- (void)jvWebView:(id)webview didReceiveJSNotificationWithObject:(NSObject*) __object{
    if([__object isKindOfClass:[NSDictionary class]]){
        [self jvWebView:webview didReceiveJSNotificationWithDictionary:(NSDictionary*)__object];
    }else if([__object isKindOfClass:[NSArray class]]){
        NSArray* __arr = (NSArray*)__object;
        for(NSDictionary* dictionary in __arr){
            [self jvWebView:webview didReceiveJSNotificationWithDictionary:(NSDictionary*)dictionary];
        }
    }
}

- (void)jvWebView:(id)webview didReceiveJSNotificationWithDictionary:(NSDictionary*) dictionary{
    /*1.若指定module 先ModuleTaskParser 过滤*/
    NSString* module = [dictionary objectForKey:@"module"] ;
    if(module&&module.length>1){
        module = [[module substringToIndex:1].uppercaseString stringByAppendingString:[module substringFromIndex:1]];
        module=[module stringByAppendingString:@"TaskParser"];
        SaberTaskParser* __parser = [self loadParser:module];
        if(__parser&&[__parser parse:dictionary]){
            return;
        }
        
    }
    
    /*2.预防同一task VC和TaskParser处理不一样，走VC(目前只有push_view 后续添加不要用这种形式 以后会废弃掉) */
    __weak NSObject* target=self;
    NSString* task = [dictionary objectForKey:@"task"];
    SEL taskSelector = NSSelectorFromString([NSString stringWithFormat:@"task%@:",[JVUtility camelCase:task]]);
    if([self performSelector:taskSelector  task:dictionary target:target]){
        return;
    }
    
    /*3.最底层LufaxTaskParser 过滤task*/
    SaberTaskParser* __productParser = [self loadParser:@"LufaxTaskParser"];
    if(__productParser&&[__productParser parse:dictionary]){
        return;
    }
}


#pragma mark------JVHTTPRequestDelegate

-(void)requestDidFinished:(id)responseModel responseObject:(NSString*)responseObject requestModel:(JVRequestModel*)requestModel{
    
    if((!isJSRendered&&self.model.requestModel==requestModel)||[requestModel.version isEqualToString:@"2"]){
        isJSRendered=YES;
    }
    
    [self resizeJVWebview];
    [self callSuccessJSByRequestModel:requestModel resposneObject:responseObject];
}
-(void)requestDidFailed:(id)responseModel error:(NSError*)error requestModel:(JVRequestModel*)requestModel{
    [self callErrorJSByRequestModel:requestModel operation:responseModel];
}

-(void)requestAllFinished:(id)responseModel requestModel:(JVRequestModel*)requestModel{
    [self callFinishedJSByRequestModel:requestModel];
}

#pragma mark ------动作相关的回调
//下拉刷新时候也要判断是否加载成功的保护
-(void)refreshInfoContent {
    [self refreshInfoContent:nil];
}

-(void)refreshInfoContent:(NSDictionary *) userInfo{
    if(self.jvWebView.loadStatus==WebViewLoadSuccess){
        if(self.model.pullDownCallBack&&isJSRendered){
            NSString* callJS = [NSString stringWithFormat:@"%@(null,%@)",self.model.pullDownCallBack,[self getJSParameter]];
            [self __callJSIfSuccess:callJS];
        }else{
            if(self.model.requestModel.url.length>0){
                abort();
                //
//                [[self httpManager]requestByRequestModel:self.model.requestModel];
            }
            NSMutableDictionary *mParams = [@{@"task":@"pullDown"} mutableCopy];
            if (userInfo) {
                [mParams setValue:userInfo forKey:@"result"];
            }
            //[self __callJSIfSuccessV2:@{@"task":@"pullDown"}];
            [self __callJSIfSuccessV2:[mParams copy]];
        }
    }else{
        [self resetRefreshView];
        [self __refreshWebView];
    }
}

//上拉触发
-(void)refreshInfoHistoryContent{
        //v2 trigger
        [self __callJSIfSuccessV2:@{@"task":@"pullUp"}];
        //v1 trigger
        NSString* callJS = [NSString stringWithFormat:@"pullUp(null,%@)",[self getJSParameter]];
        [self __callJSIfSuccess:callJS];
}



#pragma mark----JS回调
//页面加载成功后的回调
-(void)__beforeRender{
    [self.jvWebView callJS:[NSString stringWithFormat:@"window.beforeRender&&beforeRender(%@)",[self getJSParameter]]];
}
//当没有入口request时候的回调
-(void)__callJSWhenNoRequest{
    NSString* callJS = [NSString stringWithFormat:@"%@(\"init\",%@)",self.model.jsCallbackWhenNoRequest,[self getJSParameter]];
    [self.jvWebView callJS:callJS];
}



//request成功后
-(void)callSuccessJSByRequestModel:(JVRequestModel*)requestModel resposneObject:(NSString*)responseObject{
    NSString* callJS;
    if(![requestModel.version isEqualToString:@"2"]){
        //添加第四个参数
        if(requestModel.userInfo&&requestModel.userInfo.count>0){
            callJS = [NSString stringWithFormat:@"%@(%@,%@,%@)",requestModel.callback,responseObject,[self getJSParameter],JSON_STRING_FROM_DIC(requestModel.userInfo)];
        }else{
            callJS = [NSString stringWithFormat:@"%@(%@,%@)",requestModel.callback,responseObject,[self getJSParameter]];
        }
            [self.jvWebView callJS:callJS];
    }else{
        NSMutableDictionary* __model = [NSMutableDictionary new];
        [__model setObject:requestModel.callback forKey:@"callbackId"];
        [__model setObject:requestModel.sessionId forKey:@"sessionId"];
        [__model setObject:requestModel.task forKey:@"task"];
        [__model setObject:JSON_DIC_FROM_STRING(responseObject)?:@{} forKey:@"result"];//nil check
        [self.jvWebView callJSV2:__model];
    }
    

}
//request失败后
-(void)callErrorJSByRequestModel:(JVRequestModel*)requestModel operation:(JVResponseModel *)responseModel{
    if(requestModel.errorCallback.length>0){
        NSString * responseString = (responseModel.responseString&&responseModel.responseString.length>0)?responseModel.responseString:@"{}";
        if(![requestModel.version isEqualToString:@"2"]){
            NSString* callJS = [NSString stringWithFormat:@"%@(%@,%@,%@,%ld)",
                                requestModel.errorCallback,responseString,[self getJSParameter],JSON_STRING_FROM_DIC(requestModel.userInfo),(long)responseModel.statusCode];
            [self.jvWebView callJS:callJS];
        }else{
            NSMutableDictionary* __model = [NSMutableDictionary new];
            NSMutableDictionary *result = [[NSMutableDictionary alloc]initWithDictionary:JSON_DIC_FROM_STRING(responseString)?:@{}];
            [result setObject:[NSString stringWithFormat:@"%ld",(long)responseModel.statusCode] forKey:@"httpCode"];
            [__model setObject:requestModel.errorCallback forKey:@"callbackId"];
            [__model setObject:requestModel.sessionId forKey:@"sessionId"];
            [__model setObject:requestModel.task forKey:@"task"];
            [__model setObject:result forKey:@"result"];
            [self.jvWebView callJSV2:__model];
        }
    }
}
//request完成后（失败成功后统一回调）
-(void)callFinishedJSByRequestModel:(JVRequestModel*)requestModel{
    if(requestModel.finishCallback.length>0){
        NSString* callJS = [NSString stringWithFormat:@"%@(null,%@)",requestModel.finishCallback,[self getJSParameter]];
        [self.jvWebView callJS:callJS];
    }
}
//viewWillAppear的回调
-(void)callViewWillAppearJS{
    NSString* callJS = [NSString stringWithFormat:@"window.viewWillAppear&&viewWillAppear(null,%@)",[self getJSParameter]];
    [self __callJSIfSuccess:callJS];
}

#pragma mark - 内部方法
#pragma mark - HTTP Request

-(void)resizeJVWebview{
    [self resizeJVWebviewTop:[self.model.jvWebviewMarginTop integerValue]
                      bottom:[self.model.jvWebviewMarginBottom integerValue]];
}

-(void)resizeJVWebviewTop:(NSInteger)marginTop bottom:(NSInteger)bottom
{
    LFXUIAssistor *uiAssistor = [LFXUIAssistor sharedAssistor];
    //lastContentViewRect: x:0, y:marginTop, w:屏幕宽度 h:屏幕高度-导航栏高度(0 or 20+44)-marginTop-marginBottom
    CGFloat topBarHeight = (self.navigationController.navigationBarHidden) ?
                            0 : uiAssistor.heightOfTopBar;
    CGFloat webViewHeight = webViewHeight = APP_HEIGHT - topBarHeight - marginTop - bottom;
    lastContentViewRect =CGRectMake(0, marginTop, APP_WIDTH, webViewHeight);
    if(!CGRectEqualToRect(self.refreshView.frame,lastContentViewRect)){
        self.refreshView.frame = lastContentViewRect;
        [self.jvWebView frame:CGRectMake(0, 0, APP_WIDTH, webViewHeight)];
    }
}

-(void)resetRefreshView{
    [self resetRefreshView:@"0"];
}

-(void)resetRefreshView:(NSString*)noMoreContent{
    if(noMoreContent&&[noMoreContent isEqualToString:@"1"]){
        [self.refreshView noMoreHistoryContent];
    }else if(noMoreContent&&[noMoreContent isEqualToString:@"0"]){
        [self.refreshView hasMoreHistoryContent];
    }
    [self.refreshView resetRefreshState];
}

#pragma mark -- 调用js前先判断是否已经加载成功,
-(void)__callJSIfSuccess:(NSString*)func{
    if(self.jvWebView.loadStatus!=WebViewLoadSuccess){
        [self __refreshWebView];
    }else{
        [self.jvWebView callJS:func];
    }
}

-(void)__callJSIfSuccessV2:(NSDictionary*)dic{
    if(self.jvWebView.loadStatus!=WebViewLoadSuccess){
        [self __refreshWebView];
    }else{
        [self.jvWebView callJSV2:dic];
    }
}
//刷新webView
-(void)__refreshWebView{
    //因为在某些情况（空白状态页）会关闭scroll，所以这里统一重新设置下
    [self.jvWebView scrollEnable:YES];
    if(self.jvWebView&&self.jvWebView.loadStatus!=WebViewLoadSuccess){
        [self.jvWebView loadURLString:self.model.webUrl isLocalCache:[self.model.webViewLoadType isEqualToString:@"0"]?YES:NO];
    }
}

#pragma mark - saberViewWrapper的回调
#pragma mark -- saberViewWrapperDelegate;
-(void)saberWrapperViewPosition:(NSInteger)align weakSelf:(id)__weakSelf{
    SaberWrapperView* saberWrapper =(SaberWrapperView*)__weakSelf;
    switch (align) {
        case 0:{
            self.model.jvWebviewMarginTop = [NSString stringWithFormat:@"%f",saberWrapper.frame.size.height];
            CGRect frame = saberWrapper.frame;
            frame.origin.x =0;
            frame.origin.y = 0;
            saberWrapper.frame = frame;
        }
            break;
        case 1:{
            self.model.jvWebviewMarginBottom =[NSString stringWithFormat:@"%f",saberWrapper.frame.size.height];
            LFXUIAssistor *uiAssistor = [LFXUIAssistor sharedAssistor];
            CGRect frame = saberWrapper.frame;
            frame.origin.x =0;
            CGFloat heightOfTopBar = (self.navigationController.navigationBarHidden ? 0 : uiAssistor.heightOfTopBar);
            frame.origin.y = APP_HEIGHT - heightOfTopBar
                                - [self.model.jvWebviewMarginTop integerValue]
                                - saberWrapper.frame.size.height;
            saberWrapper.frame = frame;
        }
            break;
    }
    
}

//@Override
-(NSString*)getJSParameter{
    NSString* __str =JSON_STRING_FROM_DIC(self.model.lastPageData);
    if(!__str){
        __str=@"null";
    }
    return [NSString stringWithFormat:@"%@,%@",__str,[self getLocalInfo]];
}
//@Override
-(NSString*)getLocalInfo{
    return @"null";
}

-(BOOL)performSelector:(SEL)selector task:(NSDictionary*)taskObject target:(NSObject*)obj{
    if([obj respondsToSelector:selector]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [obj performSelector:selector withObject:taskObject];
#pragma clang diagnostic pop
        return YES;
    }else{
        return NO;
    }
}

#pragma mark------引擎相关代码
#pragma mark------针对titleView archer的ui构建  a.数据回来后要判断   b.viewDidLoad要判断    c.archer_ui的js的task
-(void)parseTitleView:(NSDictionary*)dict{
    if(dict){
        NSDictionary* titleDic = [dict objectForKey:@"naviBarTitleDict"];
        NSString* classString = (NSString*)[[dict objectForKey:@"class"] componentsSeparatedByString:@"."].lastObject;

        //这里
#if DEBUG
        [[NSException exceptionWithName:@"ArcherEngine Invalid" reason:@"ArcherEngine Invalid" userInfo:@{}] raise];
#endif
        UIView* titleView = [[NSClassFromString(classString) alloc] initWithDictionary:dict];
        if(titleView)
        {
            // 2018-01-05 对于titleView在iOS11上发生向下偏移的问题，进行修复
            if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0f) {
                NSArray *subviews = titleView.subviews;
                for (UIView *aSubview in subviews)
                {
                    CGRect originFrm = aSubview.frame;
                    aSubview.frame = CGRectMake(originFrm.origin.x,
                                                originFrm.origin.y -5,
                                                originFrm.size.width,
                                                originFrm.size.height);
                }
            }
            self.navigationItem.titleView=titleView;
        }
    }
}

#pragma mark--ArcherButtonDelegate
-(void)archerBtnClicked:(id)sender{
    ArcherButton* button = (ArcherButton*)sender;
    JVActionModel* jvActionModel=button.model.jvActionModel;
    if (jvActionModel.actionId.integerValue==JV_ACTION_NOTHING) {
        [self btnClickCallJS:button];
    }else{
        [super doJVAction:jvActionModel];
    }
}

#pragma mark--ArcherButtonDelegate
-(void)luBottomButtonClicked:(id)sender weakSelf:(id)weakSelf{
    [self archerBtnClicked:sender];
    //    [NSString stringWithFormat:@"底部按钮%ld被点击",(long)((ArcherButton*)sender).tag];
}




-(void)btnClickCallJS:(ArcherButton*)button{
    if(button.model.jsCallBack){
        [self.jvWebView callJS:button.model.jsCallBack];
    }
}

#pragma mark - parser
//返回parser
-(id)loadParser:(NSString*)moduleName{
    if(!taskParserDic){
        taskParserDic = [NSMutableDictionary dictionary];
    }
    if(![taskParserDic objectForKey:moduleName]){
        SaberTaskParser* parser =(SaberTaskParser*)[[NSClassFromString(moduleName) alloc]init];
        if (!parser) {
            parser = [[SaberTaskParser alloc] init];
        }
        //设置参数
        parser.taskVC=self;
        [taskParserDic setObject:parser forKey:moduleName];
    }
    return [taskParserDic objectForKey:moduleName];
}



@end
