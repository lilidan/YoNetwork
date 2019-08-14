#import "JVModel.h"

@interface JVResponseModel : JVModel

@property (nonatomic, assign) NSInteger statusCode;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSData *responseData;
@property (nonatomic, copy) NSString *responseString;

@end


@interface JVRequestModel : JVModel <NSCopying>
@property(nonatomic,strong) NSString* task;                       //默认为 init;其它有http_request
@property(nonatomic,strong) NSString* method;                     //默认GET    such as "GET"  "POST"
@property(nonatomic,strong) NSString* url ;                       //必设    请求的url
@property(nonatomic,strong) NSDictionary* postData;               //可选    post数据

@property(nonatomic,strong) NSString* callback;                   //可选    默认render 成功回调
@property(nonatomic,strong) NSString* errorCallback;              //可选    错误回调
@property(nonatomic,strong) NSString* finishCallback;             //可选    无论错对的回调

@property(nonatomic,strong) NSString* isShowLoading;              //默认 1  0 不显示       1 显示顶部横条        2 屏幕中央转菊花
@property(nonatomic,strong) NSString* isLoadingMask;              //默认 0  0 不遮罩       1 局部遮罩          2 全部遮罩(返回不可点)
@property(nonatomic,strong) NSString* loadingContent;             //默认 @""         loading时候显示的文案

@property(nonatomic,strong) NSDictionary* userInfo;                  //userInfo

@property(nonatomic,strong) NSDictionary * headers;               // 可选，添加http header

@property(nonatomic,strong) NSString* isCache;                    //默认 0  0 不缓存数据 1 缓存

@property(nonatomic,strong) NSString * withTokenCode;             // 在请求中添加手机令牌

@property(nonatomic,strong) NSString* mappMsgLevel;   // mapp显示错误等级。0：显示msg，1：不显示msg。

@property(nonatomic,strong) NSString* version; // bridgeTask版本
@property(nonatomic,strong) NSString* sessionId; // v2版本参数
@property(nonatomic,strong) NSString* origUrl; // 原始url


@property (nonatomic, strong, readonly) NSDictionary *metrics;

@end
