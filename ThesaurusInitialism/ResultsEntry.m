//
//  ResultsEntry.m
//  ThesaurusInitialism
//
//  Created by Gordon Yip on 3/5/17.
//  Copyright © 2017 Gordon Yip. All rights reserved.
//

#import "ResultsEntry.h"

@interface ResultsEntry()

@property (nonatomic, copy, readwrite) NSString *longForm;
@property (nonatomic, assign, readwrite) NSInteger frequency;
@property (nonatomic, assign, readwrite) NSInteger since;
@property (nonatomic, assign, readwrite) BOOL isVariation;

@end

@implementation ResultsEntry

+ (ResultsEntry *)entryWithLongForm:(NSString *)longForm
                          frequency:(NSInteger)frequency
                              since:(NSInteger)since isVariation:(BOOL)isVariation {
    return [[ResultsEntry alloc] initWithLongForm:longForm frequency:frequency since:since isVariation:isVariation];
}

- (instancetype)initWithLongForm:(NSString *)longForm
                       frequency:(NSInteger)frequency
                           since:(NSInteger)since
                     isVariation:(BOOL)isVaration {
    if (self = [super init]) {
        _longForm = longForm;
        _frequency = frequency;
        _since = since;
        _isVariation = isVaration;
    }
    return self;
}

@end
