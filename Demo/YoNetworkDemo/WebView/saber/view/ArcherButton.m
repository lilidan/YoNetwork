#import "ArcherButton.h"
#import "JVUtility.h"
@interface ArcherButton(){
    long lastClickTime;
}
@end
@implementation ArcherButton



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

-(void)initModel:(NSDictionary*)params{
    self.model=[[self modelClass] new];
    [self.model modelFromDictionary:params];
}

-(id)initWithModel:(ArcherButtonModel*)model{
    self = [super init];
    if(self){
        self.model=model;
        [self initView];
    }
    return self;
}
-(void)initParam:(NSDictionary*)params{
    [self initModel:params];
    [self initView];
}


-(Class)modelClass{
    return [ArcherButtonModel class];
}

-(void)initView{
    [self setTitle:self.model.title forState:UIControlStateNormal];
    
    [self.titleLabel setFont:JVFONT([self.model.fontSize integerValue])];
    if(self.model.fontColor){
        [self setTitleColor:COLOR_HEX(self.model.fontColor) forState:UIControlStateNormal];
    }
    if(self.model.highlightFontColor){
        [self setTitleColor:COLOR_HEX(self.model.highlightFontColor) forState:UIControlStateHighlighted];
    }
    if(self.model.selectedFontColor){
        [self setTitleColor:COLOR_HEX(self.model.selectedFontColor) forState:UIControlStateSelected];
    }
    
    if(self.model.disableFontColor){
        [self setTitleColor:COLOR_HEX(self.model.disableFontColor) forState:UIControlStateDisabled];
    }
    
    if(self.model.normalBg){
        [self setBackgroundImage:IMAGE_WITH_COLOR(self.model.normalBg) forState:UIControlStateNormal];
    }
    
    if(self.model.highlightBg){
        [self setBackgroundImage:IMAGE_WITH_COLOR(self.model.highlightBg) forState:UIControlStateHighlighted];
    }
    if(self.model.selectedBg){
        [self setBackgroundImage:IMAGE_WITH_COLOR(self.model.selectedBg) forState:UIControlStateSelected];
    }
    if(self.model.disableBg){
        [self setBackgroundImage:IMAGE_WITH_COLOR(self.model.disableBg) forState:UIControlStateDisabled];
    }
    if(self.model.disableBg){
        [self setBackgroundImage:IMAGE_WITH_COLOR(self.model.disableBg) forState:UIControlStateDisabled];
    }
    [self enabled:([self.model.enable isEqualToString:@"1"]?YES:NO)];
    [self setSelected:([self.model.selected isEqualToString:@"1"]?YES:NO)];
    
    //设置border参数
    if(self.model.borderRadius)self.layer.cornerRadius=self.model.borderRadius.floatValue;
    if(self.model.borderWidth)self.layer.borderWidth=self.model.borderWidth.floatValue;
    [self archerAlpha:self.model.alpha];
    [self setClipsToBounds:YES];
    if([self.model.fontStyle isEqualToString:@"1"]){
        [self.titleLabel setFont:JV_ICON_FONT(@"iconfont-framework", [self.model.fontSize floatValue])];
    }else if([self.model.fontStyle isEqualToString:@"2"]){
        [self.titleLabel setFont:JV_ICON_FONT(@"iconfont", [self.model.fontSize floatValue])];
    } else if ([self.model.fontStyle isEqualToString:@"3"]) {
        UIFont *font = JV_ICON_FONT(@"iconfontv2", [self.model.fontSize floatValue]);
        [self.titleLabel setFont:font];
    }
    
    ARCHER_INIT_BASIC_MODEL
}

/**
 * 防重复
 */

-(BOOL) isFastDoubleClick:(long)lockDuration{
    NSDate* date = [NSDate new];
    long time = date.timeIntervalSince1970;//单位是秒和android不同
    long timeD = time - lastClickTime;
    if ( 0 <= timeD && timeD <= lockDuration) {
        return true;
    }
    lastClickTime = time;
    return false;
}

-(void)addArcherTarget:(id)target{
    if([self.model.bindAction isEqualToString:@"1"]){
        self.buttonDelegate = target;
        [self addTarget:self action:@selector(archerCommonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
}

-(void)enabled:(BOOL)enable{
    self.enabled=enable;
    if(self.model.borderColor){
        if(enable){
            self.layer.borderColor=COLOR_HEX(self.model.borderColor).CGColor;
        }else{
            self.layer.borderColor=COLOR_HEX(self.model.disableBorderColor).CGColor;
        }
    }
}

//为了跟踪用，所以要做个中间回调
-(BOOL)archerCommonAction:(ArcherButton*)button{
    if(self.model.isTrace){
        //TODO:traceSystem
    }
    if([self.buttonDelegate respondsToSelector:@selector(archerBtnClicked:)]){
        if(self.model.clickLimitSeconds.integerValue==0||![self isFastDoubleClick:self.model.clickLimitSeconds.integerValue]){
            [self subArcherButtonDidClicked];
            [self.buttonDelegate archerBtnClicked:button];
            return YES;
        }
    }
    return NO;
}

-(void)archerAlpha:(NSString*)alpha{
    self.model.alpha=alpha;
    self.alpha=[self.model.alpha floatValue];
}

-(void)archerEnable:(NSString*)enableStr{
    [self enabled:[enableStr isEqualToString:@"1"]];
}

-(void)subArcherButtonDidClicked{}

-(void)addGradientColors {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.layer.bounds;
    gradientLayer.colors = @[(id)COLOR_HEX(@"FE864A"),
                             (id)COLOR_HEX(@"6F7FFF")];
    gradientLayer.cornerRadius = self.layer.cornerRadius;
    [self.layer addSublayer:gradientLayer];
}

@end
