//
//  Track.h
//  Tablet Radio
//
//  Created by Administrator on 16/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Track : NSManagedObject

@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * itemURL;
@property (nonatomic, retain) NSNumber * length;
@property (nonatomic, retain) NSNumber * prefLevel;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;

@end
