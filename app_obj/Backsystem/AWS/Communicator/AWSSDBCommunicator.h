//
//  AWSSDBCommunicator.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AWSClients.h"

@interface AWSSDBCommunicator : AWSClients

+(void)getValuesFromSDBWithDomainName:(NSString *)domainName itemName:(NSString *)itemName keys:(NSArray *)theKeys mainThreadExecutor:(BOOL)mainExecutor completionBlock:(void (^)(NSArray *values))completionBlock;
+(void)getCountFromSDBWithDomainName:(NSString *)domainName completionBlock:(void (^)(NSString *count))complectionBlock;
+(void)getCountFromSDBWithDomainName:(NSString *)domainName key:(NSString *)theKey value:(NSString *)theValue completionBlock:(void(^)(NSString *count))complectionBlock;
+(void)getItemListFromSDBWithDomainName:(NSString *)domainName condition:(NSString *)condition mainThreadExecutor:(BOOL)mainExecutor  completionBlock:(void(^)(NSArray *itemList))complectionBlock;     // retune AWSSimpleDBItem array
+(void)updateValueToSDBWithDomainName:(NSString *)domainName itemName:(NSString *)itemName Key:(NSString *)theKey value:(NSString *)theValue withMainThreadExecutor:(BOOL)mainExecutor completionBlock:(void(^)(BOOL finished))complectionBlock;
+(void)removeSDBItemWithDomainName:(NSString *)domainName itemName:(NSString *)itemName mainThreadExecutor:(BOOL)isMain completionBlock:(void(^)(BOOL successed))complectionBlock;

#pragma - unities
+(NSString *)getValueForAttribute:(NSString *)theAttribute fromList:(NSArray *)attributeList;

@end
