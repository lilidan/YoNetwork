#import <UIKit/UIKit.h>
#import "SaberRootVCModel.h"
#import "SaberRefreshView.h"
#import "JVViewController.h"
#import "JVWebView.h"
#import "SaberBackButton.h"

typedef enum {
    LUFAX_TYPE=0,/*Lufax返回按钮，没有文字*/
} JV_BACK_BUTTON_TYPE;


@interface SaberRootViewController : JVViewController<SaberRefreshViewDataSource,JVWebViewDelegate,ArcherButtonDelegate>

@property (nonatomic, strong) SaberRootVCModel *model;//VC的model
@property (nonatomic, strong) JVWebView        *jvWebView;//webview
@property (nonatomic, strong) SaberRefreshView* refreshView;
@property (nonatomic, assign) BOOL isThirdPage;//解决第三方银联H5页面无法回退问题
//UI
-(void)initNavigationBar;
-(void)initRefreshView;
-(void)initWebView;
-(void)resizeJVWebview;
-(void)resizeJVWebviewTop:(NSInteger)marginTop bottom:(NSInteger)bottom;
-(void)parseTitleView:(NSDictionary*)dict;
- (void)jvWebView:(id)webview didReceiveJSNotificationWithDictionary:(NSDictionary*) dictionary;
-(NSString*)getJSParameter;
-(void)myDealloc;
-(void)refreshInfoContent:(NSDictionary *) userInfo;
-(void)btnClickCallJS:(ArcherButton*)button;
-(void)resetRefreshView:(NSString*)noMoreContent;
-(void)__callJSIfSuccess:(NSString*)func;

@end
