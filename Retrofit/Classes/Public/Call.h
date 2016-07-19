//
//  Call.h
//  Retrofit
//
//  Created by Dailingchi on 16/4/15.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Call;
@protocol Callback <NSObject>

@optional
//请求成功
- (void)onResponse:(Call *)call response:(id)response;
//请求失败
- (void)onFailure:(Call *)call error:(NSError *)error;
//请求取消
- (void)onCanceled:(Call *)call;

@end

/**
 *  抽象类
 */
@interface Call <__covariant ObjectType> : NSObject <NSCopying>

//同步请求
- (id)execute;
//异步请求
- (void)enqueue:(__weak id<Callback>)callBack;
//是否正在请求
- (BOOL)isExecuted;
//取消请求
- (void)cancel;
//是否取消了请求
- (BOOL)isCanceled;

@end

@interface Call <__covariant ObjectType> (BlockSupport)

/**
 *  @param response 成功回调
 *  @param failure  失败回调
 */
- (void)enqueueWith:(void (^)(Call *call, ObjectType response))response
            failure:(void (^)(Call *call, NSError *error))failure;

/**
 *  @param response 成功回调
 *  @param failure  失败回调
 *  @param cancel   取消回调
 */
- (void)enqueueWith:(void (^)(Call *call, ObjectType response))response
            failure:(void (^)(Call *call, NSError *error))failure
             cancel:(void (^)(Call *call))cancel;

/**
 *  @param response 成功回调－>finish
 *  @param failure  失败回调->finish
 *  @param finish   完成回调
 */
- (void)enqueueWith:(void (^)(Call *call, ObjectType response))response
            failure:(void (^)(Call *call, NSError *error))failure
             finish:(void (^)(Call *call))finish;

/**
 *  @param response 成功回调－>finish
 *  @param failure  失败回调->finish
 *  @param cancel   取消回调
 *  @param finish   完成回调
 */
- (void)enqueueWith:(void (^)(Call *call, ObjectType response))response
            failure:(void (^)(Call *call, NSError *error))failure
             cancel:(void (^)(Call *call))cancel
             finish:(void (^)(Call *call))finish;

@end
