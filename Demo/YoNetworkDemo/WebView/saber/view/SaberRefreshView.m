#import "SaberRefreshView.h"
#import <WebKit/WebKit.h>

@interface SaberRefreshView ()

//@property (nonatomic, assign) BOOL bScrollStartNotificationSend;
//@property (nonatomic, assign) BOOL bScrollEndNotificationSend;
//@property (nonatomic, strong) ACYTableViewRefreshView *refreshView;
//@property (nonatomic, assign) CGFloat lastOffsetY;

@end

@implementation SaberRefreshView

//INIT_WITH_JSON_STRING INIT_WITH_DICTIONARY
//-(void)initParam:(NSDictionary*)params{
//    self.model = [SaberRefreshModel new];
//    [self.model modelFromDictionary:params];
//    refreshY=[self.model.refreshY integerValue];
//    refreshState=SABER_NORMAL;
//    isMoreHistoryContent=YES;
//    historyState=SABER_HISTORY_NORMAL;
//
//    if([self.model.refreshType isEqualToString:@"2"]){
//        self.historyRefreshDisabled=NO;
//    }else{
//        self.historyRefreshDisabled=YES;
//    }
//
//    _minNotifyOffsetY=0;
//    if(self.model.frameStr){
//        self.frame=CGRectFromString(self.model.frameStr);
//    }
//
//    self.lastOffsetY = 0.0;
//}
//
//#pragma mark ---- view init;implement by subclass;
//-(void)initView{
//    [self initTitleView];
//    if(!self.historyRefreshDisabled){
//        [self initBottomView];
//    }
//}
//
//
//
//-(void)initTitleView {
//    ACYTableViewRefreshView *view = [ACYTableViewRefreshView new];
//
//    CGFloat x = 195;
//
//    if ([UIScreen mainScreen].bounds.size.width < 750.0/2.0) {
//        x = 160.0;
//    }
//
//    if ([UIScreen mainScreen].bounds.size.width > 400) {
//        x = 205;
//    }
//
//    view.frame = CGRectMake(x, -30, APP_WIDTH, refreshY);
//    [self addSubview:view];
//
//    self.refreshView = view;
//}
//
//-(void)initBottomView{
//    self.bottomView=[[UIImageView alloc]initWithFrame:CGRectMake(0, self.height-refreshY, APP_WIDTH,refreshY)];
//    self.bottomView.backgroundColor=[UIColor clearColor];
//    self.refreshUpArrow=[[UIImageView alloc] initWithImage:IMAGE_WITH_NAME(@"jvbundle.bundle/refreshUpArrow")];
//    self.refreshUpArrow.frame=CGRectMake(0, 0, 25, 25);
//    self.refreshUpArrow.center=CGPointMake(self.bottomView.width/2, self.bottomView.height/2);
//    [self.bottomView addSubview:self.refreshUpArrow];
//
//    self.historyActivityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//    [self.historyActivityView setHidesWhenStopped:YES];
//    [self.historyActivityView stopAnimating];
//    self.historyActivityView.center=self.refreshUpArrow.center;
//    [self.bottomView addSubview:self.historyActivityView];
//
//}
//
////设置滚动内容的view
//-(void)setListContentView:(id)listView{
//    if([listView respondsToSelector:@selector(scrollView)]){
//        [listView scrollView].delegate=self;
//        [self initView];//初始化topview和bottomview
//        if(self.bottomView){
//            [listView addSubview:self.bottomView];
//            [listView sendSubviewToBack:self.bottomView];
//        }
//        self.listView=listView;
//        [self addSubview:listView];
//    }
//    else if ([listView isKindOfClass:[UIScrollView class]]) {
//        ((UIScrollView*)listView).delegate=self;
//        [self initView];//初始化topview和bottomview
//        if(self.bottomView){
//            [self addSubview:self.bottomView];
//            [self sendSubviewToBack:self.bottomView];
//        }
//        self.listView=listView;
//    }
//}
//
//#pragma mark ---- scrollView's delegate
//-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
//    self.bScrollEndNotificationSend = NO;
//    if (!self.bScrollStartNotificationSend) {
//        self.bScrollStartNotificationSend = YES;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollStartNotification" object:nil];
//    }
//    CGFloat offsetY = scrollView.contentOffset.y;
//    if(self.isNeedBarNotification){
//        if(offsetY<_minNotifyOffsetY){
//            _triggerNotifyOffsetY=_minNotifyOffsetY;
//        }else{
//            _triggerNotifyOffsetY=scrollView.contentOffset.y;
//        }
//    }
//}
//
//-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (scrollView.contentOffset.y < 0) {
//        CGFloat margin = self.lastOffsetY - scrollView.contentOffset.y;
//
//        CGRect rect = self.refreshView.frame;
//
//        rect.origin.y += margin;
//
//        self.refreshView.frame = rect;
//
//        if (fabs(scrollView.contentOffset.y) >= refreshY) {
//            [self.refreshView setProgress:0 animated:NO];
//            self.refreshView.circleView.hidden = NO;
//        } else {
//            [self.refreshView setProgress:fabs(scrollView.contentOffset.y)/refreshY animated:YES];
//            self.refreshView.circleView.hidden = YES;
//        }
//
//        self.lastOffsetY = scrollView.contentOffset.y;
//    }
//
//    CGFloat offsetTop=scrollView.contentSize.height-scrollView.bounds.size.height;
//    if (refreshState == SABER_LOADING) {
//        //复原位置
//        CGFloat offset = MAX(scrollView.contentOffset.y * -1, 0);
//        offset = MIN(offset, refreshY);
//        scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0f, 0.0f, 0.0f);
//    }else if (historyState == SABER_HISTORY_LOADING) {
//
//    }else if([self.model.refreshType isEqualToString:@"3"]){
//        //100逻辑点时候刷新
//        if(isMoreHistoryContent &&
//           ((offsetTop>100 && scrollView.contentOffset.y>offsetTop-100) ||
//            (offsetTop<=100 && scrollView.contentOffset.y>50))
//           ){
//            [self setHistoryRefreshState:SABER_HISTORY_LOADING];
//        }
//    }
//
//    if (scrollView.isDragging) {
//
//        if (refreshState == SABER_PULLING && scrollView.contentOffset.y > -refreshY && scrollView.contentOffset.y < 0.0f) {
//            [self setRefreshState:SABER_NORMAL];
//        } else if (refreshState == SABER_NORMAL && scrollView.contentOffset.y <= -refreshY) {
//            [self setRefreshState:SABER_PULLING];
//        } else if(refreshState ==SABER_NORMAL&&scrollView.contentOffset.y>-refreshY&&scrollView.contentOffset.y<0.0f){
//            //          滑动时候动画追踪，暂时关闭
//            //            CGFloat fraction = scrollView.contentOffset.y/-refreshY;
//            //            [self topViewAnimated:fraction];
//        }
//
//        if(!self.historyRefreshDisabled&&isMoreHistoryContent) {
//            if (historyState == SABER_HISTORY_PULLING && scrollView.contentOffset.y > offsetTop && scrollView.contentOffset.y <offsetTop+refreshY) {
//                [self setHistoryRefreshState:SABER_HISTORY_NORMAL];
//            } else if (historyState == SABER_HISTORY_NORMAL && scrollView.contentOffset.y >= offsetTop+refreshY) {
//                [self setHistoryRefreshState:SABER_HISTORY_PULLING];
//            }else if(refreshState ==SABER_HISTORY_NORMAL&&scrollView.contentOffset.y > offsetTop && scrollView.contentOffset.y <offsetTop+refreshY){
//            }
//        }
//    }
//
//
//
//
//    if([self.model.refreshType isEqualToString:@"3"]){
//        [self.myDatasource refreshListViewDidScroll:scrollView.contentOffset];
//    }
//
//    if(self.isNeedBarNotification){
//        if(scrollView.contentOffset.y>_triggerNotifyOffsetY&&_modeForBarNotify==0&&(lastNotifyDate==nil||[[NSDate date] compare:[lastNotifyDate dateByAddingTimeInterval:.6f]]==NSOrderedDescending)){
//            lastNotifyDate = [NSDate date];
//            _modeForBarNotify=1;
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"showFrameBar" object:self userInfo:@{@"isShow":@"0"}];
//        }else if(scrollView.contentOffset.y<_triggerNotifyOffsetY&&_modeForBarNotify==1&&(lastNotifyDate==nil||[[NSDate date] compare:[lastNotifyDate dateByAddingTimeInterval:.6f]]==NSOrderedDescending)){
//            lastNotifyDate = [NSDate date];
//            _modeForBarNotify=0;
//            [[NSNotificationCenter defaultCenter]postNotificationName:@"showFrameBar" object:self userInfo:@{@"isShow":@"1"}];
//        }
//    }
//}
//
//-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
//    //  if(!CGAffineTransformIsIdentity(self.arrowView.transform)){
//    CGFloat offsetTop=scrollView.contentSize.height-scrollView.bounds.size.height;
//
//    if(scrollView.contentOffset.y<=-refreshY&&refreshState!=SABER_LOADING){
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.2];
//        scrollView.contentInset = UIEdgeInsetsMake(refreshY, 0.0f, 0.0f, 0.0f);
//        [UIView commitAnimations];
//        [self setRefreshState:SABER_LOADING];
//
//    }else    if(scrollView.contentOffset.y>-refreshY && scrollView.contentOffset.y < 0.0f &&refreshState!=SABER_LOADING){
//        [self setRefreshState:SABER_NORMAL];
//    }
//
//    if(!self.historyRefreshDisabled&&isMoreHistoryContent) {
//        if (scrollView.contentOffset.y >=offsetTop+refreshY&&historyState!=SABER_HISTORY_LOADING) {
//            [UIView beginAnimations:nil context:NULL];
//            [UIView setAnimationDuration:0.2];
//            scrollView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, refreshY, 0.0f);
//            [UIView commitAnimations];
//            [self setHistoryRefreshState:SABER_HISTORY_LOADING];
//        }else   if (scrollView.contentOffset.y > offsetTop && scrollView.contentOffset.y <offsetTop+refreshY&&historyState!=SABER_HISTORY_LOADING) {
//            [self setHistoryRefreshState:SABER_HISTORY_NORMAL];
//        }
//
//
//    }
//
//    if (!decelerate) {
//        self.bScrollStartNotificationSend = NO;
//        if (!self.bScrollEndNotificationSend) {
//            self.bScrollEndNotificationSend = YES;
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollEndNotification" object:nil];
//        }
//    }
//}
//
//#pragma mark ---- implement by subclass 手指比例返回的动画控制
////-(void)topViewAnimated:(CGFloat)fraction{
////    if(fraction<1){
////        //self.refreshDownArrow.transform= CGAffineTransformMakeRotation(-M_PI*fraction);
////    }else if(fraction>=1){
////        [UIView animateWithDuration:.2 animations:^(void){
////            //self.refreshDownArrow.transform= CGAffineTransformMakeRotation(-M_PI*fraction);
////        }];
////    }
////}
//
//-(void)bottomViewAnimated:(CGFloat)fraction{
//    if(fraction<1){
//        self.refreshUpArrow.transform= CGAffineTransformMakeRotation(-M_PI*fraction);
//    }else if(fraction>=1){
//        [UIView animateWithDuration:.3 animations:^(void){
//            self.refreshUpArrow.transform= CGAffineTransformMakeRotation(-M_PI*fraction);
//        }];
//    }
//}
//
//-(void)setHistoryRefreshState:(SABER_HISTORY_STATUS)aStatus{
//    switch (aStatus) {
//        case SABER_HISTORY_LOADING:
//            historyState=SABER_HISTORY_LOADING;
//            [self.historyActivityView startAnimating];
//            [self.myDatasource refreshInfoHistoryContent];
//            [CATransaction begin];
//            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//            self.refreshUpArrow.hidden = YES;
//            [CATransaction commit];
//            break;
//        case SABER_HISTORY_NORMAL:
//            historyState=SABER_HISTORY_NORMAL;
//            [self.historyActivityView stopAnimating];
//            self.refreshUpArrow.hidden = NO;
//            [self bottomViewAnimated:0.0f];
//            break;
//        case SABER_HISTORY_PULLING:
//            historyState=SABER_HISTORY_PULLING;
//            [self.historyActivityView stopAnimating];
//            self.refreshUpArrow.hidden = NO;
//            [self bottomViewAnimated:1.0f];
//            break;
//        default:
//            break;
//    }
//
//}
//
//-(void)setRefreshState:(SABER_REFRESH_STATUS)aStatus{
//    switch (aStatus) {
//        case SABER_LOADING:
//
//            refreshState=SABER_LOADING;
//            [self.myDatasource refreshInfoContent];
//            [CATransaction begin];
//            [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
//            [CATransaction commit];
//            break;
//        case SABER_NORMAL:
//            refreshState=SABER_NORMAL;
//            // [_activityView stopAnimating];
//            // self.refreshDownArrow.hidden = NO;
//            // [self topViewAnimated:0.0f];
//            break;
//        case SABER_PULLING:
//            refreshState=SABER_PULLING;
//            //self.refreshDownArrow.hidden = NO;
//            // [self topViewAnimated:1.0f];
//            break;
//        default:
//            break;
//    }
//}
//
//-(void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
//    //  self.mWebView.userInteractionEnabled=NO;
//
//}
//
//-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    self.bScrollStartNotificationSend = NO;
//    if (!self.bScrollEndNotificationSend) {
//        self.bScrollEndNotificationSend = YES;
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"ScrollEndNotification" object:nil];
//    }
//}
//-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
//
//}
//
//-(void)delayResetState{
//    if([self.model.refreshType isEqualToString:@"3"]&&historyState==SABER_HISTORY_LOADING){
//        [self performSelector:@selector(resetRefreshState) withObject:nil afterDelay:1.0];
//    }else{
//        [self resetRefreshState];
//    }
//}
//
//-(void)resetRefreshState{
//    if(refreshState==SABER_LOADING){
//        [self setRefreshState:SABER_NORMAL];
//        isMoreHistoryContent=YES;
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.2];
//        if ([self.listView respondsToSelector:@selector(scrollView)]) {
//            [self.listView scrollView].contentInset =UIEdgeInsetsZero;
//        }
//        else if ([self.listView isKindOfClass:[UIScrollView class]]) {
//            ((UIScrollView*)self.listView).contentInset =UIEdgeInsetsZero;
//        }
//
//        [UIView commitAnimations];
//    }
//    if(!self.historyRefreshDisabled && historyState==SABER_HISTORY_LOADING){
//        [self setHistoryRefreshState:SABER_HISTORY_NORMAL];
//        [UIView beginAnimations:nil context:NULL];
//        [UIView setAnimationDuration:0.2];
//        if ([self.listView respondsToSelector:@selector(scrollView)]) {
//            [self.listView scrollView].contentInset =UIEdgeInsetsZero;
//        }
//        else if ([self.listView isKindOfClass:[UIScrollView class]]) {
//            ((UIScrollView*)self.listView).contentInset =UIEdgeInsetsZero;
//        }
//        [UIView commitAnimations];
//    }
//    if([self.model.refreshType isEqualToString:@"3"]&&historyState==SABER_HISTORY_LOADING){
//        [self setHistoryRefreshState:SABER_HISTORY_NORMAL];
//    }
//}
//
///*gotoTop的动画*/
//-(void)scrollToTop{
//    [self scrollToTopAnimated:YES];
//}
//-(void)scrollToTopAnimated:(BOOL)animated{
//
//    if (![self useWindowScroll]) {
//        if([self.listView respondsToSelector:@selector(scrollView)]){
//            [[self.listView scrollView] setContentOffset:CGPointMake(0, 0) animated:animated];
//        }
//    }
//    else {
//        NSString* javascript = [NSString stringWithFormat:@"window.scrollTo(0, 0);"];
//        if ([self.listView isKindOfClass:[UIWebView class]]) {
//            [(UIWebView *)self.listView stringByEvaluatingJavaScriptFromString:javascript];
//        }
//        else if ([self.listView isKindOfClass:[WKWebView class]]) {
//            [(WKWebView *)self.listView evaluateJavaScript:javascript completionHandler:^(id object, NSError * _Nullable error) {}];
//        }
//    }
//
//    return;
//}
//
//
//-(void)noMoreHistoryContent{
//    isMoreHistoryContent=NO;
//}
//
//-(void)hasMoreHistoryContent{
//    isMoreHistoryContent=YES;
//}
//
////ReactJS--单页面切换时隐藏问题
//- (void)hidenRefresh:(BOOL)hiden refreshType:(NSString *)rType
//{
//    self.refreshView.hidden = hiden;
//    self.bottomView.hidden = hiden;
//    refreshY = hiden?1200:[self.model.refreshY integerValue];
//}
//
//#pragma mark -
//
//- (BOOL)useWindowScroll
//{
//    BOOL isSwitchOn = NO;
//    NSDictionary *v2SwitchInfo = [[NSUserDefaults standardUserDefaults] objectForKey:@"localTotalV2SwitchInfo"];
//    if (v2SwitchInfo) {
//        isSwitchOn = [@"1" isEqualToString:[v2SwitchInfo objectForKey:@"useWindowScroll"]];
//    }
//
//    return isSwitchOn;
//}

@end
