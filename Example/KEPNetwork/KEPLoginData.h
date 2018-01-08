//
//  KEPLoginData.h
//  KEPNetwork_Example
//
//  Created by jackrex on 08/01/2018.
//  Copyright © 2018 jackrex1993@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/// Use JSONModel

@interface KEPLoginDataModel : NSObject

@property (nonatomic, copy) NSString *gender;
@property (nonatomic, copy) NSString *token;

@end

@interface KEPLoginModel : NSObject

@property (nonatomic, assign) BOOL ok;
@property (nonatomic, strong) KEPLoginDataModel *data;
@property (nonatomic, strong) NSString *now;

@end
