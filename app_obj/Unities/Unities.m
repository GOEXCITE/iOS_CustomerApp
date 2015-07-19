//
//  Unities.m
//  app_obj
//
//  Created by Tian Tian on 7/13/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "Unities.h"

@implementation NSDate (UnityExtension)

- (NSString *)getyyyy{
    NSDateFormatter *aFormatter = [[NSDateFormatter alloc] init];
    [aFormatter setDateFormat:@"yyyy"];
    [aFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSCalendarIdentifierISO8601]];
    return [aFormatter stringFromDate:self];
}

- (NSString *)getyyyyMMddString{
    NSDateFormatter *aFormatter = [[NSDateFormatter alloc] init];
    [aFormatter setDateFormat:@"yyyyMMdd"];
    [aFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSCalendarIdentifierISO8601]];
    return [aFormatter stringFromDate:self];
}

- (NSString *)getyyyyMMddhhmmssString{
    NSDateFormatter *aFormatter = [[NSDateFormatter alloc] init];
    [aFormatter setDateFormat:@"yyyyMMdd hh:mm:ss"];
    [aFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:NSCalendarIdentifierISO8601]];
    return [aFormatter stringFromDate:self];
}

@end

