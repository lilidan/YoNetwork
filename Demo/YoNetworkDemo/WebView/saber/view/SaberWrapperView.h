#import "ArcherView.h"
#import "SaberWrapperViewModel.h"
@protocol SaberWrapperViewDelegate <NSObject>
@required
-(void)saberWrapperViewPosition:(NSInteger)align weakSelf:(id)view;
@end
@interface SaberWrapperView : ArcherView
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
@property(nonatomic, strong) SaberWrapperViewModel* model;
#pragma clang diagnostic pop

@property(nonatomic,weak) id<SaberWrapperViewDelegate>  saberWrapperViewDelegate;
@end
