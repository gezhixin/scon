//
//  SCSocket.h
//  Scon
//
//  Created by gezhixin on 2018/8/1.
//  Copyright © 2018年 gezhixin. All rights reserved.
//

#import <GCDAsyncSocket.h>
#import "SCServerInfo.h"

@interface SCSocket : GCDAsyncSocket

@property (nonatomic, strong) SCServerInfo * serverInfo;

@end
