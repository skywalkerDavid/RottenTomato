//
//  ViewController.m
//  RottenTomatoes
//
//  Created by David Wang on 10/20/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "MoviesViewController.h"
#import "MoviesTableViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *movies;
@property (strong, nonatomic) NSArray *searchResults;
@property (weak, nonatomic) IBOutlet UIView *networkErrorAlertView;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@end

@implementation MoviesViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 3.0;
    [self.networkErrorAlertView setHidden:YES];
    
    self.searchBar.delegate = self;
    
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    [self onRefresh];
}


- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if (searchText.length == 0) {
        [self.searchBar setShowsCancelButton:NO];
        [self.searchBar resignFirstResponder];
    } else {
        [self.searchBar setShowsCancelButton:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@", searchText];
        self.searchResults = [self.movies filteredArrayUsingPredicate:predicate];
    }
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text=@"";
    [searchBar setShowsCancelButton:NO];
    [searchBar resignFirstResponder];
    self.searchResults = self.movies;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.searchResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MoviesTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"movieCell"];
    cell.titleLabel.text = self.searchResults[indexPath.row][@"title"];
    cell.synopsisLabel.text = self.searchResults[indexPath.row][@"synopsis"];
    
    [self fadeInImages:self.searchResults[indexPath.row][@"posters"][@"thumbnail"] CellImageView:cell.posterImageView];
    
    cell.mpaaRateLabel.text = self.searchResults[indexPath.row][@"mpaa_rating"];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@%@", self.searchResults[indexPath.row][@"runtime"], @"min"];

    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    if ([@"Spilled" isEqualToString:self.searchResults[indexPath.row][@"ratings"][@"audience_rating"]])
        attachment.image = [UIImage imageNamed:@"rotten.png"];
    else
        attachment.image = [UIImage imageNamed:@"tomato.png"];

    NSAttributedString *attachmentString = [NSAttributedString attributedStringWithAttachment:attachment];
    NSMutableString *ratingString = [NSMutableString stringWithFormat:@" %@%%", self.searchResults[indexPath.row][@"ratings"][@"audience_score"]];

    NSMutableAttributedString *ratingStringWithAttachment = [[NSMutableAttributedString alloc] initWithAttributedString:attachmentString];
    NSAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:ratingString];
    [ratingStringWithAttachment appendAttributedString:attributedString];
    cell.ratingLabel.attributedText = ratingStringWithAttachment;

    cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(nullable id)sender {
    MovieDetailViewController *detailsViewController = [segue destinationViewController];
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    NSDictionary *movie = self.searchResults[indexPath.row];
    detailsViewController.movie = movie;
}

- (void)onRefresh {
    NSString *urlString = @"https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json";
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    self.movies = responseDictionary[@"movies"];
                                                    self.searchResults = self.movies;
                                                    [self.tableView reloadData];
                                                    
                                                    [self.networkErrorAlertView setHidden:YES];
                                                    [self.tableView setHidden:NO];
                                                    NSLog(@"Response: %@", responseDictionary);
                                                } else {
                                                    [self.networkErrorAlertView setHidden:NO];
                                                    [self.tableView setHidden:YES];
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                                [self.refreshControl endRefreshing];
                                            }];
    [task resume];
}

- (void)fadeInImages:(NSString*)url CellImageView:(UIImageView*) imageView {
    NSURL *imageUrl = [NSURL URLWithString:url];
    
    NSURLRequest *imageUrlRequest = [NSURLRequest requestWithURL:imageUrl];
    __weak UIImageView *weakSelf = imageView;
    [imageView setImageWithURLRequest:imageUrlRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        UIImage *cachedImage = [[[weakSelf class] sharedImageCache] cachedImageForRequest:request];
        if (cachedImage) // image was cached
            [weakSelf setImage:image];
        else
            [UIView transitionWithView:weakSelf duration:0.5f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                [weakSelf setImage:image];
            } completion:nil];
    } failure:nil];
}

@end
