//
//  CustomerDetailViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CustomerDetailViewController.h"
#import "Brain.h"
#import "Unities.h"
#import "CustomerEditViewController.h"
#import "CustomerTextEditViewController.h"
#import "UIColor+CMExtension.h"

#import "CustomerListViewController.h"

@interface CustomerDetailViewController () <UINavigationControllerDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *pinyinCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *genderCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *birthCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *ageCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passportIDCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passportIssuedPlaceCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *passportValidDateCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *locationCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *phoneNumberCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *mailCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *wechatIDCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *remarkCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *historyCell;

@property (assign, nonatomic) BOOL needToDeleteThisItem;

@end

@implementation CustomerDetailViewController

- (void)viewDidLoad{
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor tm2_StandardBlue];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = self.cus.customerName;
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Delete" style:UIBarButtonItemStylePlain target:self action:@selector(deleteItem)];

    self.navigationController.delegate = self;
    self.needToDeleteThisItem = NO;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if ([[alertView buttonTitleAtIndex:buttonIndex]isEqualToString:@"删除"]) {
        [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_CUSTOMER itemName:self.cus.customerId Key:@"isDeleted" value:@"1" withMainThreadExecutor:YES completionBlock:^(BOOL finished){
            if (finished) {
                self.needToDeleteThisItem = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"失败" message:@"删除数据失败！\n请稍候再尝试" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alert show];
            }
        }];
    }
}
- (void)deleteItem{
    NSString *msg = [NSString stringWithFormat:@"您确认要删除%@吗？", self.cus.customerName];
    UIAlertView *confirmDelete = [[UIAlertView alloc] initWithTitle:@"确认！" message:msg delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"删除", nil];
    [confirmDelete show];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated{
    CustomerListViewController *desViewCon;
    if ([viewController isKindOfClass:[CustomerListViewController class]] && self.needToDeleteThisItem) {
        desViewCon = (CustomerListViewController *)viewController;
        NSInteger index = [[VDCustomerList sharedInstance].customerList indexOfObject:self.cus];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        [[VDCustomerList sharedInstance].customerList removeObject:self.cus];
        [desViewCon.customerTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSString *msgIfNoData = @" - ";
    self.pinyinCell.detailTextLabel.text = self.cus.pinYin.length>0 ? self.cus.pinYin : msgIfNoData;
    self.genderCell.detailTextLabel.text = self.cus.gender.length ? self.cus.gender : msgIfNoData;
    self.birthCell.detailTextLabel.text = self.cus.birth.length ? self.cus.birth : msgIfNoData;
    self.ageCell.detailTextLabel.text = self.cus.age.length ? self.cus.age : msgIfNoData;
    self.passportIDCell.detailTextLabel.text = self.cus.passportId.length ? self.cus.passportId :msgIfNoData;
    self.passportIssuedPlaceCell.detailTextLabel.text = self.cus.passportIussedPlace.length ? self.cus.passportIussedPlace : msgIfNoData;
    self.passportValidDateCell.detailTextLabel.text = self.cus.passportValidDate.length ? self.cus.passportValidDate : msgIfNoData;
    self.locationCell.detailTextLabel.text = self.cus.location.length ? self.cus.location : msgIfNoData;
    self.phoneNumberCell.detailTextLabel.text = self.cus.phoneNumber.length ? self.cus.phoneNumber : msgIfNoData;
    self.mailCell.detailTextLabel.text = self.cus.mail.length ? self.cus.mail : msgIfNoData;
    self.wechatIDCell.detailTextLabel.text = self.cus.wechatID.length ? self.cus.wechatID : msgIfNoData;
    self.historyCell.detailTextLabel.text = self.cus.history.length ? self.cus.history : msgIfNoData;
    self.remarkCell.detailTextLabel.text = self.cus.remark.length ? self.cus.remark : msgIfNoData;
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"删除" style:UIBarButtonItemStyleDone target:self action:@selector(removeItem)];
}

//- (void)removeItem{
////    __block CMCustomer *tCus = [[VDCustomerList sharedInstance].customerList objectAtIndex:indexPath.row];
//    [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_CUSTOMER itemName:self.cus.customerId Key:@"isDeleted" value:[NSDate date].getyyyyMMddhhmmssString withMainThreadExecutor:YES completionBlock:^(BOOL successed){
//        if (successed) {
//            NSLog(@"customer %@(id : %@) is deleted!",tCus.customerName,tCus.customerId);
//            [[VDCustomerList sharedInstance].customerList removeObject:self.cus];
//            
//            [self.customerTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//        }
//    }];
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"EditCustomerDetail"]) {
        UITableViewCell *cell = [sender isKindOfClass:[UITableViewCell class]] ? sender : nil;
        if (cell == nil) NSLog(@"sender is incorrect!");
        if ([cell.textLabel.text isEqualToString:@"性别"]) {
            return;
        }
        CustomerEditViewController *editV = (CustomerEditViewController *)segue.destinationViewController;
        editV.editingCustomer = self.cus;
        editV.editTitle = cell.textLabel.text;
        editV.editValue = cell.detailTextLabel.text;
    }else if ([segue.identifier isEqualToString:@"EditTextCustomerDetail"]){
        UITableViewCell *cell = [sender isKindOfClass:[UITableViewCell class]] ? sender : nil;
        if (cell == nil) NSLog(@"sender is incorrect!");
        CustomerTextEditViewController *editV = (CustomerTextEditViewController *)segue.destinationViewController;
        editV.editingCustomer = self.cus;
        editV.editTitle = cell.textLabel.text;
        editV.editValue = cell.detailTextLabel.text;
    }
}

@end
