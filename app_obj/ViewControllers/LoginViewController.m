//
//  LoginViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "LoginViewController.h"

#import "Brain.h"

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController
{
    BOOL loginPassed;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    loginPassed = NO;
    
    NSLog(@"user type %lu",(unsigned long)self.cm_userType);
    if (self.cm_userType != CMUserTypeUnregister) {
        [self performSegueWithIdentifier:@"LoginSegue" sender:self.loginButton];
    }
}

- (void)login:(id)sender{
    if (self.passwordField.text.length > 0) {
        [[VDOwner alive] loginWithInitialPassword:self.passwordField.text completionBlock:^(NSString *errorMsg){
            if (errorMsg == nil) {
                //! @p Save to Local
                [self cm_SaveUserType:[VDOwner alive].userType];
                
                //! @p show Message to User
                NSString *userTypeStr = [VDOwner alive].userType == CMUserTypeAdmin ? @"查看添加修改客户文件" : @"查看添加客户文件";
                NSString *showMsg = errorMsg == nil?
                [NSString stringWithFormat:@"%@ ,欢迎登陆。\n您的用户权限是%@",[VDOwner alive].userName,userTypeStr] :
                errorMsg;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统信息" message:showMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
                
                //! @p perform segue
                [self performSegueWithIdentifier:@"LoginSegue" sender:self.loginButton];
                
                //! @p rewrite SDB initPW
                [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_USER itemName:[VDOwner alive].userId Key:@"initialPW" value:@"" withMainThreadExecutor:NO completionBlock:^(BOOL succeesed){
                    NSLog(succeesed ? @"Deleted initialPW" : @"ERROR : failed to delete initialPW!");
                }];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统信息" message:errorMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统信息" message:@"请您输入注册登录码！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    return [textField resignFirstResponder];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    if ([identifier isEqualToString:@"LoginSegue"]) {
        return loginPassed;
    }
    return YES;
}

@end


//if (self.userIDField.text.length > 0 && self.passwordField.text.length > 0) {
//    [[VDOwner alive] tryToLoginWithUserId:self.userIDField.text password:self.passwordField.text completionBlock:^(NSString *loginFailedMsg){
//        loginPassed = loginFailedMsg==nil;
//        NSString *showMsg = loginFailedMsg == nil?
//        [NSString stringWithFormat:@"%@ ,欢迎登陆。\n您的用户权限是%lu",[VDOwner alive].userName,(unsigned long)[VDOwner alive].userType] :
//        loginFailedMsg;
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统信息" message:showMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//
//        [self performSegueWithIdentifier:@"LoginSegue" sender:self.loginButton];
//    }];
//}else{
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"系统信息" message:@"请您输入用户名和密码" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//    [alert show];
//}
