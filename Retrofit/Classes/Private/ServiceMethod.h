//
//  ServiceMethod.h
//  Retrofit
//
//  Created by Dailingchi on 16/4/15.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Retrofit;
@protocol ServicePresentable;
@class AFHTTPRequestOperationManager;

/**
 用于配置服务信息
 */
@interface ServiceMethod : NSObject

- (instancetype)initWith:(id<ServicePresentable>)service retrofit:(Retrofit *)retrofit;

- (NSURLRequest *)toRequest:(NSError **)error;
- (NSURLRequest *)toRequest:(AFHTTPRequestOperationManager *)manager error:(NSError **)error;
- (id)toResponse:(NSHTTPURLResponse *)response data:(NSData *)responseData error:(NSError **)error;

@end
