//
//  SconMsg.m
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "SconMsg.h"

const int64_t CHeaderStartIndex = 8926592795283458;

typedef struct S_MsgFrame {
    int64_t headerStartIndex;
    int64_t time;
    int32_t msgType;
    int32_t contentLenth;
    int32_t identifierLenth;
    int64_t headerCheckCode;
    const void * content;
    
} _MsgFrame;


const int64_t CHeaderLenth = sizeof(_MsgFrame);

int64_t getCheckCode(_MsgFrame frame) {
    return (int64_t)(frame.headerStartIndex^frame.time^frame.msgType^frame.contentLenth);
}

NSData * encodeMsgFrameToData(_MsgFrame frame) {
    
    if (frame.content == NULL) {
        return nil;
    }
    
    unsigned int lenth = CHeaderLenth + frame.contentLenth;
    
    char * content = (char*)malloc(lenth);
    if (content == NULL) {
        return nil;
    }
    
    memset(content, 0, lenth);
    memcpy(content, &frame, CHeaderLenth);
    memcpy(content + CHeaderLenth, frame.content, frame.contentLenth);
    
    NSData * data = [NSData dataWithBytes:content length:lenth];
    
    free(content);
    content = NULL;
    
    return data;
}

SconMsg * decodeMsg(const void * content, int64_t lenth, int64_t * offset) {
    if (lenth < CHeaderLenth) {
        *offset = 0;
        return nil;
    }
    
    _MsgFrame frame;
    
    memcpy(&frame, content, CHeaderLenth);
    
    if (frame.headerStartIndex != CHeaderStartIndex
        || getCheckCode(frame) != frame.headerCheckCode
        || frame.contentLenth + CHeaderLenth > lenth) {
        offset = 0;
        return nil;
    }
    
    *offset = CHeaderLenth + frame.contentLenth;
    
    switch (frame.msgType) {
        case SconMsgTypeCmd:
        {
            NSData * data = [[NSData alloc] initWithBytes:(void*)((char*)content + CHeaderLenth) length:frame.contentLenth];
            NSError * error = nil;
            NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (error) {
                return nil;
            }
            
            SconCommondMsg * commondMsg = [[SconCommondMsg alloc] init];
            commondMsg.content = dic;
            return commondMsg;
        }
        case SconMsgTypePlugin:
        {
            NSString * identifier = [[NSString alloc] initWithBytes:(void*)((char*)content + CHeaderLenth) length:frame.identifierLenth encoding:NSUTF8StringEncoding];
            NSData * data = [NSData dataWithBytes:(void*)((char*)content + CHeaderLenth + frame.identifierLenth) length:(frame.contentLenth - frame.identifierLenth)];
            SconPluginMsg * pluginMsg = [[SconPluginMsg alloc] init];
            pluginMsg.identifier = identifier;
            pluginMsg.content = data;
            
            return pluginMsg;
        }
        default:
            return nil;
    }
}


@implementation SconMsg

- (NSData *)msgtoData {
    return nil;
}

@end


@implementation SconCommondMsg

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = SconMsgTypeCmd;
    }
    return self;
}

- (NSData *)msgtoData {
    if (!self.content) {
        return nil;
    }
    
    NSError * error = nil;
    NSData * contentData  = [NSJSONSerialization dataWithJSONObject:self.content
                                                            options:NSJSONWritingPrettyPrinted
                                                              error:&error];
    if (error) {
        return nil;
    }
    
    _MsgFrame frame;
    frame.headerStartIndex = CHeaderStartIndex;
    frame.time = (int64_t)[[NSDate date] timeIntervalSince1970];
    frame.msgType = SconMsgTypeCmd;
    frame.identifierLenth = 0;
    frame.contentLenth = (int32_t)contentData.length;
    frame.headerCheckCode = getCheckCode(frame);
    frame.content = contentData.bytes;
    
    return encodeMsgFrameToData(frame);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"cmd: %@", [self.content description]];
}

@end

@implementation SconPluginMsg

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = SconMsgTypePlugin;
    }
    return self;
}

- (NSData *)msgtoData {
    if (!self.content || self.identifier.length == 0) {
        return nil;
    }
    
    NSData * identifierData = [self.identifier dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData * data = [NSMutableData dataWithData:identifierData];
    [data appendData:self.content];
    
    _MsgFrame frame;
    frame.headerStartIndex = CHeaderStartIndex;
    frame.time = (int64_t)[[NSDate date] timeIntervalSince1970];
    frame.msgType = SconMsgTypePlugin;
    frame.identifierLenth = (int32_t)identifierData.length;
    frame.contentLenth = (int32_t)data.length;
    frame.headerCheckCode = getCheckCode(frame);
    frame.content = data.bytes;
    
    return encodeMsgFrameToData(frame);
}

- (NSString *)description {
    return [NSString stringWithFormat:@"plugin: %@", self.identifier];
}

@end
