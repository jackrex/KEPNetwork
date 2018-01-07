//
//  KEPRequest.m
//  Expecta
//
//  Created by jackrex on 1/1/2018.
//

#import "KEPRequest.h"
#import "KEPRequestManager.h"
#import <AFNetworking/AFNetworking.h>

@implementation KEPRequest

- (void)startWithBlock:(KEPRequestBlock)success failure:(KEPRequestBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    [self start];
}

- (void)start {
    [[KEPRequestManager sharedInstance] addRequest:self];
}

- (void)stop {
    [[KEPRequestManager sharedInstance] cancelRequest:self];
}


#pragma mark - Method

- (NSString *)requestUrl {
    return @"";
}

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (id)requestArgument {
    return nil;
}

- (KEPRequestSerializerType)requestSerializerType {
    return KEPRequestSerializerTypeHTTP;
}

- (KEPResponseSerializerType)responseSerializerType {
    return KEPResponseSerializerTypeJSON;
}

- (KEPRequestMethod)requestMethod {
    return KEPRequestMethodGET;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (id)jsonValidator {
    return nil;
}

- (NSURLRequest *)customUrlRequest {
    return nil;
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return @{};
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } { method: %@ } { arguments: %@ }", NSStringFromClass([self class]), self, self.currentRequest.URL, self.currentRequest.HTTPMethod, self.requestArgument];
}

@end
