//
//  Brain.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "Brain.h"
#import "CMCSVParser.h"
#import "VDOwner.h"
#import "VDCustomerList.h"

static VDOwner *owner               = nil;
static VDCustomerList *customerList = nil;

@implementation NSObject (BrainExtension)

- (void)cm_SaveUserType:(CMUserType)userType{
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:userType] forKey:KEY_USER_TYPE];
}

- (CMUserType)cm_userType{
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:KEY_USER_TYPE];
    return num!=nil ? (CMUserType)num.integerValue : CMUserTypeUnregister;
}

//! @var basic variables

- (VDOwner *)owner{
    if (owner == nil) {
        static dispatch_once_t onceToken;
        dispatch_once (&onceToken, ^{
            owner = [[VDOwner alloc] init];
        });
    }
    return owner;
}

- (VDCustomerList *)customerList{
    if (customerList == nil) {
        static dispatch_once_t onceToken;
        dispatch_once (&onceToken, ^{
            customerList = [[VDCustomerList alloc] init];
        });
    }
    return customerList;
}

//! @function

- (void)cm_saveCSVToSDB:(NSURL *)url withCompletionBlock:(void (^)(BOOL successed))block{
    CMCSVParser *p = [CMCSVParser cm_withFileAtURL:url];
    [p tryParsewithCompletionBlock:^(NSError *error, NSArray *result){
        if (error!=nil) {
            NSLog(@"parse file failed : %@",error);
        }else{
            __block NSInteger   count = 0;
            for (CMCustomer *aCus in result) {
                aCus.customerId = [NSString stringWithFormat:@"%lu",(unsigned long)[result indexOfObject:aCus]];
                [aCus saveWithExecutor:[AWSExecutor defaultExecutor] CompletionBlock:^(BOOL successed){
                    if (!successed) {
                        NSLog(@"Failed to save customer data to SDB : %@",aCus.customerId);
                        if (block!=nil) {
                            block(NO);
                        }
                    }else{
                        count++;
                        if (count==result.count) {
                            block(YES);
                        }
                    }
                }];
            }
            
        }
    }];
}

@end
