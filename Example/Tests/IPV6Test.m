//
//  IPV6Test.m
//  Retrofit_Tests
//
//  Created by Dailingchi on 2018/8/21.
//  Copyright © 2018年 mrdaios. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <Retrofit/Retrofit.h>
#import <Retrofit/ServicePresentable.h>

@interface IPV6Server: NSObject <ServicePresentable>

@property (nonatomic, assign, readwrite) NSTimeInterval timeoutInterval;

@end

@implementation IPV6Server

- (NSURL *)baseURL
{
    return [NSURL URLWithString:@"http://[2001:db8:1::1]:8080/bmdp/service?debug=true"];
}

@end

@interface IPV6Test : XCTestCase

@end

@implementation IPV6Test

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {

    XCTestExpectation *documentOpenExpectation = [self expectationWithDescription:@"document open"];
 
    
    [[[Retrofit new] create:[IPV6Server new]] enqueueWith:^(Call *call, id response) {
        [documentOpenExpectation fulfill];
    } failure:^(Call *call, NSError *error) {
        [documentOpenExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:100 handler:^(NSError *error) {
    }];
}

@end
