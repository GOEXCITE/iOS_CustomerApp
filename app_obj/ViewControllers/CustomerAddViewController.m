//
//  CustomerAddViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CustomerAddViewController.h"

#import "Unities.h"
#import "Brain.h"
#import "UIColor+CMExtension.h"
//#import "CMCustomer.h"
//#import "AWSSDBCommunicator.h"

@interface CustomerAddViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *pinyinField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *genderSegCtl;
@property (weak, nonatomic) IBOutlet UITextField *birthField;
@property (weak, nonatomic) IBOutlet UITextField *ageField;
@property (weak, nonatomic) IBOutlet UITextField *passportIdField;
@property (weak, nonatomic) IBOutlet UITextField *passportIssuedPlaceField;
@property (weak, nonatomic) IBOutlet UITextField *passportValidDateField;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumberField;
@property (weak, nonatomic) IBOutlet UITextField *mailField;

@end

@implementation CustomerAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor tm2_StandardBlue];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"顾客列表";
    [title sizeToFit];
    self.navigationItem.titleView = title;
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField == self.birthField) {
        NSInteger age = [NSDate date].getyyyy.integerValue - [self.birthField.text substringToIndex:4].integerValue;
        self.ageField.text = [NSString stringWithFormat:@"%ld",(long)age];
    }else if (textField == self.ageField){
        NSString *frontPart = [NSString stringWithFormat:@"%d",[NSDate date].getyyyy.integerValue-self.ageField.text.integerValue];
        NSString *backPart = self.birthField.text.length==10 ? [self.birthField.text substringFromIndex:4] : @"/--/--";
        
        self.birthField.text = [frontPart stringByAppendingString:backPart];
    }
}

- (IBAction)saveToSDB:(id)sender {
    
    CMCustomer *new = [[CMCustomer alloc] init];
    new.customerName = self.nameField.text;
    new.pinYin = self.pinyinField.text;
    if (self.genderSegCtl.selectedSegmentIndex==0) {
        new.gender = @"N";
    }else if (self.genderSegCtl.selectedSegmentIndex==1){
        new.gender = @"M";
    }else if (self.genderSegCtl.selectedSegmentIndex==2){
        new.gender = @"F";
    }
    new.birth = self.birthField.text;
    new.age = self.ageField.text;
    new.passportId = self.passportIdField.text;
    new.passportIussedPlace = self.passportIssuedPlaceField.text;
    new.passportValidDate = self.passportValidDateField.text;
    new.location = self.locationField.text;
    new.phoneNumber = self.phoneNumberField.text;
    new.mail = self.mailField.text;
    [AWSSDBCommunicator getCountFromSDBWithDomainName:DOMAIN_CUSTOMER completionBlock:^(NSString *count){
        new.customerId = count;
        [new saveWithExecutor:[AWSExecutor mainThreadExecutor] CompletionBlock:^(BOOL successed){
            NSLog(@"user %@ saved to SDB with ID : %@",new.customerName,new.customerId);
            [[VDCustomerList sharedInstance].customerList addObject:new];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存成功" message:@"已经成功将用户添加到数据库和列表中！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"iPhoneMain" bundle: nil] instantiateViewControllerWithIdentifier: @"CustomerListViewController"];
//            [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
//                                                                     withSlideOutAnimation:YES
//                                                                             andCompletion:nil];
        }];
    }];
    
}

@end
