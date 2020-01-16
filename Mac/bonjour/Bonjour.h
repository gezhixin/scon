//
//  Bonjour.h
//  Sample
//
//  Created by aaronge on 2020/1/16.
//  Copyright © 2020 gezhixin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ServerInfo : NSObject

@property (nonatomic, copy) NSString * name;
@property (nonatomic, copy) NSString * hostName;
@property (nonatomic, copy) NSString * host;
@property (nonatomic, assign) NSInteger port;

@end

@interface Bonjour : NSObject

- (void)publishWithName:(NSString *)name domain:(NSString *)domain type:(NSString *)type port:(int)port;

- (void)stop;

@end

NS_ASSUME_NONNULL_END
