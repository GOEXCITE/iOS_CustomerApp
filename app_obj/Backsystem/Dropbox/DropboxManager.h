//
//  DropboxManager.h
//  OrigamiBB
//
//  Created by Tian Tian on 11/20/14.
//  Copyright (c) 2014 Forestism. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <DropboxSDK/DropboxSDK.h>

#define DROPBOX_APP_KEY         @"it9wsxfduroa9k2"
#define DROPBOX_APP_SECRET      @"bw7k32ftuohpizn"

@interface DropboxManager : NSObject <DBSessionDelegate,DBNetworkRequestDelegate,DBRestClientDelegate>

@property (nonatomic, readonly) BOOL    isWorking;
//@property (nonatomic, readonly) float   progress;

+ (instancetype)shared;

- (void)setAutoUnlinkSessions:(BOOL)autoUnlinkSessions;

- (void)linkSessionAndShow;

- (void)unlinkSession;

- (void)handleURL:(NSURL *)url sendFileToDropboxWithFromFileLocation:(NSString *)tFromFileLocation toFolder:(NSString *)tToFolder toFileName:(NSString *)tToFileName;

@end
