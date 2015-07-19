//
//  CMCSV.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOMAIN_CSV     @"CM_CSV"

@interface CMCSV : NSObject
@property (nonatomic, strong) NSString  *fileName;
//@property (nonatomic, strong) NSString  *filePath;
@property (nonatomic, strong) NSString  *parsedDate;
@end
