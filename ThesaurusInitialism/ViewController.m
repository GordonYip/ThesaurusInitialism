//
//  ViewController.m
//  ThesaurusInitialism
//
//  Created by Gordon Yip on 3/5/17.
//  Copyright © 2017 Gordon Yip. All rights reserved.
//

#import "ViewController.h"

#import "AFNetworking.h"
#import "AFNetworkReachabilityManager.h"
#import "Globals.h"
#import "MBProgressHUD.h"
#import "ResultsViewController.h"

#define kThesaurusInitialismURL @"http://www.nactem.ac.uk/software/acromine/"
#define kThesaurusInitialismEndpoint @"dictionary.py"
#define kResultsViewControllerStoryboardID @"ResultsViewController"
#define kRecentSearchesTableViewCellIdentifier @"recent-search-cell-identifier"

@interface ViewController ()

@property (nonatomic, strong) NSMutableArray<NSString *> *recentSearches;

@end

@implementation ViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCloseResultsViewController:) name:NotificationClosedResults object:nil];
        _recentSearches = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.recentSearchesTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRecentSearchesTableViewCellIdentifier];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [self.entryTextField becomeFirstResponder];
}

- (void)showEmptySearchTermMessage {
    UIAlertController *emptySearchController = [UIAlertController alertControllerWithTitle:StringNoSearchTerm message:StringNothingToSearch preferredStyle:UIAlertControllerStyleAlert];
    [emptySearchController addAction:[UIAlertAction actionWithTitle:StringOK style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:^(void) {
            [self.entryTextField becomeFirstResponder];
        }];
    }]];
    [self presentViewController:emptySearchController animated:YES completion:nil];
}

- (void)showAlertTitle:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:StringOK style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doSearch:(NSString *)string {
    NSString *searchString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (searchString == nil || searchString.length == 0) {
        [self showEmptySearchTermMessage];
        return;
    }
    
    if ([[AFNetworkReachabilityManager sharedManager] isReachable] == NO) {
        [self showAlertTitle:StringError message:StringNoNetworkForSearch];
        return;
    }
    
    NSURL *baseURL = [NSURL URLWithString:kThesaurusInitialismURL];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 10.0;
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/plain"];
    NSDictionary *params = @{ @"sf" : searchString };
    
    [self.recentSearches insertObject:searchString atIndex:0];
    [self.recentSearchesTableView reloadData];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = [NSString stringWithFormat:@"Searching for %@...", searchString];
    [manager GET:kThesaurusInitialismEndpoint
      parameters:params
        progress:^(NSProgress *downloadProgress) {
            hud.progressObject = downloadProgress;
        }
         success:^(NSURLSessionDataTask *task, id responseObject) {
             NSAssert([responseObject isKindOfClass:[NSArray class]], @"responseObject should be an array");
             [hud hideAnimated:YES];
             [self handleResponse:responseObject];
         }
         failure:^(NSURLSessionDataTask *task, NSError *error) {
             [hud hideAnimated:YES];
             [self showAlertTitle:StringError message:error.localizedDescription];
         }];
}

- (void)handleResponse:(NSArray *)responseObject {
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    ResultsViewController *resultsVC = [mainStoryboard instantiateViewControllerWithIdentifier:kResultsViewControllerStoryboardID];
    resultsVC.resultsArray = responseObject;
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:resultsVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

- (void)didCloseResultsViewController:(NSNotification *)notification {
    self.entryTextField.text = nil;
    [self.entryTextField becomeFirstResponder];
}

#pragma mark - IBAction responders

- (IBAction)didTapGoButton:(id)sender {
    [self.entryTextField resignFirstResponder];
    [self doSearch:self.entryTextField.text];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self doSearch:self.entryTextField.text];
    return YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *searchString = [self.recentSearches objectAtIndex:indexPath.item];
    [self doSearch:searchString];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recentSearches.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRecentSearchesTableViewCellIdentifier forIndexPath:indexPath];
    cell.textLabel.text = [self.recentSearches objectAtIndex:indexPath.item];
    return cell;
}

@end
