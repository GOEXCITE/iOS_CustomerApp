//
//  Brain.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AWSSDBCommunicator.h"
#import "AWSS3Communicator.h"
#import "VDOwner.h"
#import "VDCustomerList.h"
#import "CMCSV.h"

#define KEY_USER_TYPE   @"UserTypeKey"

@interface NSObject (BrainExtension)

- (void)cm_SaveUserType:(CMUserType)userType;
- (CMUserType)cm_userType;

- (void)cm_saveCSVToSDB:(NSURL *)url withCompletionBlock:(void (^)(BOOL successed))block;

@end
