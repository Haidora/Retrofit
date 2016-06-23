//
//  AFHTTPRequestCall.m
//  Retrofit
//
//  Created by Dailingchi on 16/6/16.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import "AFHTTPRequestCall.h"
#import "ServiceMethod.h"
#import <AFNetworking/AFNetworking.h>

@interface AFHTTPRequestCall ()

@property (nonatomic, strong) ServiceMethod *serviceMethod;
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

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

- (void)dealloc
{
    NSLog(@"%@-dealloc", NSStringFromClass([self class]));
}

#pragma mark
#pragma mark Utils

- (AFHTTPRequestOperation *)createHTTPRequestOperation
{
    NSURLRequest *request = [self.serviceMethod toRequest];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    return operation;
}

- (void)buildExecute
{
    //判断是否已经运行
    if (self.executed)
    {
        [[NSException exceptionWithName:@"" reason:@"Already executed." userInfo:nil] raise];
    }
    self.executed = YES;
    self.canceled = NO;

    self.requestOperation = [self createHTTPRequestOperation];
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
    [self buildExecute];

    [self.requestOperation start];
    [self.requestOperation waitUntilFinished];

    self.executed = NO;
    self.canceled = NO;

    NSError *error = nil;
    id responseObject = nil;
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
    return error ?: responseObject;
}

- (void)enqueue:(__weak id<Callback>)callBack
{
    [self buildExecute];

    self.callBack = callBack;
    __strong __typeof(self) strongSelf = self;
    [self.requestOperation
        setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *_Nonnull operation,
                                        id _Nonnull responseObject) {
          [strongSelf dealWithResponse:operation.response data:operation.responseData];
        }
        failure:^(AFHTTPRequestOperation *_Nonnull operation, NSError *_Nonnull error) {
          [strongSelf dealWithResponse:operation.response error:error];
        }];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager.operationQueue addOperation:self.requestOperation];
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
}

- (BOOL)isCanceled
{
    return self.canceled;
}

@end
