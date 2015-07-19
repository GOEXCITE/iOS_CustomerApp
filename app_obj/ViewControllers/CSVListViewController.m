//
//  CSVListViewController.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CSVListViewController.h"
#import "Brain.h"
#import "Unities.h"

//#define csvFilePath         @"file:///Users/tiantian/Desktop/sam.csv"
@interface CSVListViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) NSArray *csvFileList;
@end

@implementation CSVListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [AWSS3Communicator getFileListInS3WithFrefixKey:@"CustomerDataCSV/" executor:[AWSExecutor mainThreadExecutor] completionBlock:^(NSArray *csvFileList){
        self.csvFileList = csvFileList;
        [self.csvTable reloadData];
    }];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (IBAction)saveCSVToSDB:(id)sender{
    UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indi.center = self.view.center;
    [self.view addSubview:indi];
    [indi startAnimating];
    for (NSString *aFile in self.csvFileList) {
        __block NSInteger index = [self.csvFileList indexOfObject:aFile];
        if ([self.csvTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].accessoryType!=UITableViewCellAccessoryCheckmark) {
            [AWSS3Communicator downloadDataFromS3WithKey:[NSString stringWithFormat:@"CustomerDataCSV/%@",aFile]
                                         completionBlock:^(NSData *data){
                                             if (data != nil) {
                                                 NSLog(@"successed got file from S3.");
                                                 
                                                 NSString *pathStr = [NSTemporaryDirectory() stringByAppendingString:aFile];
                                                 NSURL *pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",pathStr]];
                                                 [data writeToFile:pathStr atomically:YES];
                                                 [self cm_saveCSVToSDB:pathURL withCompletionBlock:^(BOOL successed){
                                                     if (successed) {
                                                         NSLog(@"successed parsed CSV file and updated to SDB.");
                                                         [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_CSV
                                                                                                   itemName:aFile
                                                                                                        Key:@"parsedDate"
                                                                                                      value:[NSDate date].getyyyyMMddhhmmssString
                                                                                     withMainThreadExecutor:YES
                                                                                            completionBlock:^(BOOL successed){
                                                                                                [indi stopAnimating];
                                                                                                if (successed) {
                                                                                                    NSLog(@"Updated CSV ParsedDate in SDB.");
                                                                                                    [self.csvTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
                                                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新完毕" message:@"成功将CSV文件更新到数据库" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                                                    [alert show];
                                                                                                    
                                                                                                }else{
                                                                                                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"成功将CSV文件更新到数据库，但未能修改CSV文件的解读标示！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                                                                    [alert show];
                                                                                                }
                                                                                            }];
                                                     }else{
                                                         NSLog(@"Failed to save CSV file to SDB!");
                                                         [indi stopAnimating];
                                                         UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"未能成功将CSV文件输入到数据库中！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                         [alert show];
                                                     }
                                                     NSError *error;
                                                     [[NSFileManager defaultManager] removeItemAtPath:pathStr error: &error];
                                                     if (error) NSLog(@"ERROR :%@",error);
                                                 }];
                                             }else{
                                                 [indi stopAnimating];
                                                 NSLog(@"Unable to get CSV file from S3!");
                                             }
                                         }];
        }
    }
//    NSURL *url = [NSURL URLWithString:csvFilePath];
//    [self cm_saveCSVToSDB:url withCompletionBlock:^(BOOL successed){
//        NSLog(successed ? @"" : @"Failed to save CSV file to SDB!");
//    }];
}

- (BOOL)slideNavigationControllerShouldDisplayLeftMenu{
    return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu{
    return NO;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.csvFileList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"csvTableCell" forIndexPath:indexPath];
    NSString *aFile = [self.csvFileList objectAtIndex:indexPath.row];
    cell.textLabel.text = aFile;
    [AWSSDBCommunicator getValuesFromSDBWithDomainName:DOMAIN_CSV itemName:aFile keys:@[@"parsedDate"] mainThreadExecutor:YES completionBlock:^(NSArray *parsedDate){
        AWSSimpleDBAttribute *parsedDateStr = parsedDate.firstObject;
        if (parsedDateStr.value.length>0) {
            cell.detailTextLabel.text = parsedDateStr.value;
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.csvTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }else{
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }
    }];
//    cell.detailTextLabel.text = aFile.parsedDate;
//    CMCSV *aFile = [self.csvFileList objectAtIndex:indexPath.row];
//    cell.textLabel.text = aFile.fileName;
//    cell.detailTextLabel.text = aFile.parsedDate;
//    NSNumber *flag = (NSNumber *)[_csvFileParsed objectAtIndex:indexPath.row];
//    cell.accessoryType = flag.boolValue;
    return cell;
}

@end
