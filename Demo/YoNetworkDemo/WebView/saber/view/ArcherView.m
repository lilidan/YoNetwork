#import "ArcherView.h"
#import "JVUtility.h"
@implementation ArcherView


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

-(id)initWithModel:(ArcherViewModel*)model{
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
    return [ArcherViewModel class];
}


-(void)initView{
    [self setClipsToBounds:YES];
    //设置border参数
    if(self.model.borderRadius)self.layer.cornerRadius=self.model.borderRadius.floatValue;
    if(self.model.borderWidth)self.layer.borderWidth=self.model.borderWidth.floatValue;
    if(self.model.borderColor)self.layer.borderColor=COLOR_HEX(self.model.borderColor).CGColor;
    //common设置，ArcherView、ArcherButton、ArcherLabel
    ARCHER_INIT_BASIC_MODEL
}

@end
