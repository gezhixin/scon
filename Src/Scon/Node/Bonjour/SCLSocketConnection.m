//
//  SCLSocketConnection.m
//  Scon
//
//  Created by gezhixin on 2018/8/20.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SCLSocketConnection.h"

NSString * KNotificationSConRemoteDeviceListChanged = @"KNotificationSConRemoteDeviceListChanged";

@implementation SCLSocketConnection


#pragma mark - Override
- (NSString *)identifier {
    static int64_t index = 0;
    return [NSString stringWithFormat:@"SCLocalSocketConnection_%lld", index];
}

- (void)startConnect {
}

- (void)close {
    
}

- (void)reConnect {
    
}

- (void)sendMsg:(NSData *)msg {
    [self.socket writeData:msg withTimeout:-1 tag:self.tag];
}

- (void)onReciveMsg:(SconMsg *)msg {
    if ([msg isKindOfClass:[SconCommondMsg class]]) {
        SconCommondMsg * cmdMsg = (SconCommondMsg*)msg;
        BOOL isDeviceInfoMsg = [[cmdMsg.content objectForKey:@"bdev"] boolValue];
        if (isDeviceInfoMsg) {
            NSLog(@"%@", cmdMsg.content);
            NSDictionary * devInfoDic = [cmdMsg.content objectForKey:@"devInfo"];
            self.devInfo.appName = [devInfoDic objectForKey:@"appName"];
            self.devInfo.appVersion = [devInfoDic objectForKey:@"appVersion"];
            self.devInfo.deviceModel = [devInfoDic objectForKey:@"model"];
            self.devInfo.deviceSystem = [devInfoDic objectForKey:@"systemName"];
            self.devInfo.deviceVersion = [devInfoDic objectForKey:@"systemVersion"];
            self.devInfo.deviceName = [devInfoDic objectForKey:@"name"];
            [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationSConRemoteDeviceListChanged object:nil];
        } else {
            [super onReciveMsg:msg];
        }
    } else {
        [super onReciveMsg:msg];
    }
}

- (SCRemoteDeviceInfo *)devInfo {
    if (!_devInfo) {
        _devInfo = [[SCRemoteDeviceInfo alloc] init];
    }
    return _devInfo;
}

@end
