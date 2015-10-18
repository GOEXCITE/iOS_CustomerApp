//
//  CustomerTextEditViewController.h
//  app_obj
//
//  Created by Tian Tian on 10/18/15.
//  Copyright © 2015 goexcite.net. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CMCustomer;

@interface CustomerTextEditViewController : UIViewController

@property (nonatomic, weak) CMCustomer *editingCustomer;
@property (nonatomic, weak) NSString *editTitle;
@property (nonatomic, weak) NSString *editValue;

@end
