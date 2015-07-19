//
//  VDOwner.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "VDOwner.h"

#import "AWSSDBCommunicator.h"

@implementation VDOwner

+ (instancetype)alive{
    static VDOwner *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedClass = [[self alloc]init];
    });
    return sharedClass;
}

- (void)tryToLoginWithUserId:(NSString *)userId password:(NSString *)password completionBlock:(void (^)(NSString *failedMsg))block{
    NSString *condition = [NSString stringWithFormat:@"itemName() = '%@'",userId];
    [AWSSDBCommunicator getItemListFromSDBWithDomainName:DOMAIN_USER condition:condition mainThreadExecutor:YES completionBlock:^(NSArray *result){
        if (result.count == 1) {
            AWSSimpleDBItem *tUser = [result firstObject];
            if (![password isEqualToString:[AWSSDBCommunicator getValueForAttribute:@"password" fromList:tUser.attributes]]) {
                if (block != nil) {
                    block(@"用户名或者密码错误！");
                }
            }else{
                self.userId = userId;
                self.password = password;
                self.userName = [AWSSDBCommunicator getValueForAttribute:@"userName" fromList:tUser.attributes];
                self.userType = [AWSSDBCommunicator getValueForAttribute:@"userType" fromList:tUser.attributes].integerValue;
                if (block!=nil) {
                    block(nil);
                }
            }
        }else{
            if (block !=nil) {
                block(@"用户名不存在！");
            }
        }
    }];
}

- (void)loginWithInitialPassword:(NSString *)initPW completionBlock:(void(^)(NSString *errorMSG))block{
    NSString *condition = [NSString stringWithFormat:@"initialPW = '%@'",initPW];
    [AWSSDBCommunicator getItemListFromSDBWithDomainName:DOMAIN_USER condition:condition mainThreadExecutor:YES completionBlock:^(NSArray *result){
        if (result.count == 1) {
            AWSSimpleDBItem *tUser = [result firstObject];
            if (![initPW isEqualToString:[AWSSDBCommunicator getValueForAttribute:@"initialPW" fromList:tUser.attributes]]) {
                if (block != nil) {
                    block(@"用户名或者密码错误！");
                }
            }else{
                self.userId = tUser.name;
                self.userName = [AWSSDBCommunicator getValueForAttribute:@"userName" fromList:tUser.attributes];
                self.userType = [AWSSDBCommunicator getValueForAttribute:@"userType" fromList:tUser.attributes].integerValue;
                if (block!=nil) {
                    block(nil);
                }
            }
        }else if(result.count == 0){
            if (block !=nil) {
                block(@"用户名不存在！");
            }
        }else{
            if (block != nil) {
                block(@"系统错误！请联系管理员！");
            }
        }
    }];
}

@end
