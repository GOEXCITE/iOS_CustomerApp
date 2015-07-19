//
//  AWSConstant.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <AWSCore.h>

#define ACCESS_KEY_ID               @"AKIAIJ37HNDPBT5MO2PQ"
#define SECRET_KEY                  @"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"

#define S3_BUCKET_NAME              @"japan.travel"

static inline AWSRegionType S3RegionType (){
    return AWSRegionAPNortheast1;
}

static inline AWSRegionType SDBRegionType (){
    return AWSRegionAPNortheast1;
}
