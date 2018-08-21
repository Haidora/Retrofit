//
//  AFHTTPRequestCall.m
//  Retrofit
//
//  Created by Dailingchi on 16/6/16.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import "AFHTTPRequestCall.h"
#import "Call.h"
#import "ServiceMethod.h"
#import <AFNetworking/AFNetworking.h>

#if __has_include(<AFNetworking/AFHTTPRequestOperationManager.h>) || __has_include("AFHTTPRequestOperationManager.h")
#else
#endif

@interface AFHTTPRequestCall ()

@property (nonatomic, strong) ServiceMethod *serviceMethod;
#if __has_include(<AFNetworking/AFHTTPRequestOperationManager.h>) || __has_include("AFHTTPRequestOperationManager.h")
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;
#else
@property (nonatomic, strong) NSURLSessionDataTask *requestOperation;
#endif

@property (nonatomic, weak) id<Callback> callBack;
// call guarded
@property (nonatomic, assign) BOOL canceled;
@property (nonatomic, assign) BOOL executed;

@end

@implementation AFHTTPRequestCall

- (instancetype)initWith:(ServiceMethod *)serviceMethod
{
    self = [super init];
    if (self)
    {
        self.serviceMethod = serviceMethod;
        self.canceled = YES;
        self.executed = NO;
    }
    return self;
}

#pragma mark
#pragma mark Utils

- (void)preForExecute
{
    //判断是否已经运行
    if (self.executed)
    {
        [[NSException exceptionWithName:@"" reason:@"Already executed." userInfo:nil] raise];
    }
    self.executed = YES;
    self.canceled = NO;
}

- (void)dealWithResponse:(NSHTTPURLResponse *)response data:(NSData *)responseData
{
    self.executed = NO;
    self.canceled = NO;

    NSError *error;
    id responseObject = [self.serviceMethod toResponse:response data:responseData error:&error];
    if (error)
    {
        [self dealWithResponse:response error:error];
    }
    else
    {
        if ([self.callBack respondsToSelector:@selector(onResponse:response:)])
        {
            [self.callBack onResponse:self response:responseObject];
        }
    }
}

- (void)dealWithResponse:(NSHTTPURLResponse *)response error:(NSError *)error
{
    self.executed = NO;
    self.canceled = NO;
    if ([self.callBack respondsToSelector:@selector(onFailure:error:)])
    {
        [self.callBack onFailure:self error:error];
    }
}

#pragma mark
#pragma mark Call

- (id)execute
{
    [self preForExecute];

    id responseObject = nil;
    // build Request
    __block NSError *error;
    NSURLRequest *request = [self.serviceMethod toRequest:&error];
    if (!error)
    {
#if __has_include(<AFNetworking/AFHTTPRequestOperationManager.h>) || __has_include("AFHTTPRequestOperationManager.h")
        self.requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [self.requestOperation start];
        [self.requestOperation waitUntilFinished];
        //check error
        if (self.requestOperation.error)
        {
            error = self.requestOperation.error;
        }
        else
        {
            responseObject = [self.serviceMethod toResponse:self.requestOperation.response
                                                       data:self.requestOperation.responseData
                                                      error:&error];
        }
#else
        __weak typeof(self) weakSelf = self;
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        [[[AFHTTPSessionManager manager] dataTaskWithRequest:request
                                              uploadProgress:nil
                                            downloadProgress:nil
                                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable responseError) {
                                               if (responseError)
                                               {
                                                   error = responseError;
                                               }
                                               else
                                               {
                                                   responseObject = [weakSelf.serviceMethod toResponse:(NSHTTPURLResponse *)response
                                                                                                  data:responseObject
                                                                                                 error:&error];
                                               }
                                               dispatch_semaphore_signal(semaphore);
                                           }] resume];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
#endif
    }
    self.executed = NO;
    self.canceled = NO;
    return error ?: responseObject;
}

- (void)enqueue:(__weak id<Callback>)callBack
{
    [self preForExecute];
    self.callBack = callBack;

    // build Request
    __block NSError *error;
#if __has_include(<AFNetworking/AFHTTPRequestOperationManager.h>) || __has_include("AFHTTPRequestOperationManager.h")
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLRequest *request = [self.serviceMethod toRequest:manager error:&error];
    if (!error)
    {
        __strong __typeof(self) strongSelf = self;
        // create operation
        self.requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        if (manager.securityPolicy)
        {
            self.requestOperation.securityPolicy = manager.securityPolicy;
        }
        [self.requestOperation
         setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *_Nonnull operation,
                                         id _Nonnull responseObject) {
             [strongSelf dealWithResponse:operation.response data:operation.responseData];
         }
         failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
             [strongSelf dealWithResponse:operation.response error:error];
         }];
        [manager.operationQueue addOperation:self.requestOperation];
    }
    else
    {
        [self dealWithResponse:nil error:error];
    }
#else
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSURLRequest *request = [self.serviceMethod toRequest:manager error:&error];
    if (!error)
    {
        __strong typeof(self) weakSelf = self;
        [[[AFHTTPSessionManager manager] dataTaskWithRequest:request
                                              uploadProgress:nil
                                            downloadProgress:nil
                                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable responseError) {
                                               if (responseError)
                                               {
                                                   [weakSelf dealWithResponse:(NSHTTPURLResponse *)response error:error];
                                               }
                                               else
                                               {
                                                   [weakSelf dealWithResponse:(NSHTTPURLResponse *)response data:responseObject];
                                               }
                                           }] resume];
    }
    else
    {
        [self dealWithResponse:nil error:error];
    }
#endif
}

- (BOOL)isExecuted
{
    return self.executed;
}

- (void)cancel
{
    [self.requestOperation cancel];
    self.canceled = YES;
    self.executed = NO;
    if ([self.callBack respondsToSelector:@selector(onCanceled:)])
    {
        [self.callBack onCanceled:self];
    }
}

- (BOOL)isCanceled
{
    return self.canceled;
}

@end
