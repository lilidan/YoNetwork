#import <UIKit/UIKit.h>
#import "ArcherViewModel.h"

@interface ArcherView : UIView
@property(nonatomic, strong)     ArcherViewModel* model;
-(void)initView;
-(id)initWithJSONString:(NSString*)jsonStr;
-(id)initWithDictionary:(NSDictionary*)dict;
-(id)initWithModel:(ArcherViewModel*)model;
@end
