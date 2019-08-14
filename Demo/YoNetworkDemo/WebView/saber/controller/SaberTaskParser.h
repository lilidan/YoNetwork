#import <UIKit/UIKit.h>
#import "SaberRootViewController.h"
@interface SaberTaskParser : NSObject
@property (nonatomic,weak) SaberRootViewController* taskVC;
-(BOOL)parse:(NSDictionary*)taskDic;
@end
