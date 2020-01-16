//
//  SCRemoteDeviceInfo.m
//  Scon
//
//  Created by gezhixin on 2018/7/30.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SCServerInfo.h"
#import <arpa/inet.h>

 NSString * KNotificationSConRemoteDeviceListChanged = @"KNotificationSConRemoteDeviceListChanged";

@implementation SCServerInfo

+ (SCServerInfo *)serverInfoFromNetService:(NSNetService *)netService {
    NSData *address = [netService.addresses firstObject];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *)[address bytes];
    
    SCServerInfo * info = [[SCServerInfo alloc] init];
    
    info.addresses = [netService.addresses copy];
    info.name = netService.name;
    info.hostName = netService.hostName;
    info.host = [[NSString alloc] initWithUTF8String:inet_ntoa(socketAddress->sin_addr)];
    info.port = netService.port;

    
    return info;
}

@end
