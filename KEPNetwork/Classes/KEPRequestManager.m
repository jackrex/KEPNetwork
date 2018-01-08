//
//  KEPRequestManager.m
//  Expecta
//
//  Created by jackrex on 1/1/2018.
//

#import "KEPRequestManager.h"
#import "KEPRequest.h"
#import <pthread/pthread.h>
#import <AFNetworking/AFNetworking.h>


NSString *const KEPRequestValidationErrorDomain = @"com.gotokeep.keep.validation";


#define Lock() pthread_mutex_lock(&_lock)
#define Unlock() pthread_mutex_unlock(&_lock)

@interface KEPRequestManager()

@property (nonatomic, strong) AFHTTPSessionManager *manager;
@property (nonatomic, strong) AFJSONResponseSerializer *responseSerializer;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, KEPRequest *> *requestsRecord;

@end

@implementation KEPRequestManager {
    pthread_mutex_t _lock;

}

#pragma mark - Init

+ (KEPRequestManager *)sharedInstance {
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);

        self.requestsRecord = [NSMutableDictionary dictionary];
        
        self.responseSerializer = [AFJSONResponseSerializer serializer];
        self.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];
        
        self.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        ((AFJSONResponseSerializer *)self.manager.responseSerializer).removesKeysWithNullValues = YES;
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(100, 500)];

    }
    return self;
}

#pragma mark - Operation Request

- (void)addRequest:(KEPRequest *)request {
    NSParameterAssert(request != nil);
    
    NSError * __autoreleasing requestSerializationError = nil;
    NSURLRequest *customUrlRequest= [request customUrlRequest];
    if (customUrlRequest) {
        __block NSURLSessionDataTask *dataTask = nil;
        dataTask = [self.manager dataTaskWithRequest:customUrlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
            [self handleRequestResult:dataTask responseObject:responseObject error:error];
        }];
        request.requestTask = dataTask;
    } else {
        request.requestTask = [self sessionTaskForRequest:request error:&requestSerializationError];
    }
    
    if (requestSerializationError) {
        [self requestDidFailWithRequest:request error:requestSerializationError];
        return;
    }
    
    NSAssert(request.requestTask != nil, @"requestTask should not be nil");
    [self addRequestToRecord:request];
    [request.requestTask resume];
    
}

- (void)cancelRequest:(KEPRequest *)request {
    NSParameterAssert(request != nil);
    [request.requestTask cancel];
    [self removeRequestFromRecord:request];
    
}

- (void)addRequestToRecord:(KEPRequest *)request {
    Lock();
    self.requestsRecord[@(request.requestTask.taskIdentifier)] = request;
    Unlock();
}

- (void)removeRequestFromRecord:(KEPRequest *)request {
    Lock();
    [self.requestsRecord removeObjectForKey:@(request.requestTask.taskIdentifier)];
    Unlock();
}

- (NSString *)constructRequestUrl:(KEPRequest *)request {
    NSParameterAssert(request != nil);
    NSString *detailUrl = [request requestUrl];
    NSURL *requestURL = [NSURL URLWithString:detailUrl];
    if (!requestURL.host) {
        switch (request.apiType) {
            case KEPApi:
                requestURL = [NSURL URLWithString:[KEPApiHost stringByAppendingString:detailUrl]];
                break;
            case KEPAnaly:
                requestURL = [NSURL URLWithString:[KEPAnalyHost stringByAppendingString:detailUrl]];
                
                break;
                
            case KEPStore:
                requestURL = [NSURL URLWithString:[KEPStoreHost stringByAppendingString:detailUrl]];
                break;
                
            default:
                break;
        }
    }
    return requestURL.absoluteString;
}

#pragma mark - Handle Request

- (void)handleRequestResult:(NSURLSessionTask *)task responseObject:(id)responseObject error:(NSError *)error {
    Lock();
    KEPRequest *request = self.requestsRecord[@(task.taskIdentifier)];
    Unlock();
    
    if (!request) {
        return;
    }
    
    NSError * __autoreleasing serializationError = nil;
    NSError * __autoreleasing validationError = nil;
    
    NSError *requestError = nil;
    BOOL succeed = NO;
    
    request.responseObject = responseObject;
    if ([request.responseObject isKindOfClass:[NSData class]]) {
        request.responseData = responseObject;
        request.responseString = [[NSString alloc] initWithData:responseObject encoding:[self stringEncodingWithRequest:request]];
        
        switch (request.responseSerializerType) {
            case KEPResponseSerializerTypePlainText:
                // Default serializer. Do nothing.
                break;
            case KEPResponseSerializerTypeJSON:
                request.responseObject = [self.responseSerializer responseObjectForResponse:task.response data:request.responseData error:&serializationError];
                request.responseJSONObject = request.responseObject;
                break;
        }
    }
    if (error) {
        succeed = NO;
        requestError = error;
    } else if (serializationError) {
        succeed = NO;
        requestError = serializationError;
    } else {
        succeed = [self validateResult:request error:&validationError];
        requestError = validationError;
    }
    
    if (succeed) {
        [self requestDidSucceedWithRequest:request];
    } else {
        [self requestDidFailWithRequest:request error:requestError];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self removeRequestFromRecord:request];
    });
}

- (void)requestDidSucceedWithRequest:(KEPRequest *)request {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (request.successBlock) {
            request.successBlock(request);
        }
    });
}

- (void)requestDidFailWithRequest:(KEPRequest *)request error:(NSError *)error {
    request.error = error;
    dispatch_async(dispatch_get_main_queue(), ^{
        //Add more logic such as delegate callback etc
        if (request.failureBlock) {
            request.failureBlock(request);
        }
    });
}

- (BOOL)validateResult:(KEPRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    BOOL result = [request responseStatusCode] >= 200 && [request responseStatusCode] <= 299;
    if (!result) {
        if (error) {
            *error = [NSError errorWithDomain:KEPRequestValidationErrorDomain code:KEPRequestValidationErrorInvalidStatusCode userInfo:@{NSLocalizedDescriptionKey:@"Invalid status code"}];
        }
        return result;
    }
    id json = [request responseJSONObject];
    id validator = [request jsonValidator];
    if (json && validator) {
        result = [self validateJSON:json withValidator:validator];
        if (!result) {
            if (error) {
                *error = [NSError errorWithDomain:KEPRequestValidationErrorDomain code:KEPRequestValidationErrorInvalidJSONFormat userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON format"}];
            }
            return result;
        }
    }
    return YES;
}

- (BOOL)validateJSON:(id)json withValidator:(id)jsonValidator {
    if ([json isKindOfClass:[NSDictionary class]] &&
        [jsonValidator isKindOfClass:[NSDictionary class]]) {
        NSDictionary * dict = json;
        NSDictionary * validator = jsonValidator;
        BOOL result = YES;
        NSEnumerator * enumerator = [validator keyEnumerator];
        NSString * key;
        while ((key = [enumerator nextObject]) != nil) {
            id value = dict[key];
            id format = validator[key];
            if ([value isKindOfClass:[NSDictionary class]]
                || [value isKindOfClass:[NSArray class]]) {
                result = [self validateJSON:value withValidator:format];
                if (!result) {
                    break;
                }
            } else {
                if ([value isKindOfClass:format] == NO &&
                    [value isKindOfClass:[NSNull class]] == NO) {
                    result = NO;
                    break;
                }
            }
        }
        return result;
    } else if ([json isKindOfClass:[NSArray class]] &&
               [jsonValidator isKindOfClass:[NSArray class]]) {
        NSArray * validatorArray = (NSArray *)jsonValidator;
        if (validatorArray.count > 0) {
            NSArray * array = json;
            NSDictionary * validator = jsonValidator[0];
            for (id item in array) {
                BOOL result = [self validateJSON:item withValidator:validator];
                if (!result) {
                    return NO;
                }
            }
        }
        return YES;
    } else if ([json isKindOfClass:jsonValidator]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSStringEncoding)stringEncodingWithRequest:(KEPRequest *)request {
    NSStringEncoding stringEncoding = NSUTF8StringEncoding;
    if (request.response.textEncodingName) {
        CFStringEncoding encoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)request.response.textEncodingName);
        if (encoding != kCFStringEncodingInvalidId) {
            stringEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
        }
    }
    return stringEncoding;
}

#pragma mark - Http Request

- (NSURLSessionTask *)sessionTaskForRequest:(KEPRequest *)request error:(NSError * _Nullable __autoreleasing *)error {
    KEPRequestMethod method = [request requestMethod];
    NSString *url = [self constructRequestUrl:request];
    id param = request.requestArgument;
    AFHTTPRequestSerializer *requestSerializer = [self requestSerializerForRequest:request];
    AFConstructingBlock constructingBlock = [request constructingBodyBlock];
    
    switch (method) {
        case KEPRequestMethodGET:
            return [self dataTaskWithHTTPMethod:@"GET" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case KEPRequestMethodPOST:
            return [self dataTaskWithHTTPMethod:@"POST" requestSerializer:requestSerializer URLString:url parameters:param constructingBodyWithBlock:constructingBlock error:error];
        case KEPRequestMethodHEAD:
            return [self dataTaskWithHTTPMethod:@"HEAD" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case KEPRequestMethodPUT:
            return [self dataTaskWithHTTPMethod:@"PUT" requestSerializer:requestSerializer URLString:url parameters:param error:error];
        case KEPRequestMethodDELETE:
            return [self dataTaskWithHTTPMethod:@"DELETE" requestSerializer:requestSerializer URLString:url parameters:param error:error];
    }
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                                           error:(NSError * _Nullable __autoreleasing *)error {
    return [self dataTaskWithHTTPMethod:method requestSerializer:requestSerializer URLString:URLString parameters:parameters constructingBodyWithBlock:nil error:error];
}

- (NSURLSessionDataTask *)dataTaskWithHTTPMethod:(NSString *)method
                               requestSerializer:(AFHTTPRequestSerializer *)requestSerializer
                                       URLString:(NSString *)URLString
                                      parameters:(id)parameters
                       constructingBodyWithBlock:(nullable void (^)(id <AFMultipartFormData> formData))block
                                           error:(NSError * _Nullable __autoreleasing *)error {
    NSMutableURLRequest *request = nil;
    
    if (block && block != NULL) {
        request = [requestSerializer multipartFormRequestWithMethod:method URLString:URLString parameters:parameters constructingBodyWithBlock:block error:error];
    } else {
        request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:error];
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self.manager dataTaskWithRequest:request
                           completionHandler:^(NSURLResponse * __unused response, id responseObject, NSError *_error) {
                               [self handleRequestResult:dataTask responseObject:responseObject error:_error];
                           }];
    
    return dataTask;
}

- (AFHTTPRequestSerializer *)requestSerializerForRequest:(KEPRequest *)request {
    AFHTTPRequestSerializer *requestSerializer = nil;
    if (request.requestSerializerType == KEPRequestSerializerTypePlainText) {
        requestSerializer = [AFHTTPRequestSerializer serializer];
    } else if (request.requestSerializerType == KEPRequestSerializerTypeJSON) {
        requestSerializer = [AFJSONRequestSerializer serializer];
    }
    
    requestSerializer.timeoutInterval = [request requestTimeoutInterval];
    requestSerializer.allowsCellularAccess = [request allowsCellularAccess];
    
    //fill uniform header
    
    [self fillHeader:requestSerializer];
    // add custom value to HTTPHeaderField
    NSDictionary<NSString *, NSString *> *headerFieldValueDictionary = [request requestHeaderFieldValueDictionary];
    if (headerFieldValueDictionary != nil) {
        for (NSString *httpHeaderField in headerFieldValueDictionary.allKeys) {
            NSString *value = headerFieldValueDictionary[httpHeaderField];
            [requestSerializer setValue:value forHTTPHeaderField:httpHeaderField];
        }
    }
    return requestSerializer;
}

- (void)fillHeader:(id)obj {
    NSTimeZone *zone = [NSTimeZone defaultTimeZone];
    if (zone.name) {
        [obj setValue:zone.name forHTTPHeaderField:@"x-keep-timezone"];
    }
//    [obj setValue:[KUtils deviceId] forHTTPHeaderField:@"x-device-id"];
//    [obj setValue:[@([KUtils currentSecondTimestamp]) stringValue] forHTTPHeaderField:@"x-timestamp"];
//    [obj setValue:[self generateNewDeviceTag] forHTTPHeaderField:@"x-is-new-device"];
//    [obj setValue:[@([KUtils currentSecondTimestamp]) stringValue] forHTTPHeaderField:@"x-timestamp"];
//    [obj setValue:[self headerVersionNum] forHTTPHeaderField:@"x-version-name"];
//    [obj setValue:[self headerBuildNum] forHTTPHeaderField:@"x-version-code"];
//    [obj setValue:@"Apple Store" forHTTPHeaderField:@"x-channel"];
//    [obj setValue:@"Apple" forHTTPHeaderField:@"x-manufacturer"];
//    [obj setValue:[KUtils deviceName] forHTTPHeaderField:@"x-model"];
//    [obj setValue:[KUtils deviceModel] forHTTPHeaderField:@"x-model-raw"];
//    [obj setValue:[KUtils currentLanguage] forHTTPHeaderField:@"x-locale"];
//    [obj setValue:@"iOS" forHTTPHeaderField:@"x-os"];
//    [obj setValue:[[UIDevice currentDevice] systemVersion] forHTTPHeaderField:@"x-os-version"];
//    [obj setValue:[NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.width] forHTTPHeaderField:@"x-screen-width"];
//    [obj setValue:[NSString stringWithFormat:@"%.0f", [[UIScreen mainScreen] bounds].size.height] forHTTPHeaderField:@"x-screen-height"];
//    [obj setValue:[KUtils appBundleIdentifier] forHTTPHeaderField:@"x-bundleId"];
//    if (self.headerExpandArray && self.headerExpandArray.count) {
//        [self.headerExpandArray enumerateObjectsUsingBlock:^(HTTPHeaderExpandBlock  _Nonnull expandBlock, NSUInteger idx, BOOL * _Nonnull stop) {
//            NSDictionary * expandParams = expandBlock();
//            if (expandParams && expandParams.count) {
//                [expandParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull object, BOOL * _Nonnull stop) {
//#if DEBUG
//                    NSAssert(![obj valueForHTTPHeaderField:key], @"你使用了默认通用Header的Key作为你的Key");
//#endif
//                    [obj setValue:object forHTTPHeaderField:key];
//                }];
//            }
//        }];
//    }
}


@end

