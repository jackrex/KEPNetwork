//
//  KEPRequest.h
//  Expecta
//
//  Created by jackrex on 1/1/2018.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFNetworking.h>

NS_ASSUME_NONNULL_BEGIN
@class KEPRequest;

typedef NS_ENUM(NSInteger, KEPRequestMethod){
    KEPRequestMethodGET = 0,
    KEPRequestMethodPOST,
    KEPRequestMethodHEAD,
    KEPRequestMethodDELETE,
    KEPRequestMethodPUT,
};

typedef NS_ENUM(NSInteger, KEPRequestSerializerType) {
    KEPRequestSerializerTypeHTTP = 0,
    KEPRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, KEPResponseSerializerType) {
    KEPResponseSerializerTypeHTTP,
    KEPResponseSerializerTypeJSON,
    KEPResponseSerializerTypeXMLParser,
};

typedef void(^KEPRequestBlock)(__kindof KEPRequest *request);
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@interface KEPRequest : NSObject

@property (nonatomic, strong) NSURLSessionTask *requestTask;

@property (nonatomic, strong) NSHTTPURLResponse *response;

///  The response status code.
@property (nonatomic, readonly) NSInteger responseStatusCode;

///  The response header fields.
@property (nonatomic, strong, nullable) NSDictionary *responseHeaders;

///  The raw data representation of response. Note this value can be nil if request failed.
@property (nonatomic, strong, nullable) NSData *responseData;

@property (nonatomic, strong, nullable) NSString *responseString;

@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, copy, nullable) KEPRequestBlock successBlock;

@property (nonatomic, copy, nullable) KEPRequestBlock failureBlock;

@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

@property (nonatomic, strong, nullable) id responseObject;

@property (nonatomic, strong, nullable) id responseJSONObject;

- (nullable id)requestArgument;

- (void)startWithBlock:(nullable KEPRequestBlock)success
                                    failure:(nullable KEPRequestBlock)failure;
- (NSString *)requestUrl;

- (NSURLRequest *)customUrlRequest;

- (NSTimeInterval)requestTimeoutInterval;

- (KEPRequestMethod)requestMethod;

- (KEPRequestSerializerType)requestSerializerType;

- (KEPResponseSerializerType)responseSerializerType;

- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;

- (BOOL)allowsCellularAccess;

- (nullable id)jsonValidator;

@end

NS_ASSUME_NONNULL_END
