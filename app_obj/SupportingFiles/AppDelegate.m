//
//  AppDelegate.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AppDelegate.h"
#import "SlideNavigationController.h"
#import "LeftMenuViewController.h"

#import "Brain.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    LeftMenuViewController *leftMenu = [[UIStoryboard storyboardWithName:@"iPhoneMain" bundle:nil] instantiateViewControllerWithIdentifier:@"LeftMenuViewController"];
    [SlideNavigationController sharedInstance].leftMenu = leftMenu;
    
    //! @test AWS
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:KEY_USER_TYPE];
//    [AWSS3Communicator getFileListInS3WithFrefixKey:@"CustomerDataCSV/" executor:[AWSExecutor mainThreadExecutor] completionBlock:nil];
//    AWSStaticCredentialsProvider *c = [[AWSStaticCredentialsProvider alloc] initWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
//    AWSServiceConfiguration *congifuration = [[AWSServiceConfiguration alloc] initWithRegion:S3RegionType() credentialsProvider:c];
//    [AWSS3TransferManager registerS3TransferManagerWithConfiguration:congifuration forKey:@"s3Mgr_tokyo"];
//    
//    AWSS3TransferManagerDownloadRequest *downReq = [AWSS3TransferManagerDownloadRequest new];
//    downReq.key = @"CustomerDataCSV/aaa.txt";
//    downReq.bucket = @"japan.travel";
//    [[[AWSS3TransferManager S3TransferManagerForKey:@"s3Mgr_tokyo"] download:downReq] continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask *task) {
//        if (task.error != nil){
//            if(task.error.code != AWSS3TransferManagerErrorCancelled && task.error.code != AWSS3TransferManagerErrorPaused){
//                NSLog(@"%s Error: [%@]",__PRETTY_FUNCTION__, task.error);
//            }
//        } else {
//            //            downloadCount++;
//            AWSS3TransferManagerDownloadOutput *result = task.result;
//            NSData *bodyData = [NSData dataWithContentsOfURL:result.body];
//            if (bodyData && bodyData.length>0) {
//                NSLog(@"successful!");
//            }
//            return task;
//        }
//        return nil;
//    }];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
