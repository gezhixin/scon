//
//  SconMsgHandler.m
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SconMsgHandler.h"
#import "SconMsg.h"
#import <pthread/pthread.h>

@interface SconMsgHandler () {
}

@property (nonatomic, copy) void(^blkSendMsg)(NSData * msgData);

@property (nonatomic, copy) void(^blkMsgReciveHandler)(SconMsg *msg);

@property (nonatomic, strong) NSMutableData * recivedData;

@property (nonatomic, strong) dispatch_queue_t dataQueue;

@end

@implementation SconMsgHandler

- (instancetype)initWithSendMsgBlk:(void (^)(NSData *))sendMsgBlk
                         reciveMsg:(void(^)(SconMsg * msg))msgReciveHandler {
    self = [super init];
    if (self) {
        
        self.dataQueue = dispatch_queue_create("scon.recive.dataQueue", DISPATCH_QUEUE_SERIAL);
        
        self.recivedData = [NSMutableData data];
        
        self.blkSendMsg = sendMsgBlk;
        self.blkMsgReciveHandler = msgReciveHandler;
    }
    return self;
}

- (void)dealloc {
    
}

- (void)sendMsg:(SconMsg *)msg {
    NSData * data = [msg msgtoData];
    if (self.blkSendMsg && data) {
        self.blkSendMsg(data);
    }
}

- (void)sendPluginMsg:(NSString *)identifier msg:(NSData *)msg {
    SconPluginMsg * pluginMsg = [[SconPluginMsg alloc] init];
    pluginMsg.identifier = identifier;
    pluginMsg.content = msg;
    NSData * data = [pluginMsg msgtoData];
    if (self.blkSendMsg && data) {
        self.blkSendMsg(data);
    }
}

- (void)sendCommend:(NSDictionary *)cmd {
    SconCommondMsg * msg = [[SconCommondMsg alloc] init];
    msg.content = cmd;
    NSData * data = [msg msgtoData];
    if (self.blkSendMsg && data) {
        self.blkSendMsg(data);
    }
}

- (void)onReciveMsg:(NSData *)msgData {
    dispatch_async(self.dataQueue, ^{
        [self.recivedData appendData:msgData];
        [self decodeMsge];
    });
}

- (void)decodeMsge {
    
    dispatch_async(self.dataQueue, ^{
        
        BOOL shouldBreak = NO;
        
        while (!shouldBreak) {
            int64_t offset = 0;
            offset = 0;
            SconMsg * msg = decodeMsg(self.recivedData.bytes, self.recivedData.length, &offset);
            
            if (offset > 0) {
                int64_t leftSize = self.recivedData.length - offset;
                if (leftSize > 0) {
                    NSMutableData * nData = [NSMutableData dataWithBytes:(void*)((char*)self.recivedData.bytes + offset) length:leftSize];
                    self.recivedData = nData;
                } else {
                    self.recivedData.length = 0;
                }
            }
            
            if (self.blkMsgReciveHandler && msg) {
                self.blkMsgReciveHandler(msg);
            }
            
            shouldBreak = msg == nil || offset == 0 || self.recivedData.length == 0;
            
            if (shouldBreak) {
                break;
            }
        }
    });
}

@end
