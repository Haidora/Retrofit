//
//  ServicePresentable.h
//  Retrofit
//
//  Created by Dailingchi on 16/6/16.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFHTTPRequestSerializer;
@protocol AFURLRequestSerialization;
@class AFHTTPResponseSerializer;
@protocol AFURLResponseSerialization;

/**
 *  服务配置信息
 */
@protocol ServicePresentable <NSObject>

@optional

/**
 *  根地址
 */
@property (nonatomic, strong, readonly) NSURL *baseURL;
/**
 *  http请求方式
 */
@property (nonatomic, copy, readonly) NSString *httpMethod;
/**
 *  相对地址
 */
@property (nonatomic, copy, readonly) NSString *relativePath;
/**
 *  请求超时时间
 */
@property (nonatomic, assign, readonly) NSTimeInterval timeoutInterval;
/**
 *  请求参数
 */
@property (nonatomic, strong, readonly) id parameters;

#pragma mark
#pragma mark AFNetworking-Serialization
@property (nonatomic, strong, readonly)
    AFHTTPRequestSerializer<AFURLRequestSerialization> *requestSerializer;
@property (nonatomic, strong, readonly)
    AFHTTPResponseSerializer<AFURLResponseSerialization> *responseSerializer;

@end
