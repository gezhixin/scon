//
//  Bonjour.m
//  Sample
//
//  Created by aaronge on 2020/1/16.
//  Copyright © 2020 gezhixin. All rights reserved.
//

#import "Bonjour.h"
#import <arpa/inet.h>

@interface ServerInfo ()

@property (nonatomic, strong) NSNetService *netService;

+ (ServerInfo *)serverInfoFromNetService:(NSNetService *)netService;

@end

@interface Bonjour () <NSNetServiceDelegate, NSNetServiceBrowserDelegate>

@property (nonatomic, strong) NSRunLoop * netServiceRunloop;
@property (nonatomic, strong) NSNetService *netService;
@property (nonatomic, strong) dispatch_queue_t netServiceQueue;

@property (nonatomic, strong) NSNetServiceBrowser * netServiceBrowser;
@property (nonatomic, strong) NSMutableArray<NSNetService*> * netServices;

@property (nonatomic, strong) NSMutableArray<ServerInfo *> *services;
@property (nonatomic, copy) void(^onNetServiceListChanged)(NSArray<ServerInfo *> *servcies);

@end

@implementation Bonjour

#pragma mark - Life Cycles
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.netServices = [NSMutableArray arrayWithCapacity:10];
        self.services = [NSMutableArray arrayWithCapacity:10];
        [self setupNetServiceEvent];
    }
    return self;
}

- (void)dealloc {
    [self stop];
}

#pragma mark - Public Methols
#pragma mark Public
- (void)publishWithName:(NSString *)name domain:(NSString *)domain type:(NSString *)type port:(int)port {
    [self stop];
    if (!self.netService) {
        self.netService = [[NSNetService alloc] initWithDomain:domain type:type name:name port:port];
    }
    
    self.netService.delegate = self;
    [self.netService scheduleInRunLoop:self.netServiceRunloop forMode:NSRunLoopCommonModes];
    [self.netService publish];

    NSLog(@"[Bonjour] publish name: %@ domain: %@ type: %@ port: %d", name, domain, type, port);
}

- (void)stop {
    if (self.netService) {
        [self.netService stop];
        [self.netService removeFromRunLoop:self.netServiceRunloop forMode:NSRunLoopCommonModes];
        self.netService = nil;
    }
    NSLog(@"[Bonjour] stop");
}

#pragma mark Search
- (void)browerWithType:(NSString *)type inDomain:(NSString *)domain listChanged:(void(^)(NSArray<ServerInfo *> *servcies))listChanged {
    self.onNetServiceListChanged = listChanged;
    __weak Bonjour *ws = self;
    dispatch_async(self.netServiceQueue, ^{
        Bonjour *ss = ws;
        [ss stopBrower];
        if (!ss.netServiceBrowser) {
            ss.netServiceBrowser = [[NSNetServiceBrowser alloc] init];
        }
        [ss.netServiceBrowser scheduleInRunLoop:ss.netServiceRunloop forMode:NSRunLoopCommonModes];
        ss.netServiceBrowser.delegate = ss;
        [ss.netServiceBrowser searchForServicesOfType:type inDomain:domain];
    });
}

- (void)stopBrower {
    if (self.netServiceBrowser) {
        [self.netServiceBrowser removeFromRunLoop:self.netServiceRunloop forMode:NSRunLoopCommonModes];
        [self.netServiceBrowser stop];
        self.netServiceBrowser = nil;
    }
}

#pragma mark - Privite
- (void)setupNetServiceEvent {
    self.netServiceQueue = dispatch_queue_create("bonjour.netService", DISPATCH_QUEUE_SERIAL);
    dispatch_async(self.netServiceQueue, ^{
       self.netServiceRunloop = [NSRunLoop currentRunLoop];
       [[NSRunLoop currentRunLoop] run];
   });
}

#pragma mark - NetServiceDelegate
- (void)netServiceWillPublish:(NSNetService *)sender{}
- (void)netServiceDidPublish:(NSNetService *)sender{}
- (void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *, NSNumber *> *)errorDict {}
- (void)netServiceWillResolve:(NSNetService *)sender {}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    ServerInfo *service = [ServerInfo serverInfoFromNetService:sender];
    __block NSInteger findIdx = NSNotFound;
    [self.services enumerateObjectsUsingBlock:^(ServerInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.host isEqualToString:service.host] && obj.port == service.port) {
            findIdx = idx;
            *stop = YES;
        }
    }];
    if (findIdx == NSNotFound) {
        [self.services addObject:service];
        if (self.onNetServiceListChanged) {
            self.onNetServiceListChanged([self.services copy]);
        }
    }
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *, NSNumber *> *)errorDict {}
- (void)netServiceDidStop:(NSNetService *)sender {}
- (void)netService:(NSNetService *)sender didUpdateTXTRecordData:(NSData *)data {}
- (void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream {}

#pragma mark - NSNetServiceBrowserDelegate
- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser {}
- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *, NSNumber *> *)errorDict {}
- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing {}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    NSLog(@"net service did find : domain %@, type %@, name %@, port: %ld", service.domain, service.type, service.name, service.port);
    [self.netServices addObject:service];
    service.delegate = self;
    [service resolveWithTimeout:5];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveDomain:(NSString *)domainString moreComing:(BOOL)moreComing {
    
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
    [self.netServices removeObject:service];
    
    __block NSInteger toDeletIdx = NSNotFound;
    [self.services enumerateObjectsUsingBlock:^(ServerInfo * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.netService == service) {
            toDeletIdx = idx;
            *stop = YES;
        }
    }];
    
    if (toDeletIdx != NSNotFound) {
        [self.services removeObjectAtIndex:toDeletIdx];
        if (self.onNetServiceListChanged) {
            self.onNetServiceListChanged([self.services copy]);
        }
    }
}

@end


@implementation ServerInfo

+ (ServerInfo *)serverInfoFromNetService:(NSNetService *)netService {
    NSData *address = [netService.addresses firstObject];
    struct sockaddr_in *socketAddress = (struct sockaddr_in *)[address bytes];
    
    ServerInfo * info = [[ServerInfo alloc] init];
    info.name = netService.name;
    info.hostName = netService.hostName;
    info.host = [[NSString alloc] initWithUTF8String:inet_ntoa(socketAddress->sin_addr)];
    info.port = netService.port;
    
    info.netService = netService;
    
    return info;
}

@end
