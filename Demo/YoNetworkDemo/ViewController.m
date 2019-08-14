//
//  ViewController.m
//  YoNetworkDemo
//
//  Created by sgcy on 2019/8/5.
//  Copyright © 2019 sgcy. All rights reserved.
//

#import "ViewController.h"
#import "YoNetwork.h"
#import "BannerRequest.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    BannerRequest *request = [[BannerRequest alloc] init];
    request.funcCodeList = @"AD_BANNER_CONFIG,AD_BOTTOM_CONFIG";
    request.cfgChannels = @"PATRUST";
    [request send:^(EntrustBannerResponseModel *response, NSError *error) {
        if (error) {
            NSLog(@"");
        }
    }];
}


@end
