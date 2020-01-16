//
//  SconPluginProtocol.h
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SconMsgHandler.h"
#import "SconConnection.h"

@protocol SconPluginProtocol<NSObject>

@property (nonatomic, strong, readonly) NSString * identifier;

- (void)onConnected:(SconMsgHandler *)msgHandler;

- (void)onDisconnected;

- (void)onReciveMsg:(NSData *)data;

@end
