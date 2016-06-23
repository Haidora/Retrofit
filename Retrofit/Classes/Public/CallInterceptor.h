//
//  CallInterceptor.h
//  Pods
//
//  Created by Dailingchi on 16/6/20.
//
//

#import <Foundation/Foundation.h>

@protocol ServicePresentable;

/**
 *  用于请求拦截
 */
@protocol CallInterceptor <NSObject>

@optional

- (void)willSendRequest:(NSURLRequest *)request service:(id<ServicePresentable>)service;
- (void)didReceiveResponse:(NSHTTPURLResponse *)response service:(id<ServicePresentable>)service;

@end
