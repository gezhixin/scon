//
//  SCLocalSocketService.h
//  Scon
//
//  Created by gezhixin on 2018/8/20.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCRemoteDeviceInfo.h"

@interface SCLocalSocketService : NSObject

+ (instancetype)sharedInstance;

- (void)setCurrentRemoteDevice:(NSString *)deviceName;

- (NSArray<SCRemoteDeviceInfo*>*)getRemoteDevInfoList;

@end
