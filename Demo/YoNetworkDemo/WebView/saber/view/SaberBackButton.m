#import "SaberBackButton.h"

@implementation SaberBackButton

-(void)initView{
    [super initView];
    [self setTitle:@"" forState:UIControlStateNormal];
    if ([self.model.style isEqualToString:@"1"]) {
        [self setTitle:@"\U0000e649" forState:UIControlStateNormal];
    }
    else {
        [self setTitle:@"\U0000e6af" forState:UIControlStateNormal];
    }
    [self setTitleColor:[UIColor whiteColor]
               forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont fontWithName:@"iconfont" size:20];

    self.backgroundColor=[UIColor clearColor];
    [self setBackgroundImage:nil forState:UIControlStateNormal];
    [self setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self setBackgroundImage:nil forState:UIControlStateSelected];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.000000f) {
        if ([self.model.style isEqualToString:@"1"])
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
        else
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 10);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    } else {
        //iOS6 need remove
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}
@end
