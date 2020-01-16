//
//  SCLSocketConnection.h
//  SconSample
//
//  Created by gezhixin on 2018/8/20.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import "Scon.h"
#import "SCServerInfo.h"

extern NSString * const kSCLServieListCHanged;
extern NSString * const kSCConnectionActiveStateCHanged;

@interface SCLSocketConnection : SconConnection

@property (nonatomic, assign) BOOL active;

@property (nonatomic, strong, readonly) NSArray<SCServerInfo*> *remoteServiceList;

- (BOOL)connectService:(SCServerInfo *)info;

@end
