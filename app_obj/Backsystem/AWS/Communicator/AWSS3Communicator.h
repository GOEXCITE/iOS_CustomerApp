//
//  AWSS3Communicator.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AWSClients.h"

@interface AWSS3Communicator : AWSClients

+ (void)downloadDataFromS3WithKey:(NSString *)key completionBlock:(void (^)(NSData *dataBody))completionBlock;
+ (void)uploadDataToS3WithFileName:(NSString *)fileName fileLocation:(NSURL *)fileLocation completionBLock:(void (^)(BOOL finished))completionBlock;
+ (void)removeDataFromS3WithKey:(NSString *)key completionBlock:(void (^)(BOOL finished))completionBlock;

+ (void)getFileListInS3WithFrefixKey:(NSString *)key executor:(AWSExecutor *)executor completionBlock:(void (^)(NSArray *fileList))block;

@end
