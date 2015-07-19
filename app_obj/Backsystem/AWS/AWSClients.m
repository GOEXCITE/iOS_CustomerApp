//
//  AWSClients.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "AWSClients.h"

@implementation AWSClients
{
    AWSS3                   *s3Manager;
    AWSS3TransferManager    *s3TransferManager;
    AWSSimpleDB             *sdbManager;
    //    AWSSNS                  *snsManager;
}

+ (instancetype)sharedInstance{
    static AWSClients *sharedClass = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedClass = [[self alloc]init];
    });
    return sharedClass;
}

static AWSStaticCredentialsProvider *CredentialsProvider(){
    return [[AWSStaticCredentialsProvider alloc] initWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:AWSRegionAPNortheast1 credentialsProvider:CredentialsProvider()];
        [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;
    }
    return self;
}

- (AWSSimpleDB *)sdb{
    if (!sdbManager) {
        if (SDBRegionType() != AWSRegionUnknown) {
            AWSServiceConfiguration *congifuration = [[AWSServiceConfiguration alloc] initWithRegion:SDBRegionType() credentialsProvider:CredentialsProvider()];
            [AWSSimpleDB registerSimpleDBWithConfiguration:congifuration forKey:@"sdb_tokyo"];
            sdbManager = [AWSSimpleDB SimpleDBForKey:@"sdb_tokyo"];
        }else{
            sdbManager = [AWSSimpleDB defaultSimpleDB];
        }
    }
    return sdbManager;
}

- (AWSS3 *)s3{
    if (!s3Manager) {
        if (S3RegionType() != AWSRegionUnknown) {
            AWSServiceConfiguration *congifuration = [[AWSServiceConfiguration alloc] initWithRegion:S3RegionType() credentialsProvider:CredentialsProvider()];
            [AWSS3 registerS3WithConfiguration:congifuration forKey:@"s3_tokyo"];
            s3Manager = [AWSS3 S3ForKey:@"s3_tokyo"];
        }else{
            s3Manager = [AWSS3 defaultS3];
        }
    }
    return s3Manager;
}

- (AWSS3TransferManager *)s3Transfer{
    if (!s3TransferManager) {
        if (S3RegionType() != AWSRegionUnknown) {
            AWSServiceConfiguration *congifuration = [[AWSServiceConfiguration alloc] initWithRegion:S3RegionType() credentialsProvider:CredentialsProvider()];
            [AWSS3TransferManager registerS3TransferManagerWithConfiguration:congifuration forKey:@"s3Mgr_tokyo"];
            s3TransferManager = [AWSS3TransferManager S3TransferManagerForKey:@"s3Mgr_tokyo"];
        }else{
            s3TransferManager = [AWSS3TransferManager defaultS3TransferManager];
        }
    }
    return s3TransferManager;
}

@end
