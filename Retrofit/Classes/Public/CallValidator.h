//
//  CallValidator.h
//  Pods
//
//  Created by Dailingchi on 16/6/20.
//
//

#import <Foundation/Foundation.h>

/**
 *  用于请求验证
 */
@protocol CallValidator <NSObject>

- (BOOL)validatorResponse:(NSHTTPURLResponse *)response
           responseObject:(id)responseObject
                    error:(NSError **)error;

@end
