//
//  SCRemoteDeviceInfo.h
//  Scon
//
//  Created by gezhixin on 2018/7/30.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCRemoteDeviceInfo : NSObject

@property (nonatomic, copy) NSString * deviceName;
@property (nonatomic, copy) NSString * deviceSystem;
@property (nonatomic, copy) NSString * deviceModel;
@property (nonatomic, copy) NSString * deviceVersion;

@property (nonatomic, copy) NSString * appName;
@property (nonatomic, copy) NSString * appVersion;

@end
