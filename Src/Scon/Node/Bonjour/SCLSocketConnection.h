//
//  SCLSocketConnection.h
//  Scon
//
//  Created by gezhixin on 2018/8/20.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SconConnection.h"
#import "GCDAsyncSocket.h"
#import "SCRemoteDeviceInfo.h"

extern NSString * KNotificationSConRemoteDeviceListChanged;

@interface SCLSocketConnection : SconConnection

@property (nonatomic, assign) long tag;
@property (nonatomic, strong) GCDAsyncSocket * socket;
@property (nonatomic, strong) SCRemoteDeviceInfo * devInfo;

@end
