//
//  KEPPostRequest.m
//  KEPNetwork_Example
//
//  Created by jackrex on 07/01/2018.
//  Copyright © 2018 jackrex1993@gmail.com. All rights reserved.
//

#import "KEPPostRequest.h"

@implementation KEPPostRequest {
    NSString *_param1;
}

- (instancetype)initWithParams:(NSString *)param1 {
    self = [super init];
    if (self) {
        _param1 = param1;
    }
    return self;
}

- (NSString *)requestUrl {
    return @"/account/v2/login";
}

- (KEPRequestMethod)requestMethod {
    return KEPRequestMethodPOST;
}

- (id)requestArgument {
    return @{
             @"password": _param1,
             @"countryCode": @"86",
             @"mobile":@"13264589486",
             @"countryName":@"CHN"
             };
}

- (id)jsonValidator {
    return @{
             @"errorCode": [NSString class],
             @"now": [NSString class],
             @"data": @{
                     @"gender": [NSString class],
                     @"level": [NSNumber class],
                     @"token": [NSString class],
                     }
             };
// //error
//    return @{
//             @"errorCode": [NSNumber class],
//             @"now": [NSString class],
//             @"data": [NSNumber class]
//             };
}



@end
