//
//  SconConnection.h
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SconMsgHandler.h"
#import "SconMsg.h"

@class SconConnection;

@protocol SconConnectionDelegate<NSObject>

- (void)onConnected:(SconConnection *)conection;

- (void)onDisconnected:(SconConnection *)conection;

- (void)onMessageRecived:(SconMsg*)msg;

@end


@interface SconConnection : NSObject

@property (nonatomic, copy, readonly) NSString * identifier;

@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic, assign) unsigned int priority;

@property (nonatomic, strong, readonly) SconMsgHandler * msgHandler;



@property (nonatomic, weak) id<SconConnectionDelegate> delegate;



- (void)startConnect;

- (void)close;

- (void)reConnect;

- (void)onRecivceData:(NSData*)data;

- (void)sendMsg:(NSData *)msg;

- (void)onReciveMsg:(SconMsg *)msg;

@end
