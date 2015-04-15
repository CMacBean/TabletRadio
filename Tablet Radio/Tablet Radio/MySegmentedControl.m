//
//  MySegmentedControl.m
//  Tablet Radio
//
//  Created by Administrator on 20/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "MySegmentedControl.h"

@implementation MySegmentedControl

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithItems:(NSArray *)items {
    self = [super initWithItems:items];
    if (self) {
        // Initialization code
        
        // Set divider images
        [self setDividerImage:[UIImage imageNamed:@"NoneSelectDivide"]
          forLeftSegmentState:UIControlStateNormal
            rightSegmentState:UIControlStateNormal
                   barMetrics:UIBarMetricsDefault];
        [self setDividerImage:[UIImage imageNamed:@"LeftSelectDivide"]
          forLeftSegmentState:UIControlStateSelected
            rightSegmentState:UIControlStateNormal
                   barMetrics:UIBarMetricsDefault];
        [self setDividerImage:[UIImage imageNamed:@"RightSelectDivide"]
          forLeftSegmentState:UIControlStateNormal
            rightSegmentState:UIControlStateSelected
                   barMetrics:UIBarMetricsDefault];
        
        // Set background images
        UIImage *normalBackgroundImage = [UIImage imageNamed:@"NormalBckGd"];
        [self setBackgroundImage:normalBackgroundImage
                        forState:UIControlStateNormal
                      barMetrics:UIBarMetricsDefault];
        UIImage *selectedBackgroundImage = [UIImage imageNamed:@"SelectedBckGd"];
        [self setBackgroundImage:selectedBackgroundImage
                        forState:UIControlStateSelected
                      barMetrics:UIBarMetricsDefault];

        CGFloat width = selectedBackgroundImage.size.width;
        
        [self setContentPositionAdjustment:UIOffsetMake(width / 4, 0)
                            forSegmentType:UISegmentedControlSegmentLeft
                                barMetrics:UIBarMetricsDefault];
        [self setContentPositionAdjustment:UIOffsetMake(- width / 4, 0)
                            forSegmentType:UISegmentedControlSegmentRight
                                barMetrics:UIBarMetricsDefault];
        
    }
    return self;
}

@end
