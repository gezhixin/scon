//
//  SCRemoteDeviceInfo.h
//  Scon
//
//  Created by gezhixin on 2018/7/30.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"

extern NSString * KNotificationSConRemoteDeviceListChanged;

@interface SCServerInfo : NSObject

@property (nonatomic, strong) NSArray<NSData*> * addresses;

@property (nonatomic, copy) NSString * appName;
@property (nonatomic, copy) NSString * appVersion;

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * hostName;
@property (nonatomic, copy) NSString * host;
@property (nonatomic, assign) NSInteger port;
@property (nonatomic, weak) GCDAsyncSocket * socket;

+ (SCServerInfo *)serverInfoFromNetService:(NSNetService *)netService;

@end
