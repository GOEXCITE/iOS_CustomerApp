//
//  AWSClients.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AWSConstant.h"
#import <AWSS3.h>
#import <AWSSimpleDB.h>

@interface AWSClients : NSObject

+ (instancetype)sharedInstance;

- (AWSSimpleDB *)sdb;
- (AWSS3 *)s3;
- (AWSS3TransferManager *)s3Transfer;

@end
