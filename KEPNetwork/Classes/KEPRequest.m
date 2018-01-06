//
//  KEPRequest.m
//  Expecta
//
//  Created by jackrex on 1/1/2018.
//

#import "KEPRequest.h"
#import <AFNetworking/AFNetworking.h>

@implementation KEPRequest

- (void)startWithBlock:(KEPRequestBlock)success failure:(KEPRequestBlock)failure {
    self.successBlock = success;
    self.failureBlock = failure;
    
}

- (void)start {
    
}

- (void)stop {
    
}



@end
