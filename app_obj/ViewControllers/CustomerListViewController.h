//
//  CustomerListViewController.h
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideNavigationController.h"

@interface CustomerListViewController : UIViewController <SlideNavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet UITableView *customerTable;

@end
