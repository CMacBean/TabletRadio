//
//  ItemCell.h
//  Tablet Radio
//
//  Created by Administrator on 22/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *lengthLabel;
@property (nonatomic) BOOL isPlaying;

@end
