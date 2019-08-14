//
//  LFXUIAssistor.h
//  iosframework
//
//  Created by 杨善嗣 on 2017/10/16.
//  Copyright © 2017年 ljs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LFXUIAssistor : NSObject

@property (nonatomic, assign, readonly) CGFloat widthOfScreen;
@property (nonatomic, assign, readonly) CGFloat heightOfScreen;

@property (nonatomic, assign, readonly) CGFloat heightOfSafeView;   //页面可展示safe area view高度

@property (nonatomic, assign, readonly) CGFloat offsetOfScreenTop;
@property (nonatomic, assign, readonly) CGFloat offsetOfScreenBottom;

@property (nonatomic, assign, readonly) CGFloat heightOfStatusBar;
@property (nonatomic, assign, readonly) CGFloat heightOfNavigationBar;

@property (nonatomic, assign, readonly) CGFloat heightOfTopBar;
@property (nonatomic, assign, readonly) CGFloat heightOfTopBarShadow;

@property (nonatomic, assign, readonly) CGFloat heightOfBottomBar;
@property (nonatomic, assign, readonly) CGFloat heightOfBottomBarButton;

@property (nonatomic, assign, readonly) CGFloat widthOfSingleLine;


+ (LFXUIAssistor *)sharedAssistor;

@end



