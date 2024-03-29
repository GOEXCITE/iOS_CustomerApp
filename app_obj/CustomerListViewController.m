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
#import "SearchResultTableViewController.h"
#import "Unities.h"
#import "UIColor+CMExtension.h"
//static NSArray *testList(){
//    return @[@"tian tian",@"yukiyama yuuichi",@"yamamoto syoutai",@"wang jing"];
//}


@interface CustomerListViewController () <UITableViewDelegate, UITableViewDataSource,UISearchResultsUpdating>

//@property (weak, nonatomic) IBOutlet UISearchBar *searchCus;
@property (strong, nonatomic) NSMutableArray *searchResultIndices;

@property (strong, nonatomic) UISearchController *searchController;
//@property (assign, nonatomic) BOOL isSearching;
@end

@implementation CustomerListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor tm2_StandardBlue];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"顾客列表";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
    self.tabBarController.tabBar.tintColor = [UIColor tm2_StandardBlue];
    
    self.searchResultIndices = [NSMutableArray array];
    UINavigationController *searchResultsController = [[self storyboard] instantiateViewControllerWithIdentifier:@"SearchResultNaviController"];
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultsController];
    self.searchController.searchResultsUpdater = self;
    
    self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0);
    
//    self.searchController.searchBar.scopeButtonTitles = @[@"test1",@"test2"];
    
    self.customerTable.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    UIActivityIndicatorView *indiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indiView.center =self.view.center;
    [self.view addSubview:indiView];
    [indiView startAnimating];
    [[VDCustomerList sharedInstance] refreshWithCompletionBlock:^(BOOL successed){
        [indiView stopAnimating];
        if (successed) {
            [self.customerTable reloadData];
        }
    }];
}

- (IBAction)search:(id)sender {
    [self.searchController setEditing:YES animated:YES];
}

- (IBAction)refresh:(id)sender {
    [VDCustomerList sharedInstance].customerList = [NSMutableArray array];
    
    UIActivityIndicatorView *indiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indiView.center =self.view.center;
    [self.view addSubview:indiView];
    [indiView startAnimating];
    [[VDCustomerList sharedInstance] refreshWithCompletionBlock:^(BOOL successed){
        [indiView stopAnimating];
        if (successed) {
            [self.customerTable reloadData];
        }
    }];
}

//! @function Table

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"customer number %ld",(long)[VDCustomerList sharedInstance].customerList.count);
    return [VDCustomerList sharedInstance].customerList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *CellIdentifier = @"customerTableCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    CMCustomer *tCus = [[VDCustomerList sharedInstance].customerList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = tCus.customerName;
    cell.detailTextLabel.text = tCus.location;
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
//    return YES;
//}
//
//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        __block CMCustomer *tCus = [[VDCustomerList sharedInstance].customerList objectAtIndex:indexPath.row];
//        [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_CUSTOMER itemName:tCus.customerId Key:@"deletedDate" value:[NSDate date].getyyyyMMddhhmmssString withMainThreadExecutor:YES completionBlock:^(BOOL successed){
//            if (successed) {
//                NSLog(@"customer %@(id : %@) is deleted!",tCus.customerName,tCus.customerId);
//                [[VDCustomerList sharedInstance].customerList removeObject:tCus];
//                [self.customerTable deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//            }
//        }];
//    }
//}

//! @function Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"CustomerDetailSegue"]) {
        UITableViewCell *senderCell = (UITableViewCell *)sender;
        NSLog(@"Showing detail of customer with tag : %ld",(long)senderCell.tag);
        CustomerDetailViewController *destination = (CustomerDetailViewController *)segue.destinationViewController;
        destination.cus = [[VDCustomerList sharedInstance].customerList objectAtIndex:senderCell.tag];
    }
}

//! @function Search

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController{
    NSString *searchString = [self.searchController.searchBar text];
    [self.searchResultIndices removeAllObjects];
    for (CMCustomer *aCus in [VDCustomerList sharedInstance].customerList) {
        if ([aCus.customerName containsString:searchString]) {
            [self.searchResultIndices addObject:[NSNumber numberWithInteger:[[VDCustomerList sharedInstance].customerList indexOfObject:aCus]]];
        }
    }
    if (self.searchController.searchResultsController) {
        UINavigationController *navController = (UINavigationController *)self.searchController.searchResultsController;
        
        SearchResultTableViewController *vc = (SearchResultTableViewController *)navController.topViewController;
        vc.searchResultIndices = self.searchResultIndices;
        [vc.tableView reloadData];
    }
}

//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"customerName contains[c] %@", searchText];
//    NSArray *tmp = (NSArray *)[VDCustomerList sharedInstance].customerList;
@end
