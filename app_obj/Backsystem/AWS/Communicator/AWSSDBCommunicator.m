//
//  AWSSDBCommunicator.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AWSSDBCommunicator.h"

@implementation AWSSDBCommunicator

//! @fn getter

+(void)getValuesFromSDBWithDomainName:(NSString *)domainName itemName:(NSString *)itemName keys:(NSArray *)theKeys mainThreadExecutor:(BOOL)mainExecutor completionBlock:(void (^)(NSArray *values))completionBlock{
    AWSSimpleDBGetAttributesRequest *req = [[AWSSimpleDBGetAttributesRequest alloc] init];
    req.domainName = domainName;
    req.itemName = itemName;
    req.attributeNames = theKeys;
    
    if (mainExecutor) {
        [[[[AWSSDBCommunicator sharedInstance] sdb] getAttributes:req] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
            if (task.error != nil) {
                if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                    NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                }
                return nil;
            }else{
                if (completionBlock != nil) {
                    AWSSimpleDBGetAttributesResult *result = task.result;
                    completionBlock(result.attributes); // user [AmazonClientManager getValueForAttribute:@"" fromList:result.attributes];
                }
                return task;
            }
        }];
    }
    else{
        [[[[AWSSDBCommunicator sharedInstance] sdb] getAttributes:req] continueWithSuccessBlock:^id(AWSTask *task){
            if (task.error != nil) {
                if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                    NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                }
                return nil;
            }else{
                if (completionBlock != nil) {
                    AWSSimpleDBGetAttributesResult *result = task.result;
                    completionBlock(result.attributes);
                }
                return task;
            }
        }];
    }
    
}

+(void)getCountFromSDBWithDomainName:(NSString *)domainName completionBlock:(void (^)(NSString *count))complectionBlock{
    AWSSimpleDBSelectRequest *req = [[AWSSimpleDBSelectRequest alloc] init];
    req.selectExpression = [NSString stringWithFormat:@"select count(*) from %@",domainName];
    
    [[[[AWSSDBCommunicator sharedInstance] sdb] select:req] continueWithExecutor:[AWSExecutor defaultExecutor] withSuccessBlock:^id(AWSTask *task){
        if (task.error != nil) {
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
            return nil;
        }else{
            if (complectionBlock != nil) {
                AWSSimpleDBSelectResult *getResult = task.result;
                AWSSimpleDBItem *getItem = [getResult.items firstObject];
                AWSSimpleDBAttribute *getAtt = [getItem.attributes firstObject];
                complectionBlock(getAtt.value);
            }
            
            return task;
        }
    }];
}

+(void)getCountFromSDBWithDomainName:(NSString *)domainName key:(NSString *)theKey value:(NSString *)theValue completionBlock:(void(^)(NSString *count))complectionBlock{
    AWSSimpleDBSelectRequest *req = [[AWSSimpleDBSelectRequest alloc] init];
    req.selectExpression = [NSString stringWithFormat:@"select count(*) from %@ where %@ = '%@'",domainName,theKey,theValue];
    
    [[[[AWSSDBCommunicator sharedInstance] sdb] select:req] continueWithSuccessBlock:^id(AWSTask *task){
        if (task.error != nil) {
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
            return nil;
        }else{
            if (complectionBlock != nil) {
                AWSSimpleDBSelectResult *getResult = task.result;
                AWSSimpleDBItem *getItem = [getResult.items firstObject];
                AWSSimpleDBAttribute *getAtt = [getItem.attributes firstObject];
                complectionBlock(getAtt.value);
            }
            return task;
        }
    }];
}

+(void)getItemListFromSDBWithDomainName:(NSString *)domainName condition:(NSString *)condition mainThreadExecutor:(BOOL)mainExecutor completionBlock:(void(^)(NSArray *itemList))complectionBlock{
    AWSSimpleDBSelectRequest *req = [[AWSSimpleDBSelectRequest alloc] init];
    req.selectExpression = [NSString stringWithFormat:@"select * from %@ where %@",domainName,condition];
    //    NSLog(@"%@",req.selectExpression);
    if (mainExecutor) {
        [[[[AWSSDBCommunicator sharedInstance] sdb] select:req] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
            if (task.error != nil) {
                NSLog(@"ERROR : %@",task.error);
                if (complectionBlock != nil) {
                    complectionBlock(nil);
                }
                return nil;
            }else{
                if (complectionBlock != nil) {
                    AWSSimpleDBSelectResult *getResult = task.result;
                    complectionBlock(getResult.items); // -> AWSSimpleDBItem Array
                }
                return task;
            }
        }];
    }
    else{
        [[[[AWSSDBCommunicator sharedInstance] sdb] select:req] continueWithSuccessBlock:^id(AWSTask *task){
            if (task.error != nil) {
                if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                    NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                }
                return nil;
            }else{
                if (complectionBlock != nil) {
                    AWSSimpleDBSelectResult *getResult = task.result;
                    complectionBlock(getResult.items); // -> AWSSimpleDBItem Array
                }
                return task;
            }
        }];
    }
    
}

//! @function Putter

+(void)updateValueToSDBWithDomainName:(NSString *)domainName itemName:(NSString *)itemName Key:(NSString *)theKey value:(NSString *)theValue withMainThreadExecutor:(BOOL)mainExecutor completionBlock:(void(^)(BOOL finished))complectionBlock{
    AWSSimpleDBPutAttributesRequest *req = [[AWSSimpleDBPutAttributesRequest alloc] init];
    req.itemName = itemName;
    req.domainName = domainName;
    
    AWSSimpleDBReplaceableAttribute *anAtt;
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = theKey;
    anAtt.value = theValue;
    anAtt.replace = [NSNumber numberWithBool:YES];
    
    req.attributes = @[anAtt];
    
    if (mainExecutor) {
        [[[[AWSSDBCommunicator sharedInstance] sdb] putAttributes:req] continueWithExecutor:[AWSExecutor mainThreadExecutor] withSuccessBlock:^id(AWSTask *task){
            if (task.error != nil) {
                if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                    NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                }
                return nil;
            }else{
                if (complectionBlock != nil) complectionBlock(YES);
                return task;
            }
        }];
    }
    else{
        [[[[AWSSDBCommunicator sharedInstance] sdb] putAttributes:req] continueWithExecutor:[AWSExecutor defaultExecutor] withSuccessBlock:^id(AWSTask *task){
            if (task.error != nil) {
                if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                    NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
                }
                return nil;
            }else{
                if (complectionBlock != nil) complectionBlock(YES);
                return task;
            }
        }];
    }
    
}

//! @function Delete Item

+(void)removeSDBItemWithDomainName:(NSString *)domainName itemName:(NSString *)itemName completionBlock:(void(^)(BOOL successed))complectionBlock{
    AWSSimpleDBDeleteAttributesRequest *req = [[AWSSimpleDBDeleteAttributesRequest alloc] init];
    req.domainName = domainName;
    req.itemName = itemName;
    
    [[[[AWSSDBCommunicator sharedInstance] sdb] deleteAttributes:req] continueWithSuccessBlock:^id(AWSTask *task){
        if (task.error != nil) {
            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            }
            return nil;
        }else{
            if (complectionBlock != nil) {
                complectionBlock (YES);
            }
            return task;
        }
    }];
}

//! @function unity

+(NSString *)getValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList
{
    for (AWSSimpleDBAttribute *attribute in attributeList) {
        if ( [attribute.name isEqualToString:theAttribute]) {
            return attribute.value;
        }
    }
    return nil;
}

@end
