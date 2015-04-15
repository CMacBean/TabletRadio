//
//  SortByController.h
//  Tablet Radio
//
//  Created by Administrator on 06/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SortByController <NSObject>
@required
-(void)selectedSort:(NSString *)sort;
@end

@interface SortByController : UITableViewController

@property (nonatomic, strong) NSMutableArray *sortOptions;
@property (nonatomic, weak) id delegate;

@end
