//
//  KEPViewController.m
//  KEPNetwork
//
//  Created by jackrex1993@gmail.com on 01/01/2018.
//  Copyright (c) 2018 jackrex1993@gmail.com. All rights reserved.
//

#import "KEPViewController.h"
#import "KEPPostRequest.h"
#import <KEPNetwork/KEPRequest.h>

@interface KEPViewController ()

@end

@implementation KEPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    KEPPostRequest *postRequest = [[KEPPostRequest alloc] initWithParams:@"1123581321"];
    [postRequest startWithBlock:^(__kindof KEPRequest * _Nonnull request) {
        NSLog(@"%@", request);

    } failure:^(__kindof KEPRequest * _Nonnull request) {
        NSLog(@"%@", request);

    }];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)normalpost:(id)sender {
    KEPRequest *request = [[KEPRequest alloc] init];
    request.requestMethod = KEPRequestMethodPOST;
    request.requestUrl = @"/account/v2/login";
    request.requestArgument =  @{
                                 @"password": @"1123581321",
                                 @"countryCode": @"86",
                                 @"mobile":@"13264589486",
                                 @"countryName":@"CHN"
                                 };
    
    [request startWithBlock:^(__kindof KEPRequest * _Nonnull request) {
        NSLog(@"%@", request);
        
    } failure:^(__kindof KEPRequest * _Nonnull request) {
        NSLog(@"%@", request);
        
    }];
    
}

- (IBAction)simpleGet:(id)sender {
    
    
}

- (IBAction)postData:(id)sender {
    
    
}

@end
