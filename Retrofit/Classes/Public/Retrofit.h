//
//  Retrofit.h
//  Retrofit
//
//  Created by Dailingchi on 16/4/15.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

/// AFNetworking-Serialization

#import <Foundation/Foundation.h>

#import "Call.h"
@protocol ServicePresentable;
@protocol CallValidator;
@protocol CallInterceptor;

/**
 *  Retrofit用于配置服务和构建Call(Call暂时不支持替换)
 */
@interface Retrofit : NSObject

#pragma mark
#pragma mark build call
@property (nonatomic, copy, readonly) Call * (^create)(id<ServicePresentable> service);
- (Call *)create:(id<ServicePresentable>)service;

@end

#pragma mark
#pragma mark RetrofitBuilder

@interface RetrofitBuilder : NSObject

@property (nonatomic, copy, readonly) RetrofitBuilder * (^baseURL)(NSString *baseURL);
@property (nonatomic, copy, readonly) RetrofitBuilder * (^timeoutInterval)
    (NSTimeInterval timeoutInterval);
@property (nonatomic, copy, readonly) RetrofitBuilder * (^addValidator)(id<CallValidator> validator)
    ;
@property (nonatomic, copy, readonly) RetrofitBuilder * (^addInterceptor)
    (id<CallInterceptor> interceptor);

@property (nonatomic, copy, readonly) Retrofit * (^build)(void);

@end
