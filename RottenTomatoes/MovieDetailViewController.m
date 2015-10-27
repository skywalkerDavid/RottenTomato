//
//  MovieDetailViewController.m
//  
//
//  Created by David Wang on 10/26/15.
//
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *posterImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratingLabel;
@property (weak, nonatomic) IBOutlet UILabel *mpaaRateLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsis;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *backgroundView;

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = self.movie[@"title"];
    
    NSString *originalUrlString = [NSString stringWithString:self.movie[@"posters"][@"detailed"]];
    NSRange range = [originalUrlString rangeOfString:@".*cloudfront.net/"
                                             options:NSRegularExpressionSearch];
    NSString *detailUrlString = [originalUrlString stringByReplacingCharactersInRange:range
                                                                        withString:@"https://content6.flixster.com/"];
    
    NSURL *thumnailUrl = [NSURL URLWithString:originalUrlString];
    NSURL *detailUrl = [NSURL URLWithString:detailUrlString];
    [self.posterImageView setImageWithURL:thumnailUrl];
    [self.posterImageView setImageWithURL:detailUrl];
    
    [self.titleLabel setText:[NSString stringWithFormat:@"%@ (%@)", self.movie[@"title"], self.movie[@"year"]]];
    [self.ratingLabel setText:[NSString stringWithFormat:@"Critics Score: %@, Audience Score: %@", self.movie[@"ratings"][@"critics_score"], self.movie[@"ratings"][@"audience_score"]]];
    [self.mpaaRateLabel setText:self.movie[@"mpaa_rating"]];
    [self.synopsis setText:self.movie[@"synopsis"]];
    [self.synopsis sizeToFit];

    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.synopsis.frame.origin.y + self.synopsis.frame.size.height);
    self.backgroundView.frame = CGRectMake(self.backgroundView.frame.origin.x, self.backgroundView.frame.origin.y, self.backgroundView.frame.size.width, self.scrollView.frame.size.height);
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
