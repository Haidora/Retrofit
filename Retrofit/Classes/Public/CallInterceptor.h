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
 *  用于拦截请求事件
 */
@protocol CallInterceptor <NSObject>

- (void)willSendRequest:(NSURLRequest *)request service:(id<ServicePresentable>)service;
- (void)didReceiveResponse:(NSHTTPURLResponse *)response
                      data:(NSData *)responseData
                   service:(id<ServicePresentable>)service;

@end
