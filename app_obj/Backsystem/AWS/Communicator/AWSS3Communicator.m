//
//  AWSS3Communicator.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AWSS3Communicator.h"
#import "AWSConstant.h"

@implementation AWSS3Communicator

+ (void)downloadDataFromS3WithKey:(NSString *)key completionBlock:(void (^)(NSData *dataBody))completionBlock{
    //    AWSS3TransferManager *transferMgr = [AWSS3TransferManager defaultS3TransferManager];
    AWSS3TransferManagerDownloadRequest *downReq = [AWSS3TransferManagerDownloadRequest new];
    downReq.key = key;
    downReq.bucket = S3_BUCKET_NAME;
    
    //    __block int downloadCount = 0;
    [[[[AWSS3Communicator sharedInstance] s3Transfer] download:downReq] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
        if (task.error != nil){
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
        } else {
            //            downloadCount++;
            AWSS3TransferManagerDownloadOutput *result = task.result;
            NSData *bodyData = [NSData dataWithContentsOfURL:result.body];
            if (bodyData && bodyData.length>0 && completionBlock!=nil) {
                completionBlock(bodyData);
            }
            
            return task;
        }
        return nil;
    }];
}

+ (void)uploadDataToS3WithFileName:(NSString *)fileName fileLocation:(NSURL *)fileLocation completionBLock:(void (^)(BOOL finished))completionBlock{
    [self removeDataFromS3WithKey:fileName completionBlock:^(BOOL finished){
        if (finished) {
            AWSS3TransferManagerUploadRequest *req = [AWSS3TransferManagerUploadRequest new];
            req.body = fileLocation;
            req.bucket = S3_BUCKET_NAME;
            req.key = fileName;
            
            [[[[AWSS3Communicator sharedInstance] s3Transfer] upload:req] continueWithExecutor:[AWSExecutor defaultExecutor] withSuccessBlock:^id(AWSTask *task){
                if (task.error != nil) {
                    if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                        NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                    }
                }else{
                    NSLog(@"File uploaded to s3!");
                    if (completionBlock != nil) {
                        completionBlock(YES);
                    }
                }
                return task;
            }];
        }
    }];
}

+ (void)removeDataFromS3WithKey:(NSString *)key completionBlock:(void (^)(BOOL finished))completionBlock{
    AWSS3DeleteObjectRequest *req = [[AWSS3DeleteObjectRequest alloc] init];
    req.bucket = S3_BUCKET_NAME;
    req.key = key;
    [[[[AWSS3Communicator sharedInstance] s3] deleteObject:req] continueWithSuccessBlock:^id(AWSTask *task){
        if (task.error != nil) {
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
            if (completionBlock!=nil) {
                completionBlock(NO);
            }
        }else{
            AWSS3DeleteObjectOutput *result = task.result;
            if (result.deleteMarker.boolValue) {
                NSLog(@"File deleted from s3 (version ID: %@)",result.versionId);
            }
            if (completionBlock) {
                completionBlock(YES);
            }
        }
        return nil;
    }];
}

+ (void)getFileListInS3WithFrefixKey:(NSString *)key executor:(AWSExecutor *)executor completionBlock:(void (^)(NSArray *fileList))block{
    AWSS3ListObjectsRequest *req = [[AWSS3ListObjectsRequest alloc] init];
    req.bucket = [NSString stringWithFormat:@"%@",S3_BUCKET_NAME];
    req.prefix = key;
    [[[AWSS3Communicator sharedInstance].s3 listObjects:req] continueWithExecutor:executor withBlock:^id(AWSTask *task){
        if (task.error !=nil) {
            NSLog(@"ERROR : %@",task.error);
            if (block != nil) {
                block(nil);
            }
            return nil;
        }else{
            AWSS3ListObjectsOutput *result = task.result;
//            NSLog(@"%@",result.contents);
            NSMutableArray *files = [NSMutableArray array];
            for (AWSS3Object *anItem in result.contents) {
                NSString *covertItem = [anItem.key stringByReplacingOccurrencesOfString:key withString:@""];
                if (covertItem.length>0) {
                    [files addObject:covertItem];
                }
            }
            if (block != nil) {
                block((NSArray *)files);
            }
            return task;
        }
    }];
}

@end
