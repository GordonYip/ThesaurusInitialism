//
//  ResultsViewController.m
//  ThesaurusInitialism
//
//  Created by Gordon Yip on 3/5/17.
//  Copyright © 2017 Gordon Yip. All rights reserved.
//

#import "ResultsViewController.h"

#import "Globals.h"
#import "ResultsCollectionViewCell.h"
#import "ResultsEntry.h"
#import "ResultsHeaderCollectionViewCell.h"

#define kResultsCollectionViewCellIdentifier @"results-collection-view-cell-identifier"
#define kResultsHeaderCollectionViewCellIdentifier @"results-header-collection-view-cell-identifier"
#define kDefaultCollectionViewCellHeight 50.0
#define kCollectionViewCellLeftPadding 12.0
#define kCollectionViewCellFontSize 16.0

@interface ResultsViewController () <UICollectionViewDelegateFlowLayout>

@end

@implementation ResultsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.navigationItem.title = StringSearchResults;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(tappedDoneButton)];
    }
    return self;
}

- (void)setResultsArray:(NSArray *)resultsArray {
    _resultsArray = [self processResults:resultsArray];
}

- (void)tappedDoneButton {
    [self dismissViewControllerAnimated:YES completion:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationClosedResults object:nil];
}

- (NSArray *)processResults:(NSArray *)resultsArray {
    NSMutableArray *processedResults = [NSMutableArray array];
    for (NSDictionary *entry in resultsArray) {
        NSString *sf = [entry objectForKey:@"sf"];
        NSArray *lfs = [entry objectForKey:@"lfs"];
        NSMutableArray *cumulativeLfs = [NSMutableArray array];
        for (NSDictionary *lfsEntry in lfs) {
            NSString *lf = [lfsEntry objectForKey:@"lf"];
            NSInteger freq = [[lfsEntry objectForKey:@"freq"] integerValue];
            NSInteger since = [[lfsEntry objectForKey:@"since"] integerValue];
            [cumulativeLfs addObject:[ResultsEntry entryWithLongForm:lf frequency:freq since:since isVariation:NO]];
            
            // now process variations
            NSArray *variations = [lfsEntry objectForKey:@"vars"];
            for (NSDictionary *variationEntry in variations) {
                NSString *varLf = [variationEntry objectForKey:@"lf"];
                NSInteger varFreq = [[variationEntry objectForKey:@"freq"] integerValue];
                NSInteger varSince = [[variationEntry objectForKey:@"since"] integerValue];
                [cumulativeLfs addObject:[ResultsEntry entryWithLongForm:varLf frequency:varFreq since:varSince isVariation:YES]];
            }
        }
        
        [processedResults addObject:@{ @"sf" : sf, @"lfs" : cumulativeLfs }];
    }
    return processedResults;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return MAX(1, self.resultsArray.count);
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.resultsArray.count == 0) {
        return 1;
    }
    
    NSDictionary *entry = [self.resultsArray objectAtIndex:section];
    NSArray *lfs = [entry objectForKey:@"lfs"];
    return lfs ? lfs.count : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ResultsCollectionViewCell *cell = (ResultsCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kResultsCollectionViewCellIdentifier forIndexPath:indexPath];
    if (self.resultsArray.count == 0) {
        cell.resultsLabel.text = StringNoSearchResults;
        return cell;
    }
    
    NSDictionary *entry = [self.resultsArray objectAtIndex:indexPath.section];
    NSArray *lfs = [entry objectForKey:@"lfs"];
    ResultsEntry *lfEntry = [lfs objectAtIndex:indexPath.item];
    
    cell.resultsLabel.text = [NSString stringWithFormat:@"lf: %@, freq: %li, since: %li", lfEntry.longForm, (long)lfEntry.frequency, (long)lfEntry.since];
    
    CGRect cellResultsFrame = cell.resultsLabel.frame;
    if (lfEntry.isVariation) {
        cell.resultsLabel.font = [UIFont italicSystemFontOfSize:kCollectionViewCellFontSize];
        cellResultsFrame.origin = CGPointMake(2 * kCollectionViewCellLeftPadding, 0.0);
        cellResultsFrame.size = CGSizeMake(self.view.frame.size.width - (4 * kCollectionViewCellLeftPadding), kDefaultCollectionViewCellHeight);
    } else {
        cell.resultsLabel.font = [UIFont systemFontOfSize:kCollectionViewCellFontSize];
        cellResultsFrame.origin = CGPointMake(kCollectionViewCellLeftPadding, 0.0);
        cellResultsFrame.size = CGSizeMake(self.view.frame.size.width - (2 * kCollectionViewCellLeftPadding), kDefaultCollectionViewCellHeight);
    }
    cell.resultsLabel.frame = cellResultsFrame;
    [cell.resultsLabel sizeToFit];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    if ([UICollectionElementKindSectionHeader isEqualToString:kind]) {
        ResultsHeaderCollectionViewCell *headerCell = (ResultsHeaderCollectionViewCell *)[collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:kResultsHeaderCollectionViewCellIdentifier forIndexPath:indexPath];
        if (self.resultsArray.count == 0) {
            headerCell.headerLabel.text = nil;
        } else {
            NSDictionary *entry = [self.resultsArray objectAtIndex:indexPath.section];
            headerCell.headerLabel.text = [entry objectForKey:@"sf"];
        }
        return headerCell;
    }
    return nil;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.resultsArray.count == 0) {
        return CGSizeZero;
    } else {
        return CGSizeMake(self.view.frame.size.width, kDefaultCollectionViewCellHeight);
    }
}


@end
