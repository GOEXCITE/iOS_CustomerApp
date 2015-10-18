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
#import "UIColor+CMExtension.h"

//#define csvFilePath         @"file:///Users/tiantian/Desktop/sam.csv"
@interface CSVListViewController () <UITableViewDataSource, UITableViewDelegate,DropboxHandlerDelegate>
@property (nonatomic, strong) NSArray *dropboxCSVFileList;
@property (nonatomic, strong) NSArray *sdbCSVFileList;      // -> AWSSimpleDBItem array
@property (nonatomic, strong) NSArray *mergedCSVFileList;
@property (nonatomic, strong) NSArray *filesNeedsParse;
@property (nonatomic, assign) BOOL     dropboxCSVFileListDownloaded;
@property (nonatomic, assign) BOOL     sdbCSVFileListDownloaded;

@property (nonatomic, strong) UIActivityIndicatorView *indi;

@end

@implementation CSVListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor tm2_StandardBlue];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectZero];
    title.font = [UIFont boldSystemFontOfSize:16.0];
    title.textColor = [UIColor whiteColor];
    title.text = @"文件列表";
    [title sizeToFit];
    self.navigationItem.titleView = title;
    
    [self getDropboxCSVFiles];
    
    [self getSDBCSVFiles];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)getDropboxCSVFiles{
    [DropboxHandler shared].completionBlock = ^(BOOL successed){
        if (successed) {
            self.dropboxCSVFileList = [DropboxHandler shared].csvList;
            [self.csvTable reloadData];
        }else{
            NSLog(@"Failed to loaded csv list from dropbox!");
        }
        self.dropboxCSVFileListDownloaded = YES;
        [self mergeDropboxCSVFileListAndSDBCSVFileList];
    };
    
    __weak CSVListViewController *weakSelf = self;
    [DropboxHandler shared].delegate = weakSelf;
    if (![DBSession sharedSession].isLinked) {
        [[DBSession sharedSession] linkFromController:self.navigationController];
    }else{
        [[DropboxHandler shared] loadCSVFileList];
    }
}

- (void)getSDBCSVFiles{
    AWSSimpleDBSelectRequest *req = [[AWSSimpleDBSelectRequest alloc] init];
    req.selectExpression = [NSString stringWithFormat:@"select * from %@",DOMAIN_CSV];
    //    NSLog(@"%@",req.selectExpression);
    [[[[AWSSDBCommunicator sharedInstance] sdb] select:req] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task){
        if (task.error != nil) {
            NSLog(@"ERROR : %@",task.error);
        }else{
            AWSSimpleDBSelectResult *getResult = task.result;
            self.sdbCSVFileList = getResult.items;
            self.sdbCSVFileListDownloaded = YES;
            [self mergeDropboxCSVFileListAndSDBCSVFileList];
        }
        return nil;
    }];
}

- (void)mergeDropboxCSVFileListAndSDBCSVFileList{
    if (self.sdbCSVFileListDownloaded && self.dropboxCSVFileListDownloaded) {
        NSMutableSet *totalList = [NSMutableSet set];
        NSMutableArray *parseList = [NSMutableArray array];
        
        for (AWSSimpleDBItem *anItem in self.sdbCSVFileList) {
            [totalList addObject:anItem.name];
        }
        
        for (NSString *aName in self.dropboxCSVFileList) {
            if (![totalList containsObject:aName]) {
                [parseList addObject:aName];
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            [totalList addObject:aName];
        }
        
        self.mergedCSVFileList = totalList.allObjects;
        self.filesNeedsParse = (NSArray *)parseList;
        [self.csvTable reloadData];
    }
}

- (IBAction)refreshCSVList:(id)sender {
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self getDropboxCSVFiles];
    [self getSDBCSVFiles];
}


- (void)dropboxDownloadedFile:(NSString *)fullFilePath{
    NSLog(@"successed got file from Dropbox.");
    
    NSRange range = [fullFilePath rangeOfString:@"/" options:NSBackwardsSearch];
    NSString *fileName = range.location == NSNotFound ? fullFilePath : [fullFilePath substringFromIndex:range.location+1];
    
    NSURL *pathURL = [[NSURL alloc] initFileURLWithPath:fullFilePath];
//    [data writeToFile:pathStr atomically:YES];
    [self cm_saveCSVToSDB:pathURL withCompletionBlock:^(BOOL successed){
        if (successed) {
            NSLog(@"successed parsed CSV file and updated to SDB.");
            [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_CSV
                                                      itemName:fileName
                                                           Key:@"parsedDate"
                                                         value:[NSDate date].getyyyyMMddhhmmssString
                                        withMainThreadExecutor:YES
                                               completionBlock:^(BOOL successed){
                                                   [self.indi stopAnimating];
                                                   [self refreshCSVList:nil];
                                                   if (successed) {
                                                       NSLog(@"Updated CSV ParsedDate to SDB.");
                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新完毕" message:@"成功将CSV文件更新到数据库" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                       [alert show];
                                                       
                                                   }else{
                                                       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"成功将CSV文件更新到数据库，但未能修改CSV文件的解读标示！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                                                       [alert show];
                                                   }
                                               }];
        }else{
            NSLog(@"Failed to save CSV file to SDB!");
            [self.indi stopAnimating];
            [self refreshCSVList:nil];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"未能成功将CSV文件输入到数据库中！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }

        NSError *error;
        [[NSFileManager defaultManager] removeItemAtPath:fullFilePath error: &error];
        if (error) NSLog(@"ERROR :%@",error);
    }];
}

- (IBAction)saveCSVToSDB:(id)sender{
    [self refreshCSVList:nil];
    if (!self.filesNeedsParse.count > 0) {
        return;
    }
    self.indi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.indi.center = self.view.center;
    [self.view addSubview:self.indi];
    [self.indi startAnimating];
    for (NSString *aFile in self.filesNeedsParse) {
        [[DropboxHandler shared] loadCSVFile:aFile];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.mergedCSVFileList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"csvTableCell" forIndexPath:indexPath];
    NSString *aFile = [self.mergedCSVFileList objectAtIndex:indexPath.row];
    cell.textLabel.text = aFile;
    if ([self.filesNeedsParse containsObject:aFile]) {
        cell.imageView.image = [UIImage imageNamed:@"icon_new.png"];
        cell.detailTextLabel.text = @"需要被读取到数据库";
        
    }else if ([self.dropboxCSVFileList containsObject:aFile] && [self sdbCSVFileListContainsFile:aFile]){
        cell.imageView.image = [UIImage imageNamed:@"icon_OK.png"];
        cell.detailTextLabel.text = @"已经被读取到数据库";
    }else{
        cell.imageView.image = [UIImage imageNamed:@"icon_warning.png"];
        cell.detailTextLabel.text = @"此文件已从Dropbox中删除";
    }
//    [AWSSDBCommunicator getValuesFromSDBWithDomainName:DOMAIN_CSV itemName:aFile keys:@[@"parsedDate"] mainThreadExecutor:YES completionBlock:^(NSArray *parsedDate){
//        AWSSimpleDBAttribute *parsedDateStr = parsedDate.firstObject;
//        if (parsedDateStr.value.length>0) {
//            cell.detailTextLabel.text = parsedDateStr.value;
//            cell.accessoryType = UITableViewCellAccessoryCheckmark;
//            [self.csvTable reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        }else{
//            self.navigationItem.rightBarButtonItem.enabled = YES;
//        }
//    }];
    return cell;
}

//! @function : Private 

- (BOOL)sdbCSVFileListContainsFile:(NSString *)fileName{
    for (AWSSimpleDBItem *anItem in self.sdbCSVFileList) {
        if ([anItem.name isEqualToString:fileName]) {
            return YES;
        }
    }
    return NO;
}

- (NSString *)getDateFromSdbCSVFileList:(NSString *)fileName{
    for (AWSSimpleDBItem *anItem in self.sdbCSVFileList) {
        if ([anItem.name isEqualToString:fileName]) {
            for (AWSSimpleDBAttribute *anAtt in anItem.attributes) {
                if ([anAtt.name isEqualToString:@"parsedDate"]) {
                    return  anAtt.value;
                }
            }
        }
    }
    return nil;
}

@end

@interface DropboxHandler () <DBRestClientDelegate>

@property (nonatomic, strong) DBRestClient  *restClient;

@end

@implementation DropboxHandler

+ (instancetype)shared{
    static DropboxHandler *sharedClass = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClass = [[DropboxHandler alloc] init];
    });
    return sharedClass;
}

- (instancetype)init{
    self = [super init];
    if (self) {
        DBSession *session = [[DBSession alloc] initWithAppKey:DROPBOX_APP_KEY appSecret:DROPBOX_APP_SECRET root:kDBRootDropbox];
        [DBSession setSharedSession:session];
        if (![DBSession sharedSession].isLinked) {
            NSLog(@"Dropbox DBSession unlinked!");
        }
        self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        self.restClient.delegate = self;
        return  self;
    }
    return nil;
}

- (void)loadCSVFileList{
//    self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
//    self.restClient.delegate = self;
    [self.restClient loadMetadata:@"/_customerData"];
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        NSMutableArray *array = [NSMutableArray new];
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"%@ \n", file.filename);
            [array addObject:file.filename];
        }
        self.csvList = (NSArray *)array;
        self.completionBlock(YES);
    }else{
        self.completionBlock(NO);
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
    self.completionBlock(NO);
}

- (void)loadCSVFile:(NSString *)fileName{
    NSString *pathStr = [NSTemporaryDirectory() stringByAppendingString:fileName];
    NSString *dropboxPath = [NSString stringWithFormat:@"/_customerData/%@",fileName];
    [self.restClient loadFile:dropboxPath intoPath:pathStr];
//    [self.restClient loadFile:fileName atRev:@"/_customerData" intoPath:pathStr];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath{
    NSLog(@"file dest : %@",destPath);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(dropboxDownloadedFile:)]) {
        [self.delegate dropboxDownloadedFile:destPath];
    }
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType{
    
    NSLog(@"file dest : %@",destPath);
    NSLog(@"content type : %@",contentType);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(dropboxDownloadedFile:)]) {
        [self.delegate dropboxDownloadedFile:destPath];
    }
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)destPath contentType:(NSString *)contentType metadata:(DBMetadata *)metadata{
    NSLog(@"file dest : %@",destPath);
    NSLog(@"content type : %@",contentType);
    NSLog(@"file dest : %@",metadata);
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(dropboxDownloadedFile:)]) {
        [self.delegate dropboxDownloadedFile:destPath];
    }
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error{
    NSLog(@"ERROR : %@",error);
}

@end


//- (void)oldParseCSVFileToSDB{
//    UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    indi.center = self.view.center;
//    [self.view addSubview:indi];
//    [indi startAnimating];
//    
//    for (NSString *aFile in self.filesNeedsParse) {
//        [[DropboxHandler shared] loadCSVFile:aFile];
//        //        __block NSInteger index = [self.filesNeedsParse indexOfObject:aFile];
//        [AWSS3Communicator downloadDataFromS3WithKey:[NSString stringWithFormat:@"CustomerDataCSV/%@",aFile]
//                                     completionBlock:^(NSData *data){
//                                         if (data != nil) {
//                                             NSLog(@"successed got file from S3.");
//                                             
//                                             NSString *pathStr = [NSTemporaryDirectory() stringByAppendingString:aFile];
//                                             NSURL *pathURL = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@",pathStr]];
//                                             [data writeToFile:pathStr atomically:YES];
//                                             [self cm_saveCSVToSDB:pathURL withCompletionBlock:^(BOOL successed){
//                                                 if (successed) {
//                                                     NSLog(@"successed parsed CSV file and updated to SDB.");
//                                                     [AWSSDBCommunicator updateValueToSDBWithDomainName:DOMAIN_CSV
//                                                                                               itemName:aFile
//                                                                                                    Key:@"parsedDate"
//                                                                                                  value:[NSDate date].getyyyyMMddhhmmssString
//                                                                                 withMainThreadExecutor:YES
//                                                                                        completionBlock:^(BOOL successed){
//                                                                                            [indi stopAnimating];
//                                                                                            if (successed) {
//                                                                                                NSLog(@"Updated CSV ParsedDate in SDB.");
//                                                                                                [self.csvTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]].accessoryType = UITableViewCellAccessoryCheckmark;
//                                                                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"更新完毕" message:@"成功将CSV文件更新到数据库" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                                                                                [alert show];
//                                                                                                
//                                                                                            }else{
//                                                                                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"警告" message:@"成功将CSV文件更新到数据库，但未能修改CSV文件的解读标示！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                                                                                [alert show];
//                                                                                            }
//                                                                                        }];
//                                                 }else{
//                                                     NSLog(@"Failed to save CSV file to SDB!");
//                                                     [indi stopAnimating];
//                                                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误" message:@"未能成功将CSV文件输入到数据库中！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//                                                     [alert show];
//                                                 }
//                                                 NSError *error;
//                                                 [[NSFileManager defaultManager] removeItemAtPath:pathStr error: &error];
//                                                 if (error) NSLog(@"ERROR :%@",error);
//                                             }];
//                                         }else{
//                                             [indi stopAnimating];
//                                             NSLog(@"Unable to get CSV file from S3!");
//                                         }
//                                     }];
//        //        }
//    }
//    
//    
//    //    NSURL *url = [NSURL URLWithString:csvFilePath];
//    //    [self cm_saveCSVToSDB:url withCompletionBlock:^(BOOL successed){
//    //        NSLog(successed ? @"" : @"Failed to save CSV file to SDB!");
//    //    }];
//}
