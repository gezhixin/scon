//
//  SconConnection.m
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SconConnection.h"
#import "SconMsgHandler.h"

@interface SconConnection ()

@end

@implementation SconConnection

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak SconConnection * weakSelf = self;
        _msgHandler = [[SconMsgHandler alloc] initWithSendMsgBlk:^(NSData * msgData) {
            __strong SconConnection * strongSelf = weakSelf;
            [strongSelf sendMsg:msgData];
        } reciveMsg:^(SconMsg *msg) {
            __strong SconConnection * strongSelf = weakSelf;
            [strongSelf onReciveMsg:msg];
        }];
    }
    return self;
}

- (void)startConnect {
    
}

- (void)close {
    
}

- (void)reConnect {
    
}

- (void)sendMsg:(NSData *)msg {
    
}

- (void)onReciveMsg:(SconMsg *)msg {
    if (self.delegate && [self.delegate respondsToSelector:@selector(onMessageRecived:)]) {
        [self.delegate onMessageRecived:msg];
    }
}

- (void)onRecivceData:(NSData *)data {
    [_msgHandler onReciveMsg:data];
}

@end
