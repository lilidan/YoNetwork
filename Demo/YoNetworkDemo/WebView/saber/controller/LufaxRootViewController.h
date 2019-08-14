#import "SaberRootViewController.h"
#import "LufaxRootVCModel.h"
@class JVLocalModel;

@interface LufaxRootViewController : SaberRootViewController

@property (nonatomic, strong) LufaxRootVCModel *model;
@property (nonatomic, assign) BOOL h5SettingHeader;

- (void)setNavigationStyle:(NSInteger) stype;
- (void)showAlertView:(NSDictionary*)dictionary;
- (void)backButtonTaskParserImp:(NSDictionary*)param;
- (void)resetRefreshViewWithRefreshType:(NSString *)refreshType;
- (void)callLocalJsModel:(JVLocalModel*)__model val:(NSString*)val;

@property(nonatomic,weak)id popCallbackTarget;  // 返回上一页时的回调对象

@end
