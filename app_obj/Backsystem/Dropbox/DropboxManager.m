//
//  DropboxManager.m
//  OrigamiBB
//
//  Created by Tian Tian on 11/20/14.
//  Copyright (c) 2014 Forestism. All rights reserved.
//

#import "DropboxManager.h"
//#import "M13ProgressViewSegmentedRing.h"

@interface DropboxManager ()

@property (nonatomic, strong) DBRestClient* restClient;

@property (nonatomic, assign) BOOL          autoUnlinkSessions;

//@property (nonatomic, strong) M13ProgressViewSegmentedRing *progressView;
@end


@implementation DropboxManager
{
    NSString*   hashData;
    
    NSString    *fromFileLocation;
    NSString    *toFolder;
    NSString    *toFileName;
    
    BOOL        working;
}

+ (instancetype)shared{
    static DropboxManager *defaultClass = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        defaultClass = [[DropboxManager alloc] init];
    });
    
    return defaultClass;
}

- (instancetype)init{
    self = [super init];
    if (!self) return nil;
//    [self startDropboxSession];
    return self;
}

//- (M13ProgressViewSegmentedRing *)progressView{
//    if (!_progressView) {
//        _progressView = [[M13ProgressViewSegmentedRing alloc] initWithFrame:CGRectMake(0, 0, 150.f, 150.f)];
//        _progressView.center = CGPointMake(CGRectGetMidX([UIScreen mainScreen].bounds), CGRectGetMidY([UIScreen mainScreen].bounds));
//        _progressView.alpha = 0;
//    }
//    return _progressView;
//}

- (void)setAutoUnlinkSessions:(BOOL)tAutoUnlinkSessions{
    _autoUnlinkSessions = tAutoUnlinkSessions;
}

- (void)startDropboxSession{
    NSString* appKey = DROPBOX_APP_KEY;
    NSString* appSecret = DROPBOX_APP_SECRET;
    NSString *root = kDBRootAppFolder; // Should be set to either kDBRootAppFolder or kDBRootDropbox
    // You can determine if you have App folder access or Full Dropbox along with your consumer key/secret
    // from https://dropbox.com/developers/apps
    
    // Look below where the DBSession is created to understand how to use DBSession in your app
    
    NSString* errorMsg = nil;
    if ([appKey rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app key correctly in DBRouletteAppDelegate.m";
    } else if ([appSecret rangeOfCharacterFromSet:[[NSCharacterSet alphanumericCharacterSet] invertedSet]].location != NSNotFound) {
        errorMsg = @"Make sure you set the app secret correctly in DBRouletteAppDelegate.m";
    } else if ([root length] == 0) {
        errorMsg = @"Set your root to use either App Folder of full Dropbox";
    } else {
        NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
        NSData *plistData = [NSData dataWithContentsOfFile:plistPath];
        NSDictionary *loadedPlist = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:nil error:nil];
        NSString *scheme = [[[[loadedPlist objectForKey:@"CFBundleURLTypes"] objectAtIndex:0] objectForKey:@"CFBundleURLSchemes"] objectAtIndex:0];
        if ([scheme isEqual:@"db-APP_KEY"]) {
            errorMsg = @"Set your URL scheme correctly in DBRoulette-Info.plist";
        }
    }
    
    DBSession* session = [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    session.delegate = self; // DBSessionDelegate methods allow you to handle re-authenticating
    [DBSession setSharedSession:session];
    
    [DBRequest setNetworkRequestDelegate:self];
    
    if (errorMsg != nil) {
        [[[UIAlertView alloc]
          initWithTitle:@"Error Configuring Session" message:errorMsg
          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (void)linkSessionAndShow{
    UIWindow *newWin = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UIViewController *new = [UIViewController new];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:new];
    navi.navigationBarHidden = YES;
    [newWin addSubview:navi.view];
    [newWin makeKeyAndVisible];
    [[DBSession sharedSession] linkFromController:navi];
}

- (void)unlinkSession{
    [[DBSession sharedSession] unlinkAll];
}

- (void)handleURL:(NSURL *)url sendFileToDropboxWithFromFileLocation:(NSString *)tFromFileLocation toFolder:(NSString *)tToFolder toFileName:(NSString *)tToFileName{
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            [self setWorking:YES];
            
            fromFileLocation = tFromFileLocation;
            
            toFolder = tToFolder;
            toFileName = tToFileName;
            
//            [self.restClient searchPath:tToFolder forKeyword:tToFileName];
            [self.restClient createFolder:tToFolder];
        }
    }
}

- (void)uploadFile{
    [self.restClient uploadFile:toFileName toPath:toFolder withParentRev:nil fromPath:fromFileLocation];
}

- (void)setWorking:(BOOL)isWorking {
    if (working == isWorking) return;
    working = isWorking;
}

- (DBRestClient*)restClient {
    if (_restClient == nil) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

#pragma mark check file if existed

- (void)restClient:(DBRestClient *)restClient loadedSearchResults:(NSArray *)results forPath:(NSString *)path keyword:(NSString *)keyword{
    if (results.count>0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING!" message:@"File already existed.\n Do you want to overwrite it?" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
        [alert show];
    }else{
        [self.restClient loadMetadata:toFolder withHash:hashData];
    }
}

#pragma mark create folder

- (void)restClient:(DBRestClient *)client createdFolder:(DBMetadata *)folder{
    if ([folder.path isEqualToString:toFolder]) {
        [self.restClient loadMetadata:toFolder withHash:hashData];
    }
}

- (void)restClient:(DBRestClient *)client createFolderFailedWithError:(NSError *)error{
//    NSLog(@"%@",error);
    [self.restClient loadMetadata:toFolder withHash:hashData];
}

#pragma mark DBRestClientDelegate methods

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    hashData = metadata.hash;
//    NSLog(@"received hash data : %@",hashData);
    
//    NSArray* validExtensions = [NSArray arrayWithObjects:@"pdf", nil];
//    NSMutableArray* pdfPaths = [NSMutableArray new];
//    for (DBMetadata* child in metadata.contents) {
//        NSString* extension = [[child.path pathExtension] lowercaseString];
//        if (!child.isDirectory && [validExtensions indexOfObject:extension] != NSNotFound) {
//            [pdfPaths addObject:child.path];
//        }
//    }
////    NSLog(@"pdf pathes : %@",pdfPaths);
    
    [self uploadFile];
}

- (void)restClient:(DBRestClient*)client metadataUnchangedAtPath:(NSString*)path {
    NSLog(@"11");
}

- (void)restClient:(DBRestClient*)client loadMetadataFailedWithError:(NSError*)error {
    NSLog(@"restClient:loadMetadataFailedWithError: %@", [error localizedDescription]);
    [self displayError];
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient*)client loadedThumbnail:(NSString*)destPath {
    NSLog(@"12");
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient*)client loadThumbnailFailedWithError:(NSError*)error {
    [self setWorking:NO];
}

- (void)displayError {
    [[[UIAlertView alloc]
       initWithTitle:@"Error Loading Photo" message:@"There was an error uploading your file."
       delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
     show];
}

#pragma mark -
#pragma mark DBSessionDelegate methods

- (void)sessionDidReceiveAuthorizationFailure:(DBSession*)session userId:(NSString *)userId {
    //    relinkUserId = [userId retain];
    [[[UIAlertView alloc]
      initWithTitle:@"Dropbox Session Ended" message:@"Do you want to relink?" delegate:self
      cancelButtonTitle:@"Cancel" otherButtonTitles:@"Relink", nil] show];
}

#pragma mark -
#pragma mark DBNetworkRequestDelegate methods

static int outstandingRequests;

- (void)networkRequestStarted {
    outstandingRequests++;
    if (outstandingRequests == 1) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    }
}

- (void)networkRequestStopped {
    outstandingRequests--;
    if (outstandingRequests == 0) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

#pragma - DBRestClient

- (void)restClient:(DBRestClient *)client  uploadedFile:(NSString *)destPath from:(NSString *)srcPath{
    NSLog(@"1");
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath from:(NSString *)srcPath metadata:(DBMetadata *)metadata{
    NSLog(@"uploadedFileToDropbox : %@; toPath:%@; metadata:%lld",destPath,srcPath,metadata.totalBytes);
//    [self.progressView performAction:M13ProgressViewActionSuccess animated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self.progressView removeFromSuperview];
//        self.progressView = nil;
    });
    [self setWorking:NO];
    if (_autoUnlinkSessions) {
        [self unlinkSession];
    }
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath fromUploadId:(NSString *)uploadId metadata:(DBMetadata *)metadata{
    NSLog(@"3");
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient *)client uploadedFileChunk:(NSString *)uploadId newOffset:(unsigned long long)offset fromFile:(NSString *)localPath expires:(NSDate *)expiresDate{
    NSLog(@"4");
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient *)client uploadFileChunkFailedWithError:(NSError *)error{
    NSLog(@"uploadFileChunkFailedWithError : %@",[error localizedDescription]);
    [self setWorking:NO];
}

- (void)restClient:(DBRestClient *)client uploadFileChunkProgress:(CGFloat)progress forFile:(NSString *)uploadId offset:(unsigned long long)offset fromPath:(NSString *)localPath{
    NSLog(@"uploadFileChunkProgress: %f",progress);
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error{
    NSLog(@"Upload Error : %@",[error localizedDescription]);
}

- (void)restClient:(DBRestClient *)client uploadFromUploadIdFailedWithError:(NSError *)error{
    NSLog(@"Upload Error : %@",[error localizedDescription]);
}

- (void)restClient:(DBRestClient *)client uploadProgress:(CGFloat)progress forFile:(NSString *)destPath from:(NSString *)srcPath{
    NSLog(@"uploading progress : %f",progress);
//    if (self.progressView.alpha==0) {
//        [[[UIApplication sharedApplication] keyWindow] addSubview:self.progressView];
//        self.progressView.alpha = 1.f;
//    }
//    [self.progressView setProgress:progress animated:YES];
}

@end
