//
//  CustomerDetailViewController.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMCustomer;

@interface CustomerDetailViewController : UITableViewController

@property (nonatomic , strong) CMCustomer   *cus;

@end
