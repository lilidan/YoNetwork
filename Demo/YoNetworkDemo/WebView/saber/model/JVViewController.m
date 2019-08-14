#import "JVViewController.h"
#import "JVActionModel.h"
@interface JVViewController ()

@end

#define JSON_DIC_FROM_STRING(__STR__)   [self dictionaryFromJSONString:__STR__]


@implementation JVViewController

-(id)initWithJSONString:(NSString*)jsonStr{
    self = [super init];
    if(self){[self initParam:JSON_DIC_FROM_STRING(jsonStr)];}
    return self;
}

-(id)initWithDictionary:(NSDictionary*)dict{
    self = [super init];
    if(self){[self initParam:dict];}
    return self;
}
-(void)initParam:(NSDictionary*)params{
    [self initModel:params];
    [self initView];
}

#pragma mark ---- abstract method
-(void)initModel:(NSDictionary*)params{}
-(void)initView{}

- (void)viewDidLoad {
    [super viewDidLoad];
    /*没有这句，在7.000000f.0.3上push进来的view's frame会有问题*/
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

//jsontStr to Dictionary
- (NSDictionary*)dictionaryFromJSONString:(NSString*)jsonStr{
    NSError * error = nil;
    NSData * jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    if (!jsonData) {
        return nil;
    }
    NSMutableDictionary * jsonDic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (![jsonDic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    if(error){
        return nil;
    }else{
        return jsonDic;
    }
}


/*
 *根据popCount退出返回栈
 *@param    popCount  退出返回栈的数量
 *@param    topVCCallback  操作完，栈顶函数回调
 *@param    animated  出栈是否动画
 *@return   返回一个当前在栈顶得viewController
 */
-(UIViewController*)popViewControllerByCount:(NSInteger)popCount topVCCallback:(NSString*)callback animated:(BOOL)animated{
    if(self.presentingViewController){
        BOOL bDismiss = YES;
        if (self.parentViewController && self.navigationController && self.navigationController.childViewControllers.count>1) {
            bDismiss = NO;
        }
        if (bDismiss) {
            [self dismissViewControllerAnimated:animated completion:nil];
            [self callSelector:callback object:self.presentingViewController];
            return self.presentingViewController;
        }
    }
    
    NSArray* childVCs = self.navigationController.childViewControllers;
    if (childVCs == nil || childVCs.count <= 1) {
        return nil;
    }
    UIViewController* retController;
    
    if (childVCs.count > popCount) {
        if(popCount==1){
            retController=[childVCs objectAtIndex:childVCs.count-popCount-1];
            [self.navigationController popViewControllerAnimated:animated];
        }else{
            UIViewController* ctrl = [childVCs objectAtIndex:childVCs.count-popCount-1];
            [self.navigationController popToViewController:ctrl animated:animated];
            retController=ctrl;
        }
    }else{
        [self.navigationController popToRootViewControllerAnimated:animated];
        retController=[childVCs objectAtIndex:0];
    }
    [self callSelector:callback object:retController];
    return retController;
}

-(UIViewController*)popViewControllerByTag:(NSString*)tag  topVCCallback:(NSString*)callback animated:(BOOL)animated{
    NSArray* childVCs = self.navigationController.childViewControllers;
    if (childVCs == nil || childVCs.count <= 1) {
        return nil;
    }
    
    UIViewController* retController = nil;
    for (NSInteger i = childVCs.count-1; i >= 0; i--) {
        UIViewController * curVC = childVCs[i];
        if([curVC isKindOfClass:[JVViewController class]]){
            NSString * __alias = [(JVViewController*)curVC alias];
            if(__alias&&__alias.length>0&& [__alias isEqualToString:tag]){
                retController = curVC;
                break;
            }
        }else{
            continue;
        }
    }
    
    if(!retController){
        [self.navigationController popToRootViewControllerAnimated:animated];
        retController=[childVCs objectAtIndex:0];
    }else{
        [self.navigationController popToViewController:retController animated:animated];
    }
    [self callSelector:callback object:retController];
    
    return retController;
}

- (void)popViewControllerByBackBtnBackTag:(NSString *)tag backParams:(NSDictionary *)backParams animated:(BOOL)animated{}

-(void)doJVAction:(JVActionModel*)actionModel{
    NSInteger jvActionId = actionModel.actionId.integerValue;
    UIViewController* popedTopVC;
    
    if (self.backBtnBackTag && [self.backBtnBackTag isKindOfClass:[NSString class]] && self.backBtnBackTag.length) {
        [self popViewControllerByBackBtnBackTag:self.backBtnBackTag backParams:self.backBtnBackParams animated:YES];
        return;
    }
    
    switch (jvActionId) {
        case JV_ACTION_POP_VC:{
            popedTopVC=[self popViewControllerByCount:actionModel.intPopCount topVCCallback:actionModel.callback animated:actionModel.bolAnimated];
        }
            break;
        case JV_ACTION_POP_VC_BY_TAG:{
            popedTopVC=[self popViewControllerByTag:actionModel.popTag topVCCallback:actionModel.callback animated:actionModel.bolAnimated];
        }
            break;
        case JV_ACTION_POP_TO_ROOT:
        case JV_ACTION_POP_CLOSE_ACTIVITY:{
            if(self.navigationController){
                [self.navigationController popToRootViewControllerAnimated:actionModel.bolAnimated];
                popedTopVC = self.navigationController.topViewController;
            }
        }
            break;
        default:
            break;
    }
    NSInteger afterPopAction = actionModel.afterPopAction.integerValue;
    if(popedTopVC){
        switch (afterPopAction) {
            case JV_AFTER_ACTION_NOTHING:
                break;
            case JV_AFTER_ACTION_REFRESH:{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                if([popedTopVC respondsToSelector:@selector(refreshInfoContent)]){
                    [popedTopVC performSelector:@selector(refreshInfoContent) withObject:nil];
                }
#pragma clang diagnostic pop
            }
                break;
            default:
                break;
        }
    }
}


-(void)callSelector:(NSString*)callback object:(NSObject*)object{
    if(callback){
        if([object respondsToSelector:NSSelectorFromString(callback)]){
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [object performSelector:NSSelectorFromString(callback) withObject:nil];
#pragma clang diagnostic pop
        }
    }
}
@end
