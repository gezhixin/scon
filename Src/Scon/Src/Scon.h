//
//  Scon.h
//  Scon
//
//  Created by gezhixin on 2018/8/3.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Scon.
FOUNDATION_EXPORT double SconVersionNumber;

//! Project version string for Scon.
FOUNDATION_EXPORT const unsigned char SconVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <Scon/PublicHeader.h>
#import "SconConnection.h"
#import "SconPluginProtocol.h"
#import "SconMsg.h"

@interface Scon : NSObject<SconConnectionDelegate>

/*
 *  消息拦截
 */
@property (nonatomic, copy) BOOL (^msgReciveInterceptor)(SconMsg * msg);

/*
 *  命令消息分发
 */
@property (nonatomic, copy) void(^commendMsgRecived)(SconCommondMsg * msg);

@property (nonatomic, strong) SconConnection * connection;

+ (instancetype)sharedInstance;

- (void)addPlugin:(id<SconPluginProtocol>)plugin;

- (void)removePlugin:(id<SconPluginProtocol>)plugin;

- (void)removePluginByIdentifier:(NSString *)identifier;


@end
