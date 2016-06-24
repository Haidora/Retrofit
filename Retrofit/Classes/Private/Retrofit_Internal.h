//
//  Retrofit_Internal.h
//  Pods
//
//  Created by Dailingchi on 16/6/20.
//
//

#import <Foundation/Foundation.h>

#import "Retrofit.h"

@protocol CallValidator;
@protocol CallInterceptor;

@interface Retrofit ()

/**
 *  服务器根地址
 */
@property (nonatomic, strong) NSURL *baseURL;

/**
 *  请求超时时间,默认60s
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 *  验证
 */
@property (nonatomic, strong) NSArray<CallValidator> *validators;

/**
 *  拦截
 */
@property (nonatomic, strong) NSArray<CallInterceptor> *interceptors;

@end
