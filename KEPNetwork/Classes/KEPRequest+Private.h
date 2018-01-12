//
//  KEPRequest+Private.h
//  AFNetworking
//
//  Created by jackrex on 12/01/2018.
//

#import <KEPNetwork/KEPNetwork.h>

@interface KEPRequest ()

@property (nonatomic) NSInteger responseStatusCode;

@property (nonatomic, strong, nullable) NSDictionary *responseHeaders;

@property (nonatomic, strong, nullable) NSData *responseData;

@property (nonatomic, copy, nullable) NSString *responseString;

@property (nonatomic, strong, nullable) NSError *error;

@property (nonatomic, strong) NSURLSessionTask *requestTask;

@end
