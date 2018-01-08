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
    KEPRequestSerializerTypePlainText = 0,
    KEPRequestSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, KEPResponseSerializerType) {
    KEPResponseSerializerTypePlainText,
    KEPResponseSerializerTypeJSON,
};

typedef NS_ENUM(NSInteger, KEPApiHostType) {
    KEPApi,
    KEPStore,
    KEPAnaly
};

extern NSString *const KEPApiHost;
extern NSString *const KEPStoreHost;
extern NSString *const KEPAnalyHost;

typedef void(^KEPRequestBlock)(__kindof KEPRequest *request);
typedef void (^AFConstructingBlock)(id<AFMultipartFormData> formData);

@interface KEPRequest : NSObject

@property (nonatomic, strong) NSURLSessionTask *requestTask;

@property (nonatomic, strong) NSURLRequest *currentRequest;

@property (nonatomic, strong) NSHTTPURLResponse *response;

@property (nonatomic) NSInteger responseStatusCode;

@property (nonatomic, strong, nullable) NSDictionary *responseHeaders;

@property (nonatomic, strong, nullable) NSData *responseData;

@property (nonatomic, strong, nullable) NSString *responseString;

@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) KEPRequestMethod requestMethod;

@property (nonatomic, strong) NSString *requestUrl;

@property (nonatomic, strong) NSURLRequest *customUrlRequest;

@property (nonatomic, assign) NSTimeInterval requestTimeoutInterval;

@property (nonatomic, assign) KEPApiHostType apiType;

@property (nonatomic, assign) BOOL allowsCellularAccess;

@property (nonatomic, strong) id jsonValidator;

@property (nonatomic, strong) id requestArgument;

@property (nonatomic, strong) NSDictionary<NSString *, NSString *> *requestHeaderFieldValueDictionary;

@property (nonatomic, assign) KEPRequestSerializerType requestSerializerType;

@property (nonatomic, assign) KEPResponseSerializerType responseSerializerType;

@property (nonatomic, copy, nullable) KEPRequestBlock successBlock;

@property (nonatomic, copy, nullable) KEPRequestBlock failureBlock;

@property (nonatomic, copy, nullable) AFConstructingBlock constructingBodyBlock;

@property (nonatomic, strong, nullable) id responseObject;

@property (nonatomic, strong, nullable) id responseJSONObject;

@property (nonatomic, readonly, getter=isCancelled) BOOL cancelled;

@property (nonatomic, readonly, getter=isExecuting) BOOL executing;

- (nullable id)requestArgument;

- (void)startWithBlock:(nullable KEPRequestBlock)success
                                    failure:(nullable KEPRequestBlock)failure;

///// default add API path you can use apiType to change, full path will NOT add API Domain
//- (NSString *)requestUrl;
//
//- (NSURLRequest *)customUrlRequest;
//
//- (NSTimeInterval)requestTimeoutInterval;
//
//- (KEPRequestMethod)requestMethod;
//
//- (KEPRequestSerializerType)requestSerializerType;
//
//- (KEPApiHostType)apiType;
//
//- (KEPResponseSerializerType)responseSerializerType;
//
//- (nullable NSDictionary<NSString *, NSString *> *)requestHeaderFieldValueDictionary;
//
//- (BOOL)allowsCellularAccess;
//
//- (nullable id)jsonValidator;

@end

/// Use This Request for Keep Store
@interface KEPStoreRequest : KEPRequest

@end

/// Use This Request for Keep Analy
@interface KEPAnalyRequest : KEPRequest

@end


NS_ASSUME_NONNULL_END
