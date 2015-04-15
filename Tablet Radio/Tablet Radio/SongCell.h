//
//  SongCell.h
//  Tablet Radio
//
//  Created by Administrator on 01/01/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SongCell : UITableViewCell

@property (nonatomic, weak) IBOutletCollection(UILabel) NSArray *songLabel;
@property (nonatomic, weak) IBOutletCollection(UILabel) NSArray *artistLabel;
@property (nonatomic, weak) IBOutletCollection(UILabel) NSArray *lengthLabel;

@end
