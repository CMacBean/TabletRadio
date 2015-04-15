//
//  PLSItem.h
//  Tablet Radio
//
//  Created by Administrator on 25/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PLSItem, Track;

@interface PLSItem : NSManagedObject

@property (nonatomic, retain) NSNumber * position;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) PLSItem *nextPLS;
@property (nonatomic, retain) Track *track;

@end
