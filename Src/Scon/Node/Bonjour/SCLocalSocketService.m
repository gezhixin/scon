//
//  SCLocalSocketService.m
//  Scon
//
//  Created by gezhixin on 2018/8/20.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SCLocalSocketService.h"
#import <arpa/inet.h>
#import "GCDAsyncSocket.h"
#import "SCLSocketConnection.h"
#import <Scon.h>

#define SCNetServiceDomain    @"local."
#define SCNetServiceType      @"_scon._tcp"
#define SCNetServiceName      (netServiceName())

static long SSocketTag = 232424;

NSString * netServiceName() {
    return NSUserName();
}

@interface SCLocalSocketService ()<NSNetServiceBrowserDelegate, NSNetServiceDelegate, GCDAsyncSocketDelegate>

@property (nonatomic, strong) NSNetService * netService;
@property (nonatomic, strong) dispatch_queue_t netServiceQueue;
@property (nonatomic, strong) NSRunLoop * netServiceRunloop;


@property (nonatomic, strong) dispatch_queue_t serviceSocketQueue;
@property (nonatomic, strong) GCDAsyncSocket *serviceSocket;

@property (nonatomic, strong) NSMutableDictionary<NSString*, SCLSocketConnection*> *remoteConnections;

@end

@implementation SCLocalSocketService

+ (instancetype)sharedInstance {
    static SCLocalSocketService * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SCLocalSocketService alloc] init];
    });
    
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.netServiceQueue = dispatch_queue_create("scon.local.netService", DISPATCH_QUEUE_SERIAL);
        self.serviceSocketQueue = dispatch_queue_create("scon.local.serviceSocket", DISPATCH_QUEUE_SERIAL);
        
        self.remoteConnections = [NSMutableDictionary dictionaryWithCapacity:2];
        
        dispatch_async(self.netServiceQueue, ^{
            self.netServiceRunloop = [NSRunLoop currentRunLoop];
            [[NSRunLoop currentRunLoop] run];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self startSocketService];
            });
        });
        
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.serviceSocket disconnect];
    self.remoteConnections = nil;
    self.serviceSocket = nil;
}

- (NSArray<SCRemoteDeviceInfo *> *)getRemoteDevInfoList {
    NSMutableArray * array = [NSMutableArray arrayWithCapacity:self.remoteConnections.count];
    for (SCLSocketConnection * c in [self.remoteConnections allValues]) {
        if (c.devInfo.deviceName.length > 0) {
            [array addObject:c.devInfo];
        }
    }
    return [array copy];
}

#pragma mark - Socket
- (int)startSocketService {
    if (!self.serviceSocket) {
        self.serviceSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:self.serviceSocketQueue];
    }
    
    int port = 8900 +  (arc4random() % 1000);
    
    NSError * err = nil;
    BOOL ret = [self.serviceSocket acceptOnPort:port error:&err];
    if (!ret || err) {
        NSLog(@"startSocketService error : %@", err);
        return -1;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self _publishNetServicefWithPort:port];
    });
    
    return port;
}

#pragma mark - NetServiceBrowser
- (void)_publishNetServicefWithPort:(int)port {
    if (!self.netService) {
        self.netService = [[NSNetService alloc] initWithDomain:SCNetServiceDomain type:SCNetServiceType name:SCNetServiceName port:port];
    }
    
    self.netService.delegate = self;
    
    NSString * appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    NSString * appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    
    NSDictionary * deviceInfo = @{
                                  @"appName" : appName,
                                  @"appVersion" : appVersion,
                                };
    NSError * error = nil;
    NSData * data  = [NSJSONSerialization dataWithJSONObject:deviceInfo
                                                     options:NSJSONWritingPrettyPrinted
                                                       error:&error];
    [self.netService setTXTRecordData:[NSNetService dataFromTXTRecordDictionary:@{@"deviceInfo": data}]];
    [self.netService scheduleInRunLoop:self.netServiceRunloop forMode:NSRunLoopCommonModes];
    [self.netService publish];
}

- (void)removeNetService {
    [self.netService stop];
    [self.netService removeFromRunLoop:self.netServiceRunloop forMode:NSRunLoopCommonModes];
    self.netService = nil;
}

#pragma mark - Setter
- (void)setCurrentRemoteDevice:(NSString *)deviceName {
    
    SCLSocketConnection * oC = (SCLSocketConnection*)[Scon sharedInstance].connection;
    NSLog(@"oc : %@", oC);
    
    for (SCLSocketConnection * c in [self.remoteConnections allValues]) {
         NSLog(@"cname : %@", c.devInfo.deviceName);
        if ([deviceName isEqualToString:c.devInfo.deviceName] && oC != c) {
            NSLog(@"c : %@", c);
            if (oC) {
                [oC.msgHandler sendCommend:@{@"connected": @(NO)}];
            }
            [[Scon sharedInstance] setConnection:c];
            if ([c.delegate respondsToSelector:@selector(onConnected:)]) {
                [c.delegate onConnected:c];
            }
            [c.msgHandler sendCommend:@{@"connected": @(YES)}];
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
    NSLog(@"didNotPublish %@", errorDict);
}

- (void)netServiceWillResolve:(NSNetService *)sender {
    NSLog(@"netServiceWillResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    NSLog(@"netServiceDidResolveAddress");
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

#pragma mark - GCDAsyncSocketDelegate
- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"didAcceptNewSocket %@", newSocket);
    SCLSocketConnection * c = [[SCLSocketConnection alloc] init];
    c.socket = newSocket;
    c.tag = SSocketTag;
    NSString * addr = [NSString stringWithFormat:@"%p", newSocket];
    [self.remoteConnections setObject:c forKey:addr];
    [newSocket readDataWithTimeout:-1 tag:c.tag];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(nullable NSError *)err {
    NSLog(@"socketDidDisconnect %@", sock);
    NSString * addr = [NSString stringWithFormat:@"%p", sock];
    [self.remoteConnections removeObjectForKey:addr];
    [[NSNotificationCenter defaultCenter] postNotificationName:KNotificationSConRemoteDeviceListChanged object:nil];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString * addr = [NSString stringWithFormat:@"%p", sock];
    SCLSocketConnection * c = [self.remoteConnections objectForKey:addr];
    [c onRecivceData:data];
    
    [sock readDataWithTimeout:-1 tag:tag];
}

@end
