//
//  CMCustomer.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CMCustomer.h"
#import "AWSSDBCommunicator.h"

@implementation CMCustomer

- (void)saveWithExecutor:(AWSExecutor *)executor CompletionBlock:(void (^)(BOOL success))block;{
    AWSSimpleDBPutAttributesRequest *req = [[AWSSimpleDBPutAttributesRequest alloc] init];
    if (self.customerId == nil) {
        NSLog(@"Unable to save a customer with no ID!!");
        return;
    }
    req.itemName = self.customerId;
    req.domainName = DOMAIN_CUSTOMER;
    
    NSMutableArray *setAttributes = [NSMutableArray array];
    AWSSimpleDBReplaceableAttribute *anAtt;
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"customerName";
    anAtt.value = _customerName != nil ? _customerName : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"pinYin";
    anAtt.value = _pinYin != nil ? _pinYin : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"gender";
    anAtt.value = _gender != nil ? _gender : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"birth";
    anAtt.value = _birth != nil ? _birth : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"age";
    anAtt.value = _age != nil ? _age : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"passportId";
    anAtt.value = _passportId != nil ? _passportId : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"passportIussedPlace";
    anAtt.value = _passportIussedPlace != nil ? _passportIussedPlace : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"passportValidDate";
    anAtt.value = _passportValidDate != nil ? _passportValidDate : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"location";
    anAtt.value = _location != nil ? _location : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"phoneNumber";
    anAtt.value = _phoneNumber != nil ? _phoneNumber : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"mail";
    anAtt.value = _mail != nil ? _mail : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"wechatID";
    anAtt.value = _wechatID != nil ? _wechatID : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"history";
    anAtt.value = _history != nil ? _history : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    anAtt = [[AWSSimpleDBReplaceableAttribute alloc] init];
    anAtt.name = @"remark";
    anAtt.value = _remark != nil ? _remark : @"";
    anAtt.replace = [NSNumber numberWithBool:YES];
    [setAttributes addObject:anAtt];
    
    req.attributes = (NSArray *)setAttributes;
    [[[AWSSDBCommunicator sharedInstance].sdb putAttributes:req] continueWithExecutor:executor withBlock:^id(AWSTask *task){
        if (task.error != nil) {
            NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
            block(NO);
            return nil;
        }else{
            block(YES);
            return task;
        }
    }];
}

@end
