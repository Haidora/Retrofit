//
//  AFHTTPRequestCall.h
//  Retrofit
//
//  Created by Dailingchi on 16/6/16.
//  Copyright © 2016年 mrdaios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Call.h"
@class ServiceMethod;

@interface AFHTTPRequestCall : Call

- (instancetype)initWith:(ServiceMethod *)serviceMethod;

@end
