//
//  SCLSocketConnection.m
//  SconSample
//
//  Created by gezhixin on 2018/8/20.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SCLSocketConnection.h"
#import "SCServerInfo.h"
#import "SCSocket.h"
#import <UIKit/UIKit.h>

#define SOCKET_TAG (2333333)

NSString * const kSCLServieListCHanged = @"SCLServieListCHanged";
NSString * const kSCConnectionActiveStateCHanged = @"SCConnectionActiveStateCHanged";


@interface SCLSocketConnection ()<NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSNetServiceBrowser * netServiceBrowser;
@property (nonatomic, strong) NSRunLoop *netServiceBrowserRunloop;

@property (nonatomic, strong) NSMutableArray<NSNetService*> * netServiceList;

@property (nonatomic, strong) dispatch_queue_t netServiceBrowserQueue;

@property (nonatomic, strong) dispatch_queue_t socketServiceQueue;
@property (nonatomic, strong) SCSocket * socket;

@property (nonatomic, strong) NSMutableArray<SCServerInfo*> *serviceList;

@end

@implementation SCLSocketConnection

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _propertyInit];
        [self _startNetServiceBrowser];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate:) name:UIApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self close];
}

- (void)_propertyInit {
    self.netServiceList = [NSMutableArray array];
    self.netServiceBrowserQueue = dispatch_queue_create("scon.local.net.browser", DISPATCH_QUEUE_SERIAL);
    self.socketServiceQueue = dispatch_queue_create("scon.local.net.socket", DISPATCH_QUEUE_SERIAL);
}

#pragma mark - getter
- (NSMutableArray<SCServerInfo *> *)serviceList {
    if (!_serviceList) {
        _serviceList = [NSMutableArray array];
    }
    
    return _serviceList;
}

- (NSArray<SCServerInfo *> *)remoteServiceList {
    return [_serviceList copy];
}

#pragma mark - setter
- (void)setActive:(BOOL)active {
    if (active == _active) {
        return;
    }
    
    _active = active;
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCConnectionActiveStateCHanged object:nil];
}

#pragma mark - Override
- (NSString *)identifier {
    return @"SCLocalSocketConnectionClient";
}

- (void)startConnect {
    
}

- (void)close {
    [self.socket disconnect];
}

- (void)reConnect {
    if (self.socket && self.socket.serverInfo && !self.socket.isConnected) {
        SCServerInfo * info = self.socket.serverInfo;
        
        NSError * err = nil;
        BOOL ret = [self.socket connectToHost:info.host onPort:info.port error:&err];
        if (ret != 0 && err) {
            NSLog(@"connectToHost err : %@", err);
        }
    }
}

- (void)sendMsg:(NSData *)msg {
    [self.socket writeData:msg withTimeout:-1 tag:SOCKET_TAG];
}

- (void)onReciveMsg:(SconMsg *)msg {
    if ([msg isKindOfClass:[SconCommondMsg class]]) {
        SconCommondMsg * cmd = (SconCommondMsg*)msg;
        BOOL isConnected = [[cmd.content objectForKey:@"connected"] boolValue];
        self.active = isConnected;
        if (isConnected) {
            if ([self.delegate respondsToSelector:@selector(onConnected:)]) {
                [self.delegate onConnected:self];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(onDisconnected:)]) {
                [self.delegate onDisconnected:self];
            }
        }
    }
    
    [super onReciveMsg:msg];
}

- (BOOL)connectService:(SCServerInfo *)info {
    if ([self.socket.serverInfo.name isEqualToString:info.name] && self.socket.isConnected) {
        return YES;
    }
    
    if (!self.socket) {
        self.socket = [[SCSocket alloc] initWithDelegate:self delegateQueue:self.socketServiceQueue];
    }
    
    if (self.socket.isConnected) {
        [self.socket disconnect];
    }
    
    self.socket.serverInfo = info;
    
    NSError * err = nil;
    for (NSData * addr in info.addresses) {
        err = nil;
        BOOL ret = [self.socket connectToAddress:addr withTimeout:15 error:&err];
        if (ret != 0 && err) {
            NSLog(@"connectToHost err : %@", err);
        } else {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - NetServiceBrowser
- (void)_startNetServiceBrowser {
    dispatch_async(self.netServiceBrowserQueue, ^{
        NSNetServiceBrowser * browser = [[NSNetServiceBrowser alloc] init];
        browser.delegate = self;
        [browser searchForServicesOfType:@"_scon._tcp" inDomain:@"local."];
        self.netServiceBrowser = browser;
        self.netServiceBrowserRunloop = [NSRunLoop currentRunLoop];
        [browser scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}

- (NSDictionary *)getDevInfo {
    UIDevice * device = [UIDevice currentDevice];
    
    NSString * deviceName = device.name;
#if TARGET_OS_SIMULATOR
    int randomId = 100 +  (arc4random() % 1000);
    deviceName = [NSString stringWithFormat:@"%@ %@-%d", [[UIDevice currentDevice] model], @"Simulator", randomId];
#endif
    
    NSString * appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    NSString * appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSDictionary * deviceInfo = @{@"name" : deviceName,
                                  @"systemName" : device.systemName,
                                  @"model" : device.model,
                                  @"systemVersion" : device.systemVersion,
                                  @"appName" : appName,
                                  @"appVersion" : appVersion,
                                  };
    return deviceInfo;
}

#pragma mark delegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {
    
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"net service did find : domain %@, type %@, name %@, port: %ld", service.domain, service.type, service.name, service.port);
    [self.netServiceList addObject:service];
    service.delegate = self;
    [service resolveWithTimeout:5];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"didRemoveService");
    [self.netServiceList removeObject:service];
    
    if ([self.socket.serverInfo.name isEqualToString:service.name]) {
        [self.socket disconnect];
        self.socket = nil;
        if ([self.delegate respondsToSelector:@selector(onDisconnected:)]) {
            [self.delegate onDisconnected:self];
        }
    }
    
    for (SCServerInfo * info in self.serviceList) {
        if ([info.name isEqualToString:service.name]) {
            [self.serviceList removeObject:info];
            [[NSNotificationCenter defaultCenter] postNotificationName:kSCLServieListCHanged object:nil];
            break;
        }
    }
}

#pragma mark - NetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender{
    NSLog(@"netServiceWillPublish");
}

- (void)netServiceDidPublish:(NSNetService *)sender{
    NSLog(@"netServiceDidPublish");
}

- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSLog(@"didNotPublish");
}

- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"netServiceWillResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"netServiceDidResolveAddress");
    SCServerInfo * info = [SCServerInfo serverInfoFromNetService:sender];

    BOOL exist = NO;
    for (SCServerInfo * s in self.serviceList) {
        if ([s.name isEqualToString:info.name]) {
            exist = YES;
            break;
        }
    }
    if (!exist) {
        [self.serviceList addObject:info];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCLServieListCHanged object:nil];
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {
    NSLog(@"didNotResolve");
}

- (void)netServiceDidStop:(NSNetService *)sender {
    NSLog(@"netServiceDidStop");
}

- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {
    NSLog(@"didUpdateTXTRecordData");
}

- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {
    NSLog(@"didAcceptConnectionWithInputStream");
}

#pragma mark - Scon_Scon_GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    NSLog(@"didConnectToHost -> %@", sock);
    self.isConnected = YES;
    
    [self.msgHandler sendCommend:@{@"bdev": @(YES), @"devInfo": [self getDevInfo]}];
    
    [sock readDataWithTimeout:-1 tag:SOCKET_TAG];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"socketDidDisconnect -> %@ %@", sock, err);
    self.isConnected = NO;
    self.active = NO;
    [self.socket disconnect];
    self.socket = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onDisconnected:)]) {
        [self.delegate onDisconnected:self];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSLog(@"didReadData");
    [self onRecivceData:data];
    [self.socket readDataWithTimeout:-1 tag:SOCKET_TAG];
}


#pragma mark - Notifications
- (void)applicationWillTerminate:(UIApplication *)application {
    if (self.socket.isConnected) {
        [self.socket disconnect];
    }
    [self.netServiceBrowser removeFromRunLoop:self.netServiceBrowserRunloop forMode:NSRunLoopCommonModes];
    [self.netServiceBrowser stop];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    if (self.socket.isConnected) {
        [self.socket disconnect];
        self.socket = nil;
    }
    
    [self.serviceList removeAllObjects];
    [self.netServiceList removeAllObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSCLServieListCHanged object:nil];
    [self.netServiceBrowser removeFromRunLoop:self.netServiceBrowserRunloop forMode:NSRunLoopCommonModes];
    [self.netServiceBrowser stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application{
    [self.netServiceBrowser scheduleInRunLoop:self.netServiceBrowserRunloop forMode:NSRunLoopCommonModes];
    [self.netServiceBrowser searchForServicesOfType:@"_scon._tcp" inDomain:@"local."];
}

@end
