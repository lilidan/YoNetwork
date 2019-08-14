#import "JVModel.h"

@interface JVLocalModel : JVModel
@property (nonatomic, strong) NSString* localDataKey;               //数据持久化在本地的key
@property (nonatomic, strong) NSString* localDataValue;             //数据持久话在本地的值key，值为string
@property (nonatomic, strong) NSString* callback;                   //可选    成功回调
@end
