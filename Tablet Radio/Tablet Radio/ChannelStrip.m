//
//  ChannelStrip.m
//  Tablet Radio
//
//  Created by Administrator on 04/11/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import "ChannelStrip.h"

@interface ChannelStrip()



@end

@implementation ChannelStrip

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.faderPos = 641;
        self.dimPos = 457;
    }
    return self;
}



- (void)mute {
    if (self.isMuted) self.muted = NO;
    else self.muted = YES;
    //mustoverwrite
}

- (void)dim {
    if (self.isDimmed) self.Dimmed = NO;
    else self.Dimmed = YES;
    //must overwrite
}

@end
