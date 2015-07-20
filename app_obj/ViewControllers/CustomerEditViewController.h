//
//  CustomerEditViewController.h
//  app_obj
//
//  Created by Tian Tian on 7/19/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMCustomer;

@interface CustomerEditViewController : UITableViewController

@property (nonatomic, weak) CMCustomer *editingCustomer;
@property (nonatomic, weak) NSString *editTitle;
@property (nonatomic, weak) NSString *editValue;



@end
