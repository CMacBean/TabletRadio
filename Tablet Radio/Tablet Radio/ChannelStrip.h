//
//  ChannelStrip.h
//  Tablet Radio
//
//  Created by Administrator on 04/11/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ChannelStrip : NSObject

@property (nonatomic, getter=isMuted) BOOL muted;
@property (nonatomic, getter=isDimmed) BOOL Dimmed;
@property (nonatomic) CGFloat faderPos;
@property (nonatomic) CGFloat faderLevel;
@property (nonatomic) CGFloat dimPos;
@property (nonatomic) CGFloat dimLevel;

- (void)mute;
- (void)dim;

@end
