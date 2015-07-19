//
//  VDOwner.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CMUser.h"

@interface VDOwner : CMUser

+ (instancetype)alive;

- (void)tryToLoginWithUserId:(NSString *)userId password:(NSString *)password completionBlock:(void (^)(NSString *failedMsg))block;

- (void)loginWithInitialPassword:(NSString *)initPW completionBlock:(void(^)(NSString *errorMSG))block;

@end
