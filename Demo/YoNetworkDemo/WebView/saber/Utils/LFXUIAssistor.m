//
//  LFXUIAssistor.m
//  iosframework
//
//  Created by 杨善嗣 on 2017/10/16.
//  Copyright © 2017年 ljs. All rights reserved.
//

#import "LFXUIAssistor.h"

@implementation LFXUIAssistor

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initCommon];
    }
    return self;
}

- (void)initCommon
{
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    self->_widthOfScreen  = [UIScreen mainScreen].bounds.size.width;
    self->_heightOfScreen = [UIScreen mainScreen].bounds.size.height;
    
    self->_offsetOfScreenTop    = 0.0f;
    self->_offsetOfScreenBottom = 0.0f;
    
    self->_heightOfStatusBar = [UIApplication sharedApplication].statusBarFrame.size.height;
    self->_heightOfNavigationBar = 44.0f;
    
    self->_heightOfTopBar        = 64.0f;
    self->_heightOfTopBarShadow  = 2.0f;
    
    /* 根据UED的要求，从V400开始，底部bottomView的高度统一为50pt，
     * 不再根据屏幕大小进行50->60的变化了
     * 2017-11-18 YangShanSi
     */
    self->_heightOfBottomBar       = 50.0f;
    self->_heightOfBottomBarButton = 50.0f;
    
    self->_widthOfSingleLine = 1.0f / [UIScreen mainScreen].scale;
    
    // adjust for OS > iOS7
    if (systemVersion >= 7.000000f) {
        self->_offsetOfScreenTop = 20.0f;
    }
    
    // adjust for iphone X
    CGFloat widthInterval  = fabs([UIScreen mainScreen].bounds.size.width - 375);
    CGFloat heightInterval = fabs([UIScreen mainScreen].bounds.size.height - 812);
    
    if (systemVersion >= 11.000000f &&
        widthInterval < CGFLOAT_MIN  && heightInterval < CGFLOAT_MIN)
    {
        self->_offsetOfScreenTop     = 44.0f;
        self->_offsetOfScreenBottom  = 34;
        
        self->_heightOfStatusBar = 44.0f;
        self->_heightOfTopBar    = 88.0f;
        self->_heightOfBottomBar = 50.0f + 34.0f;
        
    }
    
    self->_heightOfSafeView = self->_heightOfScreen - self->_heightOfTopBar - self->_offsetOfScreenBottom;
}


+ (LFXUIAssistor *)sharedAssistor
{
    static LFXUIAssistor *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [LFXUIAssistor new];
    });
    return instance;
}


@end






