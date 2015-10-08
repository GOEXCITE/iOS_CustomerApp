//
//  AppDelegate.m
//  app_obj
//
//  Created by Tian Tian on 7/11/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AppDelegate.h"

#import "Brain.h"

#import "DropboxManager.h"

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
    
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:DROPBOX_APP_KEY
                            appSecret:DROPBOX_APP_SECRET
                            root:kDBRootDropbox]; // either kDBRootAppFolder or kDBRootDropbox
    [DBSession setSharedSession:dbSession];
    
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
            self.restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
            self.restClient.delegate = self;
            [self.restClient loadMetadata:@"/"];
            
        }
        return YES;
    }
    return NO;
}

- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory) {
        NSLog(@"Folder '%@' contains:", metadata.path);
        for (DBMetadata *file in metadata.contents) {
            NSLog(@"	%@", file.filename);
        }
    }
}

- (void)restClient:(DBRestClient *)client
loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
}

@end
