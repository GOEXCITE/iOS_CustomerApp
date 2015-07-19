//
//  VDCustomerList.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CMCustomer.h"

@interface VDCustomerList : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, strong) NSMutableArray    *customerList;

- (void)refreshWithCompletionBlock:(void (^)(BOOL successed))block;

@end
