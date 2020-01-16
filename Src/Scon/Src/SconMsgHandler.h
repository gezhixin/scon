//
//  SconMsgHandler.h
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SconMsg.h"

@interface SconMsgHandler : NSObject

- (instancetype)initWithSendMsgBlk:(void (^)(NSData *))sendMsgBlk
                         reciveMsg:(void(^)(SconMsg * msg))msgReciveHandler;

- (void)onReciveMsg:(NSData *)msgData;

- (void)sendMsg:(SconMsg *)msg;

- (void)sendPluginMsg:(NSString *)identifier msg:(NSData *)msg;

- (void)sendCommend:(NSDictionary *)cmd;

@end
