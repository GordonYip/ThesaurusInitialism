//
//  ResultsViewController.h
//  ThesaurusInitialism
//
//  Created by Gordon Yip on 3/5/17.
//  Copyright © 2017 Gordon Yip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ResultsViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, copy) NSArray *resultsArray;

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;

@end
