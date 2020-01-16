//
//  SCon.m
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "Scon.h"
#import "SconMsgHandler.h"
#import "SconConnection.h"
#import <pthread.h>

@interface Scon () {
    pthread_mutex_t _lock;
}

@property (nonatomic, strong) NSMutableDictionary * pluginsMap;

@end

@implementation Scon

+ (instancetype)sharedInstance {
    
    static Scon * instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[Scon alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _comInit];
    }
    return self;
}

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
}

- (void)_comInit {
    
    pthread_mutex_init(&_lock, NULL);
    
    self.pluginsMap = [NSMutableDictionary dictionaryWithCapacity:3];
}

#pragma mark - Plugin
- (void)addPlugin:(id<SconPluginProtocol>)plugin {
    if (plugin.identifier.length == 0) {
        return;
    }
    
    pthread_mutex_lock(&_lock);
    [self.pluginsMap setObject:plugin forKey:plugin.identifier];
    pthread_mutex_unlock(&_lock);
}

- (void)removePlugin:(id<SconPluginProtocol>)plugin {
    [self removePluginByIdentifier:plugin.identifier];
}

- (void)removePluginByIdentifier:(NSString *)identifier{
    if (identifier.length == 0) {
        return;
    }
    
    id<SconPluginProtocol> oPlugin = [self.pluginsMap objectForKey:identifier];
    if (oPlugin) {
        pthread_mutex_lock(&_lock);
        [self.pluginsMap removeObjectForKey:oPlugin];
        pthread_mutex_unlock(&_lock);
    }
}

#pragma mark - Connection
- (void)setConnection:(SconConnection *)connection {
    if (_connection) {
        for (id<SconPluginProtocol> plugin in [self.pluginsMap allValues]) {
            [plugin onDisconnected];
        }
    }
    
    _connection = connection;
    _connection.delegate = self;
}

#pragma mark - SconConnectionDelegate
- (void)onConnected:(SconConnection *)conection {
    for (id<SconPluginProtocol> plugin in [self.pluginsMap allValues]) {
        [plugin onConnected:conection.msgHandler];
    }
}

- (void)onDisconnected:(SconConnection *)conection {
    for (id<SconPluginProtocol> plugin in [self.pluginsMap allValues]) {
        [plugin onDisconnected];
    }
}

- (void)onMessageRecived:(SconMsg *)msg {
    [self dispathMsg:msg];
}

#pragma mark - Msg
- (void)dispathMsg:(SconMsg *)msg {
    if (!msg) {
        return;
    }
    
    if (self.msgReciveInterceptor) {
        BOOL ok = self.msgReciveInterceptor(msg);
        if(!ok) return;
    }
    
    switch (msg.type) {
        case SconMsgTypeCmd:
        {
            [self onReciveCommondMsg:(SconCommondMsg *)msg];
            break;
        }
        case SconMsgTypePlugin:
        {
            [self onRecivePluginMsg:(SconPluginMsg *)msg];
            break;
        }
        default:
            break;
    }
}

- (void)onReciveCommondMsg:(SconCommondMsg *)msg {
    if (self.commendMsgRecived) {
        self.commendMsgRecived(msg);
    }
}

- (void)onRecivePluginMsg:(SconPluginMsg *)msg {
    
    if (msg.identifier.length == 0 || msg.content.length == 0) {
        return;
    }
    
    id<SconPluginProtocol> plugin = [self.pluginsMap objectForKey:msg.identifier];
    if (plugin) {
        [plugin onReciveMsg:msg.content];
    }
}

@end
