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

@property (nonatomic, strong) NSArray<CallValidator> *validators;
@property (nonatomic, strong) NSArray<CallInterceptor> *interceptors;

@end
