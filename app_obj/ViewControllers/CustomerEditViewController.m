//
//  CustomerEditViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/19/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CustomerEditViewController.h"
#import "Brain.h"
#import "CustomerDetailViewController.h"
#import "Unities.h"

@interface CustomerEditViewController () <UITextFieldDelegate,UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *editField;
@property (weak, nonatomic) IBOutlet UILabel *plusInfo;
@end

@implementation CustomerEditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.editingCustomer.customerName;
    self.navigationController.delegate = self;
    
    self.titleLabel.text = self.editTitle;
    self.editField.text = self.editValue;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save)];
    
    if ([self.titleLabel.text isEqualToString:@"拼音"]) {
        self.editField.keyboardType = UIKeyboardTypeASCIICapable;
    }else if ([self.titleLabel.text isEqualToString:@"出生年月"]) {
        self.editField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.plusInfo.text = @"输入例: 2000/01/01";
    }else if ([self.titleLabel.text isEqualToString:@"年龄"]) {
        self.editField.keyboardType = UIKeyboardTypeNumberPad;
    }else if ([self.titleLabel.text isEqualToString:@"护照号码"]) {
        self.editField.keyboardType = UIKeyboardTypeASCIICapable;
    }else if ([self.titleLabel.text isEqualToString:@"护照发行地"]) {
        self.editField.keyboardType = UIKeyboardTypeDefault;
    }else if ([self.titleLabel.text isEqualToString:@"护照有效期"]) {
        self.editField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        self.plusInfo.text = @"输入例: 2000/01/01";
    }else if ([self.titleLabel.text isEqualToString:@"常驻地"]) {
        self.editField.keyboardType = UIKeyboardTypeDefault;
    }else if ([self.titleLabel.text isEqualToString:@"联系方式"]) {
        self.editField.keyboardType = UIKeyboardTypeNumberPad;
    }else if ([self.titleLabel.text isEqualToString:@"mail"]) {
        self.editField.keyboardType = UIKeyboardTypeASCIICapable;
    }
}

-(void)save{
    if ([self.titleLabel.text isEqualToString:@"拼音"]) {
        self.editingCustomer.pinYin = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"性别"]) {
        self.editingCustomer.gender = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"出生年月"]) {
        self.editingCustomer.birth = self.editField.text;
        NSInteger age = [NSDate date].getyyyy.integerValue - [self.editField.text substringToIndex:4].integerValue;
        self.editingCustomer.age = [NSString stringWithFormat:@"%ld",(long)age];
        
    }else if ([self.titleLabel.text isEqualToString:@"年龄"]) {
        self.editingCustomer.age = self.editField.text;
        
        NSString *frontPart = [NSString stringWithFormat:@"%d",[NSDate date].getyyyy.integerValue-self.editField.text.integerValue];
        NSString *backPart = self.editingCustomer.birth.length==10 ? [self.editingCustomer.birth substringFromIndex:4] : @"/--/--";
        self.editingCustomer.birth = [frontPart stringByAppendingString:backPart];
    }else if ([self.titleLabel.text isEqualToString:@"护照号码"]) {
        self.editingCustomer.passportId = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"护照发行地"]) {
        self.editingCustomer.passportIussedPlace = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"护照有效期"]) {
        self.editingCustomer.passportValidDate = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"常驻地"]) {
        self.editingCustomer.location = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"联系方式"]) {
        self.editingCustomer.phoneNumber = self.editField.text;
    }else if ([self.titleLabel.text isEqualToString:@"mail"]) {
        self.editingCustomer.mail = self.editField.text;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if ([viewController isKindOfClass:[CustomerDetailViewController class]]) {
        CustomerDetailViewController *forwardingV = (CustomerDetailViewController *)viewController;
        [forwardingV.tableView reloadData];
    }
}

@end
