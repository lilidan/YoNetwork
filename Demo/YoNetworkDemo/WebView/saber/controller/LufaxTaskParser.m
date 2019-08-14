#import "LufaxTaskParser.h"
#import "LufaxRootViewController.h"
#import "JVUtility.h"
#import "JVLocalModel.h"
#import "DESCryptor.h"
#import "LFXUIAssistor.h"


@interface LufaxTaskParser()
{
    NSMutableDictionary     * headInfo;
    NSMutableDictionary     * footInfo;
    NSString                * rightBtnCB;
}
@property (nonatomic, strong) NSMutableArray *syncDomains;
@property (nonatomic, copy) NSString *callbackId;


@end

@implementation LufaxTaskParser

-(instancetype)init{
    self = [super init];
    if (self) {

    }
    return self;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(BOOL)parse:(NSDictionary*)taskDic{
    BOOL isHandled = YES;
    NSString* task = [taskDic objectForKey:@"task"];
    
    if([@"set_back_button_state" isEqualToString:task]){
        [self setNavigatorBackBtnStatus:taskDic];
    }
    else if([@"page" isEqualToString:task]) {
        [self pageInit:taskDic];
    }else if([@"navigation_bar" isEqualToString:task]){
        NSString *isThirdPage = taskDic[@"leftView"][@"isThirdPage"];
        self.taskVC.isThirdPage = [isThirdPage isEqualToString:@"1"] ? YES : NO;
        [self navigationBar:taskDic];
    }else if([@"bottom_view" isEqualToString:task]) {
        [self bottomView:taskDic];
    }else if([@"push_view" isEqualToString:task]){
        [self pushView:taskDic];
    }else if([@"pop_view" isEqualToString:task]) {
        [self taskPopView:taskDic];
    /*这个task是用来同步.lu.com域名下的cookie到指定的域名下*/
    }else if([@"sync_cookie" isEqualToString:task] ){
        if (self.syncDomains == nil) {
            self.syncDomains = [NSMutableArray array];
        }
        NSString *domainKey = [taskDic objectForKey:@"domainKey"];
        if (![self.syncDomains containsObject:domainKey]) {
            [self.syncDomains addObject:domainKey?:@""];
        }
        [self syncForeignAccountCookie:taskDic];
    }else if([@"http_request" isEqualToString:task]) {
        [self taskHttpRequest:taskDic];
    }else if([@"alert_view" isEqualToString:task]) {
        [(LufaxRootViewController*)self.taskVC showAlertView:taskDic];
    }else if([@"open_url" isEqualToString:task]) {
        [[UIApplication sharedApplication] openURL:[taskDic objectForKey:@"url"]?:@""];
    }else if([@"paste_board" isEqualToString:task]) {
        [self taskPasteBoard:taskDic];
    }else if([@"navi_bar" isEqualToString:task]) {
        [self taskNaviBar:taskDic];
    }else if([@"phoneCall" isEqualToString:task]) {
        [self taskPhoneCall:taskDic];
    }else if([@"reset_refresh_view" isEqualToString:task]) {
        [self taskResetRefreshView:taskDic];
    }else if([@"scroll_to_top" isEqualToString:task]) {
        [self taskScrollToTop:taskDic];
    }else if([@"title_view" isEqualToString:task]) {
        [self taskTitleView:taskDic];
    }else if([@"present_view_controller" isEqualToString:task]) {
        [self taskPresentViewController:taskDic];
    }else if([@"save_local_data" isEqualToString:task]) {
        [self taskSaveLocalData:taskDic];
    }else if([@"get_local_data" isEqualToString:task]) {
        [self taskGetLocalData:taskDic];
    }else if([@"open_pdf" isEqualToString:task]) {
//        NSMutableDictionary *mutableTask = [taskDic mutableCopy];
//        NSString *url = [taskDic st_stringForKey:@"url" defaultValue:@""];
//        if (url.length==0) {
//            [mutableTask setObject:[taskDic st_stringForKey:@"webUrl" defaultValue:@""] forKey:@"url"];
//        }
//        [LFGlobalMethod openPDFFile:mutableTask withNavigationCtrl:self.taskVC.navigationController];
    }else if([@"back_button" isEqualToString:task]) {
        [(LufaxRootViewController*)self.taskVC backButtonTaskParserImp:taskDic];
    }else if([@"right_button" isEqualToString:task]) {
        [self taskRightButton:taskDic];
    }else if([@"login" isEqualToString:task]) {
//        [(LufaxRootViewController*)self.taskVC loginTaskParserImp:taskDic];
    }else if([@"enable_scroll" isEqualToString:task]) {
        [self taskEnableScroll:taskDic];
    } else{
        isHandled = NO;
    }
    return isHandled;
}

#pragma mark - Task通用处理处

-(void)pushView:(NSDictionary*)param{
    NSString* pushClass = [param objectForKey:@"push_class"];
    if(pushClass&&pushClass.length>0){
        pushClass = (NSString*)[pushClass componentsSeparatedByString:@"."].lastObject;
        LufaxRootViewController* vc = [[NSClassFromString(pushClass) alloc]initWithDictionary:param];
        [self.taskVC.navigationController pushViewController:vc animated:(![param[@"anim"] isEqualToString:@"3"])];
        [self handlePushBackModel:param andVC:vc];
    }else{
        LufaxRootViewController* vc = [[self.taskVC.class alloc]initWithDictionary:param];
        [self.taskVC.navigationController pushViewController:vc animated:YES];
        [self handlePushBackModel:param andVC:vc];
    }
}

- (void)handlePushBackModel:(NSDictionary *)param andVC:(LufaxRootViewController *)vc
{
    if (param[@"backModel"]) {
        NSString *backModel = param[@"backModel"];
        if ([backModel isKindOfClass:[NSString class]] && backModel.length) {
            NSDictionary *dic = JSON_DIC_FROM_STRING(backModel);
            if (dic && [dic isKindOfClass:[NSDictionary class]]) {
                NSDictionary *backBtnBackParams = nil;
                //设置需要返回的页面的pageParams
                NSDictionary *data = dic[@"data"];
                if (data && [data isKindOfClass:[NSDictionary class]] &&
                    data[@"h5params"]) {
                    NSDictionary *h5params = data[@"h5params"];
                    if (h5params && [h5params isKindOfClass:[NSDictionary class]]) {
                        NSString *jsonStr = JSON_STRING_FROM_DIC(h5params);
                        backBtnBackParams = @{@"h5params": jsonStr ? : @""};
                    }
                }
                
                //被push出来的页面有可能是LufaxRootViewController或ParentViewController
                if ([vc isKindOfClass:[LufaxRootViewController class]]) {
                    vc.backBtnBackTag = dic[@"tag"] ? : @"";
                    vc.backBtnBackParams = backBtnBackParams;
                }
            }
        }
    }
}

-(void)setNavigatorBackBtnStatus:(NSDictionary*) param{
    NSString *isHide = [param objectForKey:@"isHide"]?:@"0";
    if ([@"1" isEqualToString:isHide]) {
        self.taskVC.navigationItem.leftBarButtonItem=nil;
        [self.taskVC.navigationItem setHidesBackButton:YES];
    }else{
        [self.taskVC initNavigationBar];
    }
}

- (NSDictionary*)adapteForNavibarStyleWithParam:(NSDictionary*)param
{
    NSMutableDictionary *retDict = [param mutableCopy];
    NSArray *colors = [self getColorsForStyle:[param objectForKey:@"naviBarStyle"]];
    
    NSMutableDictionary* naviBar = [[param objectForKey:@"naviBar"] mutableCopy];
    if (naviBar != nil) {
        [naviBar setObject:[colors firstObject] forKey:@"color"];
        [naviBar setObject:[colors objectAtIndex:2] forKey:@"titleColor"];
        [retDict setObject:naviBar forKey:@"naviBar"];
    }
    
    NSMutableDictionary* leftNaviItem = [[param objectForKey:@"leftView"] mutableCopy];
    if (leftNaviItem != nil) {
        [leftNaviItem setObject:[colors objectAtIndex:1] forKey:@"color"];
        [retDict setObject:leftNaviItem forKey:@"leftView"];
    }
    
    NSMutableDictionary* rightNaviItem = [[param objectForKey:@"rightView"] mutableCopy];
    if (rightNaviItem != nil) {
        [rightNaviItem setObject:[colors objectAtIndex:3] forKey:@"color"];
        [retDict setObject:rightNaviItem forKey:@"rightView"];
    }
    
    NSMutableDictionary* centerNaviItem = [[param objectForKey:@"centerView"] mutableCopy];
    if (centerNaviItem != nil) {
        [centerNaviItem setObject:[colors objectAtIndex:2] forKey:@"color"];
        [retDict setObject:centerNaviItem forKey:@"centerView"];
    }
    
    NSMutableDictionary* rightMenu = [[param objectForKey:@"rightMenu"] mutableCopy];
    if (rightMenu != nil) {
        [rightMenu setObject:[colors objectAtIndex:3] forKey:@"color"];
        [retDict setObject:rightMenu forKey:@"rightMenu"];
    }
    
    return retDict;
}

- (NSArray*)getColorsForStyle:(NSString*)naviBarStyle
{
    // 背景底色 左边按钮色 中间标题色 右边按钮色
    switch ([naviBarStyle integerValue]) {
        default:
        case 0:
            return @[@"FFFFFF",@"9AA2A8",@"13334D",@"9AA2A8"];
            break;
        case 1:
            return @[@"5064EB",@"FFFFFF",@"FFFFFF",@"FFFFFF"];
            break;
        case 2:
            return @[@"0E0E20",@"FFFFFF",@"FFFFFF",@"FFFFFF"];
            break;
    }
}

#define ADD_V2_BRIDGE_DIC(__TARGET__,__TASK_DIC__) if(__TARGET__)[__TARGET__ addEntriesFromDictionary:@{@"taskInfo":__TASK_DIC__}]

-(void)navigationBar:(NSDictionary*) param{
    
//    param = [self adapteForNavibarStyleWithParam:param];
    
    NSMutableDictionary* naviBar = [[param objectForKey:@"naviBar"] mutableCopy];
    NSMutableDictionary* leftNaviItem = [[param objectForKey:@"leftView"] mutableCopy];
    NSMutableDictionary* rightNaviItem = [[param objectForKey:@"rightView"] mutableCopy];
    NSMutableDictionary* centerNaviItem = [[param objectForKey:@"centerView"] mutableCopy];
    if ([[centerNaviItem valueForKey:@"tabStyle"] isEqualToString:@"indicator"]) {
        [centerNaviItem setObject:@"13334d" forKey:@"color"];
    }
    NSMutableDictionary* rightMenu = [[param objectForKey:@"rightMenu"] mutableCopy];
        
    ADD_V2_BRIDGE_DIC(naviBar, param);
    ADD_V2_BRIDGE_DIC(leftNaviItem, param);
    ADD_V2_BRIDGE_DIC(rightNaviItem, param);
    ADD_V2_BRIDGE_DIC(centerNaviItem, param);
    ADD_V2_BRIDGE_DIC(rightMenu, param);
    
    LufaxRootViewController* __taskVC = (LufaxRootViewController*)self.taskVC;
    __taskVC.h5SettingHeader=YES;
    if(naviBar)__taskVC.model.naviBar=naviBar;
    if(leftNaviItem)__taskVC.model.leftNaviItem=leftNaviItem;
    if(rightNaviItem && !rightMenu)__taskVC.model.rightNaviItem=rightNaviItem;
    if(centerNaviItem)__taskVC.model.centerNaviItem=centerNaviItem;
    if(rightMenu)__taskVC.model.rightMenu=rightMenu;
}

-(void)bottomView:(NSDictionary*) param{
    LufaxRootViewController* __taskVC = (LufaxRootViewController*)self.taskVC;
    NSMutableDictionary* bottomDic = [param mutableCopy];
    [bottomDic setValue:[param objectForKey:@"inputButton"]?@"0":[param objectForKey:@"oneButton"]?@"1":[param objectForKey:@"twoButton"]?@"2":@"" forKey:@"type"];
    __taskVC.model.bottomView=bottomDic;
}

-(void)pageInit:(NSDictionary*) param{
    LufaxRootViewController* __taskVC = (LufaxRootViewController*)self.taskVC;
    __taskVC.model.pageDic=[param mutableCopy];
}

- (void)taskPopView:(NSDictionary*) param {
    NSString *backTag = [param valueForKey:@"backTag"];
    if (backTag.length > 0) {
        //TODO:获取参数多层pop
//        UIViewController *appointVC = [LFGlobalMethod popAppointVCByPageTag:backTag param:param navigationC:self.taskVC.navigationController];
//        if (!appointVC) {
//            [self.taskVC.navigationController popToRootViewControllerAnimated:YES];
//        }else {
//            [self.taskVC.navigationController popToViewController:appointVC animated:(![param[@"anim"] isEqualToString:@"3"])];
//        }
    } else {
        [self popOnePage:param];
    }
}

-(void)popOnePage:(NSDictionary*) param{
    NSString *needRefresh = [param objectForKey:@"needRefresh"]?:@"";
    if ([needRefresh isEqualToString:@"1"]) {
        [self taskPopRefresh:param];
        return;
    }
}

-(void)taskPopRefresh:(NSDictionary*)param {
    NSArray* childVCs = self.taskVC.navigationController.childViewControllers;
    if (childVCs.count > 1) {
        UIViewController * ctrl = [childVCs objectAtIndex:childVCs.count-2];
        if([ctrl isKindOfClass:[SaberRootViewController class]]){
            [(SaberRootViewController*)ctrl refreshInfoContent];
        }
    }
    [self.taskVC.navigationController popViewControllerAnimated:YES];
}


#pragma mark -------- Other Domain Related Method --------


- (void)syncForeignAccountCookie:(NSDictionary *) taskParams{
    if (taskParams == nil) {
        return;
    }
//TODO缺少一个origin Domain
//    NSDictionary *domains = [[NSUserDefaults standardUserDefaults] ss_objectForKey:SYNC_DOMAIN_CONFIGS];
    for (NSString *key in self.syncDomains) {
//        NSDictionary *itemConfig = [domains objectForKey:key];
//        NSString *syncDomain = [itemConfig objectForKey:@"syncDomain"];
//        NSString *completeHost = [itemConfig objectForKey:@"completeHost"];
//        NSString *callbackId = [taskParams objectForKey:@"callbackId"]?:@"";
//        NSString *version = [taskParams objectForKey:@"version"];
//        if (syncDomain.length > 0 && completeHost.length > 0) {
//            NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//
//            NSArray *cookies = [storage cookiesForURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://%@", LFDOMAIN]]];
//            NSMutableArray *newCookies = [NSMutableArray array];
//            for (NSHTTPCookie *cookie in cookies) {
//                NSMutableDictionary *muArray = [cookie.properties mutableCopy];
//                [muArray setValue:syncDomain forKey:@"Domain"]; //修改.lu.com下的cookie 所属的域名
//                NSHTTPCookie *newCookie = [NSHTTPCookie cookieWithProperties:muArray];
//                [newCookies addObject:newCookie];
//            }
//            [storage setCookies:newCookies forURL:[NSURL URLWithString:completeHost] mainDocumentURL:nil];
//            if (callbackId.length > 0) {
//                if ([@"2" isEqualToString:version]) {
//                    [self.taskVC.jvWebView callJSV2:taskParams];
//                }else{
//                    [self.taskVC.jvWebView callJS:[NSString stringWithFormat:@"%@()",callbackId]];
//                }
//            }
//        }
    }
}

-(void)taskPasteBoard:(NSDictionary*)param {
    NSString * text = [param objectForKey:@"pasteText"];
    UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
    [pasteboard setString:text];
}


-(void)taskNaviBar:(NSDictionary*)param {
    NSString* show = [param objectForKey:@"show"];
    BOOL isHide = NO;
    if(![show isEqualToString:@"1"]){
        isHide= YES;
    }
    [self.taskVC.navigationController setNavigationBarHidden:isHide animated:NO];
}

-(void)taskChangeRefreshType:(NSDictionary*)param {
    NSString* refreshType = [param objectForKey:@"refreshType"];
    [(LufaxRootViewController*)self.taskVC resetRefreshViewWithRefreshType:refreshType?:@"1"];
}

-(void)taskHttpRequest:(NSDictionary*)param{
    JVRequestModel* __requestModel=[JVRequestModel new];
    //第一个请求默认为webview的第一个请求
    [__requestModel modelFromDictionary:param];
    if(!self.taskVC.model.requestModel.url&&[__requestModel.version isEqualToString:@"1"]){
        self.taskVC.model.requestModel=__requestModel;
    }
    
//    [[(LufaxRootViewController*)self.taskVC httpManager] requestByRequestModel:__requestModel];
}

-(void)taskPhoneCall:(NSDictionary*)param {
    NSString *callNow = [param objectForKey:@"callNow"]?:@"";
    NSString *phoneNo = [param objectForKey:@"phoneNo"]?:@"";
    if ([phoneNo isKindOfClass:[NSString class]] && phoneNo.length > 0) {
        phoneNo = [phoneNo stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSURL *url =[NSURL URLWithString:[[NSString alloc] initWithFormat:@"tel://%@",phoneNo]];
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

-(void)taskExtendsModel:(NSDictionary*)param {
    [self.taskVC.model modelFromDictionary:param];
}

-(void)taskResetRefreshView:(NSDictionary*)param {  //强制刷新当前页面
    NSString* noMoreContent = [param objectForKey:@"no_more_content"];
    [(SaberRootViewController*)self.taskVC resetRefreshView:noMoreContent];
}

-(void)taskScrollToTop:(NSDictionary*)param {
    [[self.taskVC.jvWebView scrollView] setContentOffset:CGPointMake(0, 0) animated:NO];
}

-(void)taskTitleView:(NSDictionary*)param{
    [self.taskVC performSelector:@selector(parseTitleView:) withObject:param afterDelay:0.3];
}

NSString* TASK_LOCAL_TEMP_KEY = @"9dh9uhpkqwp90qddfj01xiqg";
-(void)taskSaveLocalData:(NSDictionary*)param{
    JVLocalModel* __model = [[JVLocalModel alloc]init];
    [__model modelFromDictionary:param];
    if (![__model.localDataValue isKindOfClass:[NSString class]])
        return;
    [[NSUserDefaults standardUserDefaults] setObject:[DESCryptor base64StringFromText:__model.localDataValue key:TASK_LOCAL_TEMP_KEY] forKey:__model.localDataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)taskGetLocalData:(NSDictionary*)param{
    JVLocalModel* __model = [[JVLocalModel alloc]init];
    [__model modelFromDictionary:param];
    NSString *localVal = (NSString*)[[NSUserDefaults standardUserDefaults] objectForKey:__model.localDataKey];
    [(LufaxRootViewController *)self.taskVC callLocalJsModel:__model val:[DESCryptor textFromBase64String:localVal key:TASK_LOCAL_TEMP_KEY]];
}

-(void)taskPresentViewController:(NSDictionary*)param{
    SaberRootViewController* vc = [[self.class alloc]initWithDictionary:param];
    if([vc.model.isNaviRootVCWhenPresent isEqualToString:@"1"]){
        UINavigationController* naviVC = [[UINavigationController alloc]initWithRootViewController:vc];
        naviVC.transitioningDelegate=vc.transitioningDelegate;
        [self.taskVC presentViewController:naviVC animated:YES completion:nil];
    }else{
        [self.taskVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)taskRightButton:(NSDictionary*)param{
    NSString * title = [param objectForKey:@"text"];
    NSString * color = [param objectForKey:@"fontColor"];
    if (title && title.length>0) {
        rightBtnCB = [param objectForKey:@"jsCallBack"];
        UIButton * rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([[param objectForKey:@"isIcon"] isEqualToString:@"1"]) {
            NSString *iconSize = [param objectForKey:@"iconSize"];
            CGSize settingSize = [JVUtility sizeForText:@"\U0000e634" font:ICON_FONT(15)];
            rightBtn.frame = CGRectMake(0, 0, settingSize.width,    [LFXUIAssistor sharedAssistor].heightOfNavigationBar);
            rightBtn.titleLabel.font = iconSize ? ICON_FONT([iconSize intValue]) : ICON_FONT(20);
            title = [JVUtility iconFontFromHexStr:title];
        }else {
            rightBtn.titleLabel.font = JVFONT(14);
        }
        [rightBtn setTitle:title forState:UIControlStateNormal];
        [rightBtn setTitleColor:color?COLOR_HEX(color):[UIColor whiteColor] forState:UIControlStateNormal];
        [rightBtn sizeToFit];
        [rightBtn addTarget:self action:@selector(rightBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
        self.taskVC.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    }
    else{
        rightBtnCB = nil;
        self.taskVC.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)rightBtnPressed:(id)sender
{
    //如果是有红点的highlight,就去掉
    UIImageView* imgView = (UIImageView *)[(UIView*)sender viewWithTag:8500];
    if(imgView) [imgView removeFromSuperview];
    if (rightBtnCB && rightBtnCB.length>0) {
        NSString * jsParam = [NSString stringWithFormat:@"%@()",rightBtnCB];
        [self.taskVC.jvWebView callJS:jsParam];
    }
}

- (void)taskTrack:(NSDictionary*)param {
//TODO:埋点
    NSString * type = [param objectForKey:@"type"];
    NSString * logType = [param objectForKey:@"lufax_log_type"]?:@"BIZ";
    
    if ([@"event" isEqualToString:type]) {
//        [[LFTracker instance] recordEvent:[param objectForKey:@"eventDic"]
//                                   buName:BN_H5
//                                  logType:[logType isEqualToString:@"DEV"]?LogType_DEV:LogType_BIZ];
    } else if([@"screen" isEqualToString:type]) {
        NSString *screenName = [param objectForKey:@"screenName"]?:@"";
        NSDictionary *eventDic = [param objectForKey:@"eventDic"];
        if (eventDic!=nil && [eventDic isKindOfClass:[NSDictionary class]]) {
//            [[LFTracker instance] recordScreenWithName:screenName eventDic:eventDic];
        } else {
//            [[LFTracker instance] recordScreenWithName:screenName];
        }
        if ([self.taskVC.model isKindOfClass:[LufaxRootVCModel class]]) {
            ((LufaxRootVCModel*)self.taskVC.model).trackScreenName = screenName;
            ((LufaxRootVCModel*)self.taskVC.model).h5HasTrackedScreen = YES;
        }
    } else if ([@"page_exit" isEqualToString:type]) {
        NSString *screenName = [param objectForKey:@"screenName"]?:@"";
//        [[LFTracker instance] recordScreenDisappearWithName:screenName];
    }
}

- (void)taskEnableScroll:(NSDictionary*)param {
    NSString * enable = [param objectForKey:@"enable"];
    UIWebView * webView = [self.taskVC.jvWebView webView];
    if ([@"1" isEqualToString:enable]) {
        webView.scrollView.scrollEnabled = YES;
    }
    else if([@"0" isEqualToString:enable]){
        webView.scrollView.scrollEnabled = NO;
    }
}

@end
