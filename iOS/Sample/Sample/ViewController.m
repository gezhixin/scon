//
//  ViewController.m
//  Sample
//
//  Created by gezhixin on 2018/8/22.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "ViewController.h"

#import <SCLServiceInfoView.h>
#import <DDLog.h>
#import <DDTTYLogger.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [SCLServiceInfoView show];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    static long i = 0;
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [DDLog log:NO level:DDLogLevelAll flag:DDLogFlagWarning context:0 file:__FILE__ function:__FUNCTION__ line:__LINE__ tag:nil format:@"time : %@", @(i++)];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
