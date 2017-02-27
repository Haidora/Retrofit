//
//  ServiceMethod.m
//  Retrofit
//
//  Created by Dailingchi on 16/4/15.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import "CallInterceptor.h"
#import "CallValidator.h"
#import "Retrofit.h"
#import "Retrofit_Internal.h"
#import "ServiceMethod.h"
#import "ServicePresentable.h"
#import <AFNetworking/AFURLRequestSerialization.h>
#import <AFNetworking/AFURLResponseSerialization.h>

@interface ServiceMethod ()

@property (nonatomic, strong) Retrofit *retrofit;
@property (nonatomic, strong) id<ServicePresentable> service;
// http info
@property (nonatomic, strong) NSURL *httpURL;
@property (nonatomic, copy) NSString *httpMethod;
@property (nonatomic, assign) NSTimeInterval timeoutInterval;
@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) id parameters;
// Serializer
@property (nonatomic, strong) AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;
@property (nonatomic, copy) void (^multipartForm)(id<AFMultipartFormData>);
@property (nonatomic, strong)
    AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;

@end

@implementation ServiceMethod

- (instancetype)initWith:(id<ServicePresentable>)service retrofit:(Retrofit *)retrofit;
{
    self = [super init];
    if (self)
    {
        self.service = service;
        self.retrofit = retrofit;
    }
    return self;
}

- (void)dealloc
{
    NSLog(@"%@-dealloc", NSStringFromClass([self class]));
}

- (NSURLRequest *)toRequest:(NSError **)error
{
    [self praseInfo];

    NSString *httpMethod = self.httpMethod;
    NSString *httpURLString = self.httpURL.absoluteString;
    id parameters = self.parameters;

    // Serializer
    NSMutableURLRequest *request;
    if (self.multipartForm)
    {
        request = [self.requestSerializer multipartFormRequestWithMethod:httpMethod
                                                               URLString:httpURLString
                                                              parameters:parameters
                                               constructingBodyWithBlock:self.multipartForm
                                                                   error:error];
    }
    else
    {
        request = [self.requestSerializer requestWithMethod:httpMethod
                                                  URLString:httpURLString
                                                 parameters:parameters
                                                      error:error];
    }
    if (*error)
    {
        return nil;
    }
    //timeout
    if (self.timeoutInterval > 0)
    {
        request.timeoutInterval = self.timeoutInterval;
    }
    // Interceptor
    for (id<CallInterceptor> interceptor in self.retrofit.interceptors)
    {
        [interceptor willSendRequest:request service:self.service];
    }
    return request;
}

- (id)toResponse:(NSHTTPURLResponse *)response data:(NSData *)responseData error:(NSError **)error
{ // Interceptor
    for (id<CallInterceptor> interceptor in self.retrofit.interceptors)
    {
        [interceptor didReceiveResponse:response data:responseData service:self.service];
    }
    // Serializer
    id responseObject =
        [self.responseSerializer responseObjectForResponse:response data:responseData error:error];
    if (*error)
    {
        return nil;
    }

    // check validator
    for (id<CallValidator> validator in self.retrofit.validators)
    {
        if (![validator validatorResponse:response responseObject:responseObject error:error])
        {
            return nil;
        }
    }
    return responseObject;
}

#pragma mark
#pragma mark Private Utils

- (void)praseInfo
{
    // parse Http method info(参数等)
    self.httpURL = [self praseURL];
    self.httpMethod = [self praseHttpMethod];
    self.parameters = [self praseParameters];
    self.timeoutInterval = [self praseTimeoutInterval];
    self.requestSerializer = [self praseRequestSerializer];
    self.responseSerializer = [self praseResponseSerializer];
    self.multipartForm = [self praseMultipartForm];
}

- (NSURL *)praseURL
{
    NSURL *requestURL = nil;
    if ([self.service respondsToSelector:@selector(baseURL)])
    {
        requestURL = [self.service baseURL];
    }
    if (!requestURL)
    {
        requestURL = self.retrofit.baseURL;
    }

    NSString *relativePath = nil;
    if ([self.service respondsToSelector:@selector(relativePath)])
    {
        relativePath = [self.service relativePath];
    }
    if (relativePath)
    {
        requestURL = [NSURL URLWithString:relativePath relativeToURL:requestURL];
    }
    NSAssert(requestURL != nil, @"");
    return requestURL;
}

- (NSString *)praseHttpMethod
{
    NSString *httpMethod = nil;
    if ([self.service respondsToSelector:@selector(httpMethod)])
    {
        httpMethod = [self.service httpMethod];
    }
    httpMethod = httpMethod ?: @"GET";
    // TODO: Check Http方法的类型
    return httpMethod;
}

- (id)praseParameters
{
    id parameters = nil;
    if ([self.service respondsToSelector:@selector(parameters)])
    {
        parameters = [self.service parameters];
    }
    return parameters;
}

- (NSTimeInterval)praseTimeoutInterval
{
    NSTimeInterval timeoutInterval = 0;
    if ([self.service respondsToSelector:@selector(timeoutInterval)])
    {
        timeoutInterval = [self.service timeoutInterval] ?: self.retrofit.timeoutInterval;
    }
    return timeoutInterval;
}

- (AFHTTPRequestSerializer<AFURLRequestSerialization> *)praseRequestSerializer
{
    AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer = nil;
    if ([self.service respondsToSelector:@selector(requestSerializer)])
    {
        requestSerializer = [self.service requestSerializer];
    }
    return requestSerializer ?: [AFHTTPRequestSerializer serializer];
}

- (AFHTTPResponseSerializer<AFURLResponseSerialization> *)praseResponseSerializer
{
    AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer = nil;
    if ([self.service respondsToSelector:@selector(responseSerializer)])
    {
        responseSerializer = [self.service responseSerializer];
    }
    return responseSerializer ?: [AFHTTPResponseSerializer serializer];
}

- (void (^)(id<AFMultipartFormData>))praseMultipartForm
{
    void (^multipartForm)(id<AFMultipartFormData>) = nil;
    if ([self.service respondsToSelector:@selector(multipartForm)])
    {
        multipartForm = [self.service multipartForm];
    }
    return multipartForm;
}

@end
