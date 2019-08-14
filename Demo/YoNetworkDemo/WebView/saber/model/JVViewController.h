#import <UIKit/UIKit.h>
#import "JVActionModel.h"
#import "JVViewControllerModel.h"
@class  JVActionModel;
@interface JVViewController : UIViewController
@property  (nonatomic, strong) NSString *alias;

//返回指定tag 页面
@property (nonatomic,strong) NSString *pageTag; //当前页面标记
@property (nonatomic,strong) NSDictionary *pageParams;  //当前页面param
@property (nonatomic,strong) NSDictionary *backTagPageParams;

@property (nonatomic,strong) NSString *backBtnBackTag;  //当前页面返回时，回到pageTag为backBtnBackTag的页面
@property (nonatomic,strong) NSDictionary *backBtnBackParams;   //返回指定页面时，带参数给指定页面


//init function
-(id)initWithJSONString:(NSString*)jsonStr;
-(id)initWithDictionary:(NSDictionary*)dict;

-(void)initParam:(NSDictionary*)params;
-(void)initModel:(NSDictionary*)params;
-(void)initView;
-(void)doJVAction:(JVActionModel*)jvActionModel;

//pop to tag
-(UIViewController*)popViewControllerByTag:(NSString*)tag  topVCCallback:(NSString*)callback animated:(BOOL)animated;
//pop to count
-(UIViewController*)popViewControllerByCount:(NSInteger)popCount topVCCallback:(NSString*)callback animated:(BOOL)animated;

- (void)popViewControllerByBackBtnBackTag:(NSString *)tag backParams:(NSDictionary *)backParams animated:(BOOL)animated;

@end
