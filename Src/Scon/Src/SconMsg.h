//
//  SconMsg.h
//  SconSample
//
//  Created by gezhixin on 2018/7/27.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SconMsg;

typedef NS_ENUM(int32_t, SconMsgType) {
    SconMsgTypeCmd = 78683,
    SconMsgTypePlugin = 34359,
};

SconMsg * decodeMsg(const void * content, int64_t lenth, int64_t * offset);

@interface SconMsg : NSObject

@property (nonatomic, assign) SconMsgType type;

- (NSData *)msgtoData;

@end


@interface SconCommondMsg : SconMsg

@property (nonatomic, strong) NSDictionary * content;

@end


@interface SconPluginMsg : SconMsg

@property (nonatomic, strong) NSString * identifier;

@property (nonatomic, strong) NSData * content;

@end
