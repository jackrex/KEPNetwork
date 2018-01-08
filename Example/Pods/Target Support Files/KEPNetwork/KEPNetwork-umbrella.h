#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KEPBatchRequestManager.h"
#import "KEPChainRequestManager.h"
#import "KEPNetwork.h"
#import "KEPRequest.h"
#import "KEPRequestManager.h"

FOUNDATION_EXPORT double KEPNetworkVersionNumber;
FOUNDATION_EXPORT const unsigned char KEPNetworkVersionString[];

