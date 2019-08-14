#import "ArcherView.h"
#import "SaberRefreshModel.h"
/*上拉下拉刷新控件*/
typedef enum{
    SABER_PULLING = 0,
    SABER_NORMAL,
    SABER_LOADING,
} SABER_REFRESH_STATUS;

typedef enum{
    SABER_HISTORY_PULLING = 0,
    SABER_HISTORY_NORMAL,
    SABER_HISTORY_LOADING
} SABER_HISTORY_STATUS;

@protocol SaberRefreshViewDataSource <NSObject>
@required
-(void)refreshInfoHistoryContent;
-(void)refreshInfoContent;

@optional
-(void)refreshListViewDidScroll:(CGPoint)point;
@end


@interface SaberRefreshView : ArcherView<UIScrollViewDelegate>{
    SABER_REFRESH_STATUS      refreshState;
    SABER_HISTORY_STATUS      historyState;
    BOOL                isMoreHistoryContent;
    NSInteger           refreshY;
    
    NSInteger bottomY;
#pragma mark -  发送隐藏bar的通知
    NSInteger           positionForBarNotify;
    NSDate*             lastNotifyDate;

}


@property (nonatomic, weak  ) id<SaberRefreshViewDataSource> myDatasource;
@property (nonatomic, weak  ) id listView;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-property-synthesis"
@property (nonatomic, strong) SaberRefreshModel       *model;
#pragma clang diagnostic pop

//@property (nonatomic, strong) UIView                  *titleView;/*头部*/
//@property (nonatomic, strong) UIImageView             *refreshDownArrow;/*头部的箭头，默认会旋转180度*/
//@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, strong) UIView                  *bottomView;/*底部*/
@property (nonatomic, strong) UIImageView             *refreshUpArrow;/*底部的箭头，默认会旋转180度*/
@property (nonatomic, strong) UIActivityIndicatorView *historyActivityView;
@property (nonatomic, assign) BOOL                    historyRefreshDisabled;/*是否禁用上拉刷新*/

@property (nonatomic, assign) NSInteger               modeForBarNotify;//1是正在隐藏状态 0是正在显示状态

//ui init
-(void)initView;
-(void)initTitleView;
-(void)initBottomView;

-(void)setRefreshState:(SABER_REFRESH_STATUS)aStatus;
-(void)setHistoryRefreshState:(SABER_HISTORY_STATUS)status;
-(void)delayResetState;
-(void)resetRefreshState;
-(void)setListContentView:(id)contentView;
-(void)scrollToTop;
-(void)scrollToTopAnimated:(BOOL)animated;
-(void)noMoreHistoryContent;
-(void)hasMoreHistoryContent;
- (void)hidenRefresh:(BOOL)hiden refreshType:(NSString *)rType;


#pragma mark -  发送隐藏bar的通知
@property BOOL   isNeedBarNotification;//????
@property NSInteger triggerNotifyOffsetY;//????
@property NSInteger minNotifyOffsetY;//???

@end
