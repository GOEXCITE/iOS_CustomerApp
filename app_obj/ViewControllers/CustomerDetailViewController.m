//
//  CustomerDetailViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CustomerDetailViewController.h"
#import "CMCustomer.h"

@interface CustomerDetailViewController ()

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

@end

@implementation CustomerDetailViewController

- (void)viewDidLoad{
    self.title = self.cus.customerName;
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
}

@end
