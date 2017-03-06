//
//  ResultsEntry.h
//  ThesaurusInitialism
//
//  Created by Gordon Yip on 3/5/17.
//  Copyright © 2017 Gordon Yip. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultsEntry : NSObject

@property (nonatomic, copy, readonly) NSString *longForm;
@property (nonatomic, assign, readonly) NSInteger frequency;
@property (nonatomic, assign, readonly) NSInteger since;
@property (nonatomic, assign, readonly) BOOL isVariation;

+ (ResultsEntry *)entryWithLongForm:(NSString *)longForm
                          frequency:(NSInteger)frequency
                              since:(NSInteger)since
                        isVariation:(BOOL)isVariation;

- (instancetype)initWithLongForm:(NSString *)longForm
                       frequency:(NSInteger)frequency
                           since:(NSInteger)since
                     isVariation:(BOOL)isVariation;

@end
