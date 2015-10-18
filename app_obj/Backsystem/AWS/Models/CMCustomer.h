//
//  CMCustomer.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOMAIN_CUSTOMER     @"CM_Customer"

@class AWSExecutor;

@interface CMCustomer : NSObject
@property (nonatomic ,strong) NSString  *customerId;
@property (nonatomic ,strong) NSString  *customerName;
@property (nonatomic ,strong) NSString  *pinYin;
@property (nonatomic ,strong) NSString  *gender;
@property (nonatomic ,strong) NSString  *birth;
@property (nonatomic ,strong) NSString  *age;
@property (nonatomic ,strong) NSString  *passportId;
@property (nonatomic ,strong) NSString  *passportIussedPlace;
@property (nonatomic ,strong) NSString  *passportValidDate;
@property (nonatomic ,strong) NSString  *location;
@property (nonatomic ,strong) NSString  *phoneNumber;
@property (nonatomic ,strong) NSString  *mail;

@property (nonatomic ,strong) NSString  *wechatID;
@property (nonatomic ,strong) NSString  *history;
@property (nonatomic ,strong) NSString  *remark;

- (void)saveWithExecutor:(AWSExecutor *)executor CompletionBlock:(void (^)(BOOL success))block;

@end
