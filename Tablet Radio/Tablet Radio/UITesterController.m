//
//  UITesterController.m
//  Tablet Radio
//
//  Created by Administrator on 13/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "UITesterController.h"

@interface UITesterController()

@property (nonatomic) double count;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) NSInteger task;
@property (nonatomic) BOOL isTask;
@property (nonatomic) double time;

@end

@implementation UITesterController

- (UITesterController *)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.count = -1;
    self.task = 1;
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)alertWithTitle:(NSString *)title andText:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.isTask) {
        [self resetAll];
        self.timer = [NSTimer timerWithTimeInterval:0.01
                                                 target:self
                                               selector:@selector(updateTime:)
                                               userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    } else {
        self.task++;
        [self start];
    }
}

- (void)updateTime:(id)sender {
    self.time += 0.01;
    NSLog(@"time = %f", self.time);
}

- (void)resetAll {
    self.count = 0;
    self.time = 0;
}

- (void)start {
    self.isTask = YES;
    switch (self.task) {
        case 1:
            [self alertWithTitle:@"" andText:@"Add the itunes playlist called 'Radio Playlist' into the applications music"];
            break;
        case 2:
            [self alertWithTitle:@"" andText:@"Load the track 'Lovers Eyes' onto Deck 2"];
            break;
        case 3:
            [self alertWithTitle:@"" andText:@"Cue Deck 2 and turn up its volume to max"];
            break;
        case 4:
            [self alertWithTitle:@"" andText:@"Turn on the 'Fader Start/Stop' setting and use the fader to pause the track"];
            break;
        case 5:
            [self alertWithTitle:@"" andText:@"Stop the cue and eject the track from Deck 2"];
            break;
        case 6:
            [self alertWithTitle:@"" andText:@"Enter the Playlist Editor and create a new playlist with 4 track. Then exit back to the main screen"];
            break;
        case 7:
            [self alertWithTitle:@"" andText:@"Load the first playlist track into Deck 1, add an effect, and then edit the effect"];
            break;
        case 8:
            [self alertWithTitle:@"" andText:@"Put the station on air and turn up the microphone"];
            break;
        case 9:
            [self alertWithTitle:@"" andText:@"Turn Deck 1s fader up half way and save the fader position"];
            break;
    }
}

- (void)finish {
    [self.timer invalidate];
    self.timer = nil;
    self.isTask = NO;
    [self alertWithTitle:@"" andText:[NSString stringWithFormat:@" Task - %ld \nTaps = %.f \ntime = %0.02fs", (long)self.task, self.count, self.time]];
}

- (void)loadedPlaylist {
    if (self.task == 1) {
        [self finish];
    }
}

- (void)loversEyesLoaded {
    if (self.task == 2) {
        [self finish];
    }
}

- (void)trackCuedandIncreased {
    if (self.task == 3) {
        [self finish];
    }
}

- (void)trackPausedWithFader {
    if (self.task == 4) {
        [self finish];
    }
}

- (void)stopCueandEject {
    if (self.task == 5) {
        [self finish];
    }
}

- (void)newPlaylistWithFourTracks {
    if (self.task == 6) {
        [self finish];
    }
}

- (void)playlistWithEffect {
    if (self.task == 7) {
        [self finish];
    }
}

- (void)onAirWithMicrophone {
    if (self.task == 8) {
        [self finish];
    }
}

- (void)faderPositionSaved {
    if (self.task == 9) {
        [self finish];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (self.count == -1) {
        [self start];
        self.count = 0;
    }
    self.count++;
    self.count -= 0.5;
    NSLog(@"Touch = %ld", (long)self.count);
    return nil;
}
@end
