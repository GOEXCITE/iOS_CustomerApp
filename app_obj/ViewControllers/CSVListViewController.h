//
//  CSVListViewController.h
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <DropboxSDK/DropboxSDK.h>

@interface CSVListViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UITableView *csvTable;

@end

#define DROPBOX_APP_KEY         @"it9wsxfduroa9k2"
#define DROPBOX_APP_SECRET      @"bw7k32ftuohpizn"

@interface DropboxHandler : NSObject

+ (instancetype)shared;

@property (nonatomic, strong) NSArray   *csvList;
@property (nonatomic, strong) void(^completionBlock)(BOOL successed) ;

- (void)loadCSVFiles;

@end
