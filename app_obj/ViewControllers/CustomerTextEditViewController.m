//
//  CustomerTextEditViewController.m
//  app_obj
//
//  Created by Tian Tian on 10/18/15.
//  Copyright © 2015 goexcite.net. All rights reserved.
//

#import "CustomerTextEditViewController.h"
#import "Brain.h"
#import "UIColor+CMExtension.h"
#import "CMCustomer.h"
#import "CustomerDetailViewController.h"

@interface CustomerTextEditViewController () <UITextViewDelegate>

@property (strong, nonatomic) IBOutlet UILabel *titleLabel;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end

@implementation CustomerTextEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor tm2_StandardBlue];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = self.editingCustomer.customerName;
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
    self.titleLabel.text = self.editTitle;
    self.textView.text = self.editValue;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
}

- (void)save{
    if ([self.titleLabel.text isEqualToString:@"历史记录"]) {
        self.editingCustomer.history = self.textView.text;
    }else if ([self.titleLabel.text isEqualToString:@"备注"]) {
        self.editingCustomer.remark = self.textView.text;
    }
    [self.editingCustomer saveWithExecutor:[AWSExecutor mainThreadExecutor] CompletionBlock:^(BOOL successed){
        NSLog(successed ? @"save customer Data to SDB successed":@"Failed to save customer data to SDB");
        if (successed) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"修改失败" message:@"无法修改数据。\n请您尝试稍后再修改。" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[CustomerDetailViewController class]]) {
        CustomerDetailViewController *forwardingV = (CustomerDetailViewController *)viewController;
        [forwardingV.tableView reloadData];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    NSLog(@"Begin to edit %@",self.editTitle);
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    NSLog(@"Ended editing %@",self.editTitle);
}


@end
