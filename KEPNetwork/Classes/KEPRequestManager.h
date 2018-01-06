//
//  KEPRequestManager.h
//  Expecta
//
//  Created by jackrex on 1/1/2018.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const KEPRequestValidationErrorDomain;

NS_ENUM(NSInteger) {
    KEPRequestValidationErrorInvalidStatusCode = -8,
    KEPRequestValidationErrorInvalidJSONFormat = -9,
};
    
@class KEPRequest;

@interface KEPRequestManager : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

+ (KEPRequestManager *)sharedInstance;

- (void)addRequest:(KEPRequest *)request;
- (void)cancelRequest:(KEPRequest *)request;
- (NSString *)constructRequestUrl:(KEPRequest *)request;


@end
