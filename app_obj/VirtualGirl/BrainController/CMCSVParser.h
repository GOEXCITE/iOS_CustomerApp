//
//  CMCSVParser.h
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DELIMITER   '\t'


@interface CMCSVParser : NSObject

+ (instancetype)cm_withFileAtURL:(NSURL *)url;

- (void)tryParsewithCompletionBlock:(void(^)(NSError *error, NSArray *result))block;

@property (nonatomic, readonly) NSArray *resultCustomerList;

@end
