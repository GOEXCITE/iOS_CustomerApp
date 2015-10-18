//
//  CMCSVParser.m
//  app_obj
//
//  Created by Tian Tian on 7/12/15.
//  Copyright (c) 2015 goexcite.net. All rights reserved.
//

#import "CMCSVParser.h"
#import "CHCSVParser.h"
#import "CMCustomer.h"

@interface CMCSVParser () <CHCSVParserDelegate>
@property (nonatomic, strong) CHCSVParser       *operator;
@property (nonatomic, strong) NSMutableArray    *lines;
@property (nonatomic, strong) NSMutableArray    *currentLine;

@property (nonatomic, copy) void(^completeParseCMCustomersBlock)(NSError *error, NSArray *result);
@end

@implementation CMCSVParser

+ (instancetype)cm_withFileAtURL:(NSURL *)url{
    return [[CMCSVParser alloc] initWithURL:url];
}

- (instancetype)initWithURL:(NSURL *)url{
    self = [super init];
    if (self) {
        self.operator = [[CHCSVParser alloc] initWithContentsOfDelimitedURL:url delimiter:DELIMITER];
        self.operator.sanitizesFields = YES;
        self.operator.delegate = self;
        return self;
    }
    return nil;
}

- (void)tryParsewithCompletionBlock:(void(^)(NSError *error, NSArray *result))block{
    self.completeParseCMCustomersBlock = block;
    [self.operator parse];
}

- (void)parserDidBeginDocument:(CHCSVParser *)parser {
    NSLog(@"CSV Parser Beginning...");
    self.lines = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didBeginLine:(NSUInteger)recordNumber {
    _currentLine = [[NSMutableArray alloc] init];
}
- (void)parser:(CHCSVParser *)parser didReadField:(NSString *)field atIndex:(NSInteger)fieldIndex {
    [_currentLine addObject:field];
}
- (void)parser:(CHCSVParser *)parser didEndLine:(NSUInteger)recordNumber {
    [_lines addObject:_currentLine];
    _currentLine = nil;
}
- (void)parserDidEndDocument:(CHCSVParser *)parser {
    NSLog(@"CSV Parser Ended.");
    NSArray *getResultCustomers = [self covertLinesToCustomerArray];
//    NSLog(@"customer array :%@",getResultCustomers);
    if (self.completeParseCMCustomersBlock!=nil) {
        self.completeParseCMCustomersBlock(nil,getResultCustomers);
    }
}
- (void)parser:(CHCSVParser *)parser didFailWithError:(NSError *)error {
    NSLog(@"ERROR: %@", error);
    _lines = nil;
    if (self.completeParseCMCustomersBlock!=nil) {
        self.completeParseCMCustomersBlock(error,nil);
    }
}

//! @function covert to customer data

- (NSArray *)covertLinesToCustomerArray{
//    NSLog(@"lines : %@",self.lines);
    NSMutableArray *customerArray = [NSMutableArray array];
    for (NSMutableArray *anItem in self.lines) {
        CMCustomer *new = [[CMCustomer alloc] init];
        new.customerName = [anItem objectAtIndex:0];
        new.pinYin = [anItem objectAtIndex:1];
        new.gender = [anItem objectAtIndex:2];
        new.birth = [anItem objectAtIndex:3];
        new.age = [anItem objectAtIndex:4];
        new.passportId = [anItem objectAtIndex:5];
        new.passportIussedPlace = [anItem objectAtIndex:6];
        new.passportValidDate = [anItem objectAtIndex:7];
        new.location = [anItem objectAtIndex:8];
        new.phoneNumber = [anItem objectAtIndex:9];
        new.mail = [anItem objectAtIndex:10];
        new.wechatID = [anItem objectAtIndex:11];
        new.history = [anItem objectAtIndex:12];
        new.remark = [anItem objectAtIndex:13];
        [customerArray addObject:new];
    }
    self.lines = nil;
    self.currentLine = nil;
    return customerArray;
}


@end
