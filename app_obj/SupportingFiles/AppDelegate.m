//
//  AppDelegate.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AppDelegate.h"

#import "Brain.h"

#import "CSVListViewController.h"

//<key>NSAppTransportSecurity</key>
//<dict>
//<key>NSAllowsArbitraryLoads</key>
//<true/>
//</dict>

@interface AppDelegate () <DBRestClientDelegate>
@property (nonatomic, strong) DBRestClient  *restClient;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Set the initial view controller to be the root view controller of the window object
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"iPhoneMain" bundle:nil];
    UIViewController *initialViewController = storyBoard.instantiateInitialViewController;
    self.window.rootViewController  = initialViewController;
    
    // Set the window object to be the key window and show it
    [self.window makeKeyAndVisible];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    NSLog(@"%@",url);
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            NSLog(@"App linked successfully!");
            // At this point you can start making API calls
            [[DropboxHandler shared] loadCSVFileList];
        }
        return YES;
    }
    return NO;
}



@end
