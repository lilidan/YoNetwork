#import <UIKit/UIKit.h>
#import "ArcherButtonModel.h"
@protocol ArcherButtonDelegate <NSObject>
@required
-(void)archerBtnClicked:(id)sender;
@end

@interface ArcherButton : UIButton
@property(nonatomic, strong)     ArcherButtonModel* model;
@property(nonatomic,weak) id<ArcherButtonDelegate>  buttonDelegate;
//init function
-(id)initWithJSONString:(NSString*)jsonStr;
-(id)initWithDictionary:(NSDictionary*)dict;
-(id)initWithModel:(ArcherButtonModel*)model;
//can be implement
-(void)initView;
-(void)enabled:(BOOL)enable;
-(BOOL)archerCommonAction:(ArcherButton*)button;

-(void)archerAlpha:(NSString*)alpha;
-(void)subArcherButtonDidClicked;

-(void)addGradientColors;
-(void)addArcherTarget:(id)target;
@end
