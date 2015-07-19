//
//  CMUser.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOMAIN_USER     @"CM_User"

typedef NS_ENUM(NSUInteger, CMUserType){
    CMUserTypeUnregister = 0,
    CMUserTypeAdmin = 1,
    CMUserTypeNormal = 2,
};

@interface CMUser : NSObject

@property (nonatomic, strong) NSString      *userId;
@property (nonatomic, strong) NSString      *userName;
@property (nonatomic, strong) NSString      *password;
@property (nonatomic, strong) NSString      *initialPW;
@property (nonatomic, assign) CMUserType    userType;

@end
