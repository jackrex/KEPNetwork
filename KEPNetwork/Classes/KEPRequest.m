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

NSString *const KEPApiHost = @"https://api.gotokeep.com";
NSString *const KEPStoreHost = @"https://store.gotokeep.com";
NSString *const KEPAnalyHost = @"https://apm.gotokeep.com";


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

- (NSTimeInterval)requestTimeoutInterval {
    return 60;
}

- (KEPRequestSerializerType)requestSerializerType {
    return KEPRequestSerializerTypePlainText;
}

- (KEPResponseSerializerType)responseSerializerType {
    return KEPResponseSerializerTypeJSON;
}

- (KEPRequestMethod)requestMethod {
    return _requestMethod != KEPRequestMethodGET ? _requestMethod : KEPRequestMethodGET;
}

- (KEPApiHostType)apiType {
    if (_apiType != KEPApi) {
        return _apiType;
    }
    return KEPApi;
}

- (BOOL)allowsCellularAccess {
    return YES;
}

- (NSInteger)responseStatusCode {
    return ((NSHTTPURLResponse *)self.requestTask.response).statusCode;
}

- (NSURLRequest *)currentRequest {
    return self.requestTask.currentRequest;
}

- (BOOL)isCancelled {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateCanceling;
}

- (BOOL)isExecuting {
    if (!self.requestTask) {
        return NO;
    }
    return self.requestTask.state == NSURLSessionTaskStateRunning;
    
}

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    return @{};
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p>{ URL: %@ } \n { method: %@ } \n { arguments: %@ } \n { response: %@ }", NSStringFromClass([self class]), self, self.currentRequest.URL, self.currentRequest.HTTPMethod, self.requestArgument, self.responseObject];
}

@end

@implementation KEPStoreRequest

- (KEPApiHostType)apiType {
    return KEPStore;
}

@end

@implementation KEPAnalyRequest

- (KEPApiHostType)apiType {
    return KEPAnaly;
}

@end

