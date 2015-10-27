//
//  MoviesTableViewCell.m
//  RottenTomatoes
//
//  Created by David Wang on 10/20/15.
//  Copyright © 2015 David Wang. All rights reserved.
//

#import "MoviesTableViewCell.h"

@implementation MoviesTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    [self changeColor:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [self changeColor:highlighted];
}

- (void)changeColor:(BOOL)isChange {
    if (isChange) {
        self.synopsisLabel.textColor = [UIColor whiteColor];
    } else {
        self.synopsisLabel.textColor = [UIColor grayColor];
    }
}

@end
