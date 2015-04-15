//
//  ItemCell.m
//  Tablet Radio
//
//  Created by Administrator on 22/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "ItemCell.h"

@implementation ItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    UIImage *background = nil;
    if (selected) {
        background = [UIImage imageNamed:@"CellSelected"];
    } else if (self.isPlaying) {
        background = [UIImage imageNamed:@"cellIsPlaying"];
    } else {
        background = [UIImage imageNamed:@"Cell"];
    }

    UIImageView *cellBackgroundView = [[UIImageView alloc] initWithImage:background];
    cellBackgroundView.image = background;
    self.backgroundView = cellBackgroundView;
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    // Configure the view for the selected state
}

@end
