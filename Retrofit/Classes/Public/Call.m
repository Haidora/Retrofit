//
//  Call.m
//  Retrofit
//
//  Created by Dailingchi on 16/4/15.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import "Call.h"
#import <objc/runtime.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincompatible-pointer-types"
#pragma clang diagnostic ignored "-Wincomplete-implementation"
#pragma clang diagnostic ignored "-Wprotocol"

@implementation Call

@end

#pragma clang diagnostic pop

@interface Call (BlockSupportPrivate) <Callback>

@property (nonatomic, copy) void (^onResponse)(Call *call, id response);
@property (nonatomic, copy) void (^onFailure)(Call *call, NSError *error);
@property (nonatomic, copy) void (^onCancel)(Call *call);
@property (nonatomic, copy) void (^onFnish)(Call *call);

@end

@implementation Call (BlockSupportPrivate)

- (void)onResponse:(Call *)call response:(id)response
{
    if (self.onResponse)
    {
        self.onResponse(call, response);
    }
    if (self.onFnish)
    {
        self.onFnish(call);
    }
    [self cleanCallBack];
}

- (void)onFailure:(Call *)call error:(NSError *)error
{
    if (self.onFailure)
    {
        self.onFailure(call, error);
    }
    if (self.onFnish)
    {
        self.onFnish(call);
    }
    [self cleanCallBack];
}

- (void)onCanceled:(Call *)call
{
    if (self.onCancel)
    {
        self.onCancel(call);
    }
    [self cleanCallBack];
}

- (void)cleanCallBack
{
    self.onResponse = nil;
    self.onFailure = nil;
    self.onCancel = nil;
    self.onFnish = nil;
}

#pragma mark
#pragma mark Getter / Setter

- (void)setOnResponse:(void (^)(Call *, id))onResponse
{
    objc_setAssociatedObject(self, @selector(setOnResponse:), onResponse,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(Call *, id))onResponse
{
    return objc_getAssociatedObject(self, @selector(setOnResponse:));
}

- (void)setOnFailure:(void (^)(Call *, NSError *))onFailure
{
    objc_setAssociatedObject(self, @selector(setOnFailure:), onFailure,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(Call *, NSError *))onFailure
{
    return objc_getAssociatedObject(self, @selector(setOnFailure:));
}

- (void)setOnCancel:(void (^)(Call *))onCancel
{
    objc_setAssociatedObject(self, @selector(setOnCancel:), onCancel,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(Call *))onCancel
{
    return objc_getAssociatedObject(self, @selector(setOnCancel:));
}

- (void)setOnFnish:(void (^)(Call *))onFnish
{
    objc_setAssociatedObject(self, @selector(setOnFnish:), onFnish,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void (^)(Call *))onFnish
{
    return objc_getAssociatedObject(self, @selector(setOnFnish:));
}

@end

@implementation Call (BlockSupport)

- (void)enqueueWith:(void (^)(Call *call, id response))response
            failure:(void (^)(Call *call, NSError *error))failure

{
    [self enqueueWith:response failure:failure cancel:nil finish:nil];
}

- (void)enqueueWith:(void (^)(Call *call, id response))response
            failure:(void (^)(Call *call, NSError *error))failure
             cancel:(void (^)(Call *call))cancel
{
    [self enqueueWith:response failure:failure cancel:cancel finish:nil];
}

- (void)enqueueWith:(void (^)(Call *call, id response))response
            failure:(void (^)(Call *call, NSError *error))failure
             finish:(void (^)(Call *call))finish
{
    [self enqueueWith:response failure:failure cancel:nil finish:finish];
}

- (void)enqueueWith:(void (^)(Call *call, id response))response
            failure:(void (^)(Call *call, NSError *error))failure
             cancel:(void (^)(Call *call))cancel
             finish:(void (^)(Call *call))finish
{
    self.onResponse = response;
    self.onFailure = failure;
    self.onCancel = cancel;
    self.onFnish = finish;
    [self enqueue:self];
}

@end