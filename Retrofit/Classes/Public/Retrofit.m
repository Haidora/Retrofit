//
//  Retrofit.m
//  Retrofit
//
//  Created by Dailingchi on 16/4/15.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import "Retrofit.h"

#import "AFHTTPRequestCall.h"
#import "Retrofit_Internal.h"
#import "ServiceMethod.h"

@implementation Retrofit

- (Call * (^)(id<ServicePresentable> service))create
{
    __weak typeof(self) weakSelf = self;
    return (id) ^ (id<ServicePresentable> service) { return [weakSelf create:service]; };
}

- (Call *)create:(id<ServicePresentable>)service
{
    //构造serviceMethod
    ServiceMethod *serviceMethod = [[ServiceMethod alloc] initWith:service retrofit:self];
    //生成Call
    // TODO:动态的替换
    Call *call = [[AFHTTPRequestCall alloc] initWith:serviceMethod];
    return call;
}

#pragma mark
#pragma mark Setter/Getter

- (void)setBaseURL:(NSURL *)baseURL
{
    _baseURL = baseURL;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    _timeoutInterval = timeoutInterval;
}

@end

@interface RetrofitBuilder ()

@property (nonatomic, strong) NSURL *pBaseURL;
@property (nonatomic, assign) NSTimeInterval pTimeoutInterval;
@property (nonatomic, strong) NSMutableArray<CallValidator> *pValidators;
@property (nonatomic, strong) NSMutableArray<CallInterceptor> *pInterceptors;

@end

@implementation RetrofitBuilder

- (RetrofitBuilder * (^)(NSString *))baseURL
{
    return ^(NSString *baseURL) {
      self.pBaseURL = [NSURL URLWithString:baseURL];
      return self;
    };
}

- (RetrofitBuilder * (^)(NSTimeInterval))timeoutInterval
{
    return ^(NSTimeInterval timeoutInterval) {
      self.pTimeoutInterval = timeoutInterval;
      return self;
    };
}

- (RetrofitBuilder * (^)(id<CallValidator>))addValidator
{
    return ^(id<CallValidator> validator) {
      [self.pValidators addObject:validator];
      return self;
    };
}

- (RetrofitBuilder * (^)(id<CallInterceptor>))addInterceptor
{
    return ^(id<CallInterceptor> interceptor) {
      [self.pInterceptors addObject:interceptor];
      return self;
    };
}

- (Retrofit * (^)())build
{
    return ^() {
      Retrofit *retrofit = [Retrofit new];
      [retrofit setBaseURL:self.pBaseURL];
      [retrofit setTimeoutInterval:self.pTimeoutInterval];
      retrofit.validators = self.pValidators;
      retrofit.interceptors = self.pInterceptors;
      return retrofit;
    };
}

#pragma mark
#pragma mark Getter

- (NSMutableArray<CallValidator> *)pValidators
{
    if (nil == _pValidators)
    {
        _pValidators = [[NSMutableArray<CallValidator> alloc] init];
    }
    return _pValidators;
}

- (NSMutableArray<CallInterceptor> *)pInterceptors
{
    if (nil == _pInterceptors)
    {
        _pInterceptors = [[NSMutableArray<CallInterceptor> alloc] init];
    }
    return _pInterceptors;
}

@end
