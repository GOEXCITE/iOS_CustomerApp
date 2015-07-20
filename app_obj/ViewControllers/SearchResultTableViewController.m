//
//  SearchResultTableViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/19/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "SearchResultTableViewController.h"
#import "Brain.h"
#import "CustomerDetailViewController.h"

@interface SearchResultTableViewController ()

@end

@implementation SearchResultTableViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResultIndices count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *CellIdentifier = @"searchResultTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    NSNumber *index = [self.searchResultIndices objectAtIndex:indexPath.row];
    CMCustomer *tCus = [[VDCustomerList sharedInstance].customerList objectAtIndex:index.integerValue];
    cell.textLabel.text = tCus.customerName;
    cell.detailTextLabel.text = tCus.location;
    return cell;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    UITableViewCell *senderCell = (UITableViewCell *)sender;
    NSLog(@"Showing detail of customer with tag : %ld",(long)indexPath.row);
//    CustomerDetailViewController *destination = (CustomerDetailViewController *)segue.destinationViewController;
//    destination.cus = [[VDCustomerList sharedInstance].customerList objectAtIndex:senderCell.tag];
    
    CustomerDetailViewController *vc = [[self storyboard] instantiateViewControllerWithIdentifier:@"CustomerDetailViewController"];
//    vc.
//    self.presentingViewController.navigationItem.title = @"Search";
    NSNumber *index = [self.searchResultIndices objectAtIndex:indexPath.row];
    CMCustomer *tCus = [[VDCustomerList sharedInstance].customerList objectAtIndex:index.integerValue];
    vc.cus = tCus;
    [self.presentingViewController.navigationController pushViewController:vc animated:YES];
}

@end
