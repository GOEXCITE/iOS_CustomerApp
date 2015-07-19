//
//  CustomerListViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CustomerListViewController.h"
#import "CustomerDetailViewController.h"
#import "Brain.h"
#import "SearchTableCell.h"
//static NSArray *testList(){
//    return @[@"tian tian",@"yukiyama yuuichi",@"yamamoto syoutai",@"wang jing"];
//}


@interface CustomerListViewController () <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate,UISearchControllerDelegate,UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchCus;
@property (weak, nonatomic) NSArray *searchResults;
@end

@implementation CustomerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    [self.searchDisplayController.searchResultsTableView registerClass:[SearchTableCell class] forCellReuseIdentifier:@"SearchTableCell"];
    
    [[VDCustomerList sharedInstance] refreshWithCompletionBlock:^(BOOL successed){
        if (successed) {
            [self.customerTable reloadData];
        }
    }];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
    return NO;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return [VDCustomerList sharedInstance].customerList.count;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.searchResults count];
        
    } else {
        NSLog(@"customer number %ld",(long)[VDCustomerList sharedInstance].customerList.count);
        return [VDCustomerList sharedInstance].customerList.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = tableView == self.searchDisplayController.searchResultsTableView ? @"SearchTableCell" : @"customerTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    CMCustomer *tCus;
//    = [[VDCustomerList sharedInstance].customerList objectAtIndex:indexPath.row];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
//        recipe = [searchResults objectAtIndex:indexPath.row];
        tCus = [self.searchResults objectAtIndex:indexPath.row];
    } else {
//        recipe = [recipes objectAtIndex:indexPath.row];
        tCus = [[VDCustomerList sharedInstance].customerList objectAtIndex:indexPath.row];
    }
    
    cell.textLabel.text = tCus.customerName;
    cell.detailTextLabel.text = tCus.location;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CustomerDetailSegue"]) {
        UITableViewCell *senderCell = (UITableViewCell *)sender;
        NSLog(@"Showing detail of customer with tag : %ld",(long)senderCell.tag);
        CustomerDetailViewController *destination = (CustomerDetailViewController *)segue.destinationViewController;
        destination.cus = [[VDCustomerList sharedInstance].customerList objectAtIndex:senderCell.tag];
    }
}

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"customerName contains[c] %@", searchText];
//    NSArray *tmp = (NSArray *)[VDCustomerList sharedInstance].customerList;
    self.searchResults = [[VDCustomerList sharedInstance].customerList filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

@end
