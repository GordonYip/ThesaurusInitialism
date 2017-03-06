//
//  ViewController.h
//  ThesaurusInitialism
//
//  Created by Gordon Yip on 3/5/17.
//  Copyright © 2017 Gordon Yip. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UITextField *entryTextField;
@property (nonatomic, weak) IBOutlet UITableView *recentSearchesTableView;

- (IBAction)didTapGoButton:(id)sender;

@end

