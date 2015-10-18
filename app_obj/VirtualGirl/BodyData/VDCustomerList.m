//
//  VDCustomerList.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "VDCustomerList.h"
#import "AWSSDBCommunicator.h"

@interface VDCustomerList ()
@property (nonatomic, strong) AWSSimpleDBSelectRequest *req;
@end
@implementation VDCustomerList

+ (instancetype)sharedInstance{
    static VDCustomerList *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedClass = [[self alloc]init];
    });
    return sharedClass;
}

- (NSMutableArray *)customerList{
    if (_customerList == NULL) {
        _customerList = [NSMutableArray array];
    }
    return _customerList;
}

- (AWSSimpleDBSelectRequest *)req{
    if (!_req) {
        _req = [[AWSSimpleDBSelectRequest alloc] init];
        _req.selectExpression = [NSString stringWithFormat:@"select * from %@ where isDeleted != '1' or isDeleted is null",DOMAIN_CUSTOMER];
    }
    return _req;
}

- (void)refreshWithCompletionBlock:(void (^)(BOOL successed))block{
//    self.customerList = [NSMutableArray array];
    [[[[AWSSDBCommunicator sharedInstance] sdb] select:self.req] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
        if (task.error !=nil) {
            NSLog(@"ERROR : %@",task.error);
            if (block) block(NO);
        }else{
            AWSSimpleDBSelectResult *getResult = task.result;
            NSArray *resultArray = getResult.items;
            for (AWSSimpleDBItem *anItem in resultArray) {
                CMCustomer *aCus = [CMCustomer new];
                aCus.customerId = anItem.name;
                aCus.customerName = [AWSSDBCommunicator getValueForAttribute:@"customerName" fromList:anItem.attributes];
                aCus.pinYin = [AWSSDBCommunicator getValueForAttribute:@"pinYin" fromList:anItem.attributes];
                aCus.gender = [AWSSDBCommunicator getValueForAttribute:@"gender" fromList:anItem.attributes];
                aCus.birth = [AWSSDBCommunicator getValueForAttribute:@"birth" fromList:anItem.attributes];
                aCus.age = [AWSSDBCommunicator getValueForAttribute:@"age" fromList:anItem.attributes];
                aCus.passportId = [AWSSDBCommunicator getValueForAttribute:@"passportId" fromList:anItem.attributes];
                aCus.passportIussedPlace = [AWSSDBCommunicator getValueForAttribute:@"passportIussedPlace" fromList:anItem.attributes];
                aCus.passportValidDate = [AWSSDBCommunicator getValueForAttribute:@"passportValidDate" fromList:anItem.attributes];
                aCus.location = [AWSSDBCommunicator getValueForAttribute:@"location" fromList:anItem.attributes];
                aCus.phoneNumber = [AWSSDBCommunicator getValueForAttribute:@"phoneNumber" fromList:anItem.attributes];
                aCus.mail = [AWSSDBCommunicator getValueForAttribute:@"mail" fromList:anItem.attributes];
                [self.customerList addObject:aCus];
            }
            self.req.nextToken = getResult.nextToken;
            if (self.req.nextToken != nil) [self refreshWithCompletionBlock:block];
            else{
                NSLog(@"SDB Downloading Successed finished!");
                if (block) block(YES);
            }
        }
        return nil;
    }];
}


@end
