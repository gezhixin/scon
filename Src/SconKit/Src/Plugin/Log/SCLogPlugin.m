//
//  SCLogPlugin.m
//  Scon
//
//  Created by gezhixin on 2018/7/31.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SCLogPlugin.h"
#import <DDLog.h>
#import <DDTTYLogger.h>
#import <objc/message.h>
#import <objc/runtime.h>

@interface SCLogPlugin ()

@property (nonatomic, strong) SconMsgHandler * msgHandler;

@end

@implementation SCLogPlugin

- (instancetype)init
{
    self = [super init];
    if (self) {
        __weak SCLogPlugin * wSelf = self;
        [self setDDLogHook:^(DDLogMessage *logMessage) {
            __strong SCLogPlugin * strongSelf = wSelf;
            [strongSelf sendDDLog:logMessage];
        }];
    }
    return self;
}

- (NSString *) identifier {
    return @"SCLogPlugin";
}

- (void)onConnected:(SconMsgHandler *)msgHandler {
    self.msgHandler = msgHandler;
}

- (void)onDisconnected {
    self.msgHandler = nil;
}

- (void)onReciveMsg:(NSData *)data {
    
}

- (void)sendDDLog:(DDLogMessage *)logMessage {
    if (self.msgHandler && logMessage) {
        NSData * data = [self logMessageToJsonData:logMessage];
        [self.msgHandler sendPluginMsg:self.identifier msg:data];
    }
}

/*
- - (void)queueLogMessage:(DDLogMessage *)logMessage asynchronously:(BOOL)asyncFlag
*/
- (void)setDDLogHook:(void(^)(DDLogMessage *logMessage))logCallBack {
    
    Class className = [DDLog class];
    
    NSString * orSelStr = @"queueLogMessage:asynchronously:";
    SEL orSel = NSSelectorFromString(orSelStr);
    
    Method originalResume = class_getInstanceMethod(className, orSel);
    if (originalResume == nil) {
        return;
    }
    
    SEL swizSel = NSSelectorFromString([NSString stringWithFormat:@"scon_%d_%@", arc4random(), orSelStr]);
    
    typedef void(^TLogBLK)(DDLog * slf, DDLogMessage *logMessage, BOOL asynchronous);
    
    TLogBLK logBlk = ^(DDLog * slf, DDLogMessage *logMessage, BOOL asynchronous) {
        ((void(*)(id, SEL, DDLogMessage *, BOOL))objc_msgSend)(slf, swizSel, logMessage, asynchronous);
        if (logCallBack) {
            logCallBack(logMessage);
        }
    };
    
    IMP implementation = imp_implementationWithBlock(logBlk);
    class_addMethod(className, swizSel, implementation, method_getTypeEncoding(originalResume));
    Method newResume = class_getInstanceMethod(className, swizSel);
    
    method_exchangeImplementations(originalResume, newResume);
}

- (NSData *)logMessageToJsonData:(DDLogMessage *)logMessage {
#define KILL_Nil_STR(str) (str == nil ? @"" : str)
    NSMutableDictionary * logInfo = [NSMutableDictionary dictionaryWithCapacity:7];
    static NSDictionary<NSNumber *, NSString*> * flagStrMap = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //'unknown' | 'verbose' | 'debug' | 'info' | 'warn' | 'error' | 'fatal',
        flagStrMap = @{
                       @(DDLogFlagInfo): @"info",
                       @(DDLogFlagVerbose) : @"verbose",
                       @(DDLogFlagDebug) : @"debug",
                       @(DDLogFlagWarning) : @"warn",
                       @(DDLogFlagError) : @"error",
                       };
    });
    [logInfo setObject:KILL_Nil_STR(flagStrMap[@(logMessage.flag)]) forKey:@"flag"];
    [logInfo setObject:KILL_Nil_STR(logMessage.message) forKey:@"msg"];
    [logInfo setObject:KILL_Nil_STR(logMessage.fileName) forKey:@"file"];
    [logInfo setObject:KILL_Nil_STR(logMessage.function) forKey:@"fun"];
    [logInfo setObject:@(logMessage.line) forKey:@"line"];
    [logInfo setObject:@((long)logMessage.timestamp.timeIntervalSince1970) forKey:@"time"];
    
    NSString * appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleNameKey];
    [logInfo setObject:appName forKey:@"tag"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization  dataWithJSONObject:logInfo options:0 error:&err];
    if (err != nil)
    {
        return nil;
    }
    
    return jsonData;
}

@end

