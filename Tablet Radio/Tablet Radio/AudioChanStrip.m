//
//  AudioChanStrip.m
//  Tablet Radio
//
//  Created by Administrator on 04/11/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import "AudioChanStrip.h"

@implementation AudioChanStrip

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        self.currentIndex = -1;
    }
    return self;
}


- (void)mute {
    if (self.isMuted) {
        self.muted = NO;
        self.audioPlayer.volume = self.faderLevel;
    } else {
        self.muted = YES;
        self.audioPlayer.volume = 0;
    }
}

- (void)dim {
    if (self.isDimmed) {
        self.Dimmed = NO;
        self.audioPlayer.volume = self.faderLevel;
    } else {
        self.muted = YES;
        self.audioPlayer.volume = self.dimLevel;
    }
}


- (void)queueNextSong {
    if (self.currentIndex+1 != ([self.trackList count]-1)) {
        self.currentIndex++;
        [self queueSongAtIndex:self.currentIndex];
    }
}

- (void)queueSongAtIndex:(NSInteger)index{
    if (index != -1) {
        self.currentIndex = index;
        MPMediaItem *item = [self.trackList.items objectAtIndex:index];
        NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        
        self.nowPlayingItem = item;
        
        AVAudioPlayer *newPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        newPlayer.volume = self.faderLevel;
        
        self.audioPlayer = newPlayer;
        [self.audioPlayer setDelegate:self];
        [self.audioPlayer prepareToPlay];
    }
}

#pragma mark - AudioPlayer Protocols

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    NSLog(@"done");
    if (flag == YES) {
        if (self.currentIndex +1 != [self.trackList count]) {
            [self queueNextSong];
            [self.audioPlayer play];
            //[myTableView reloadData];
        } else {
            self.nowPlayingItem = nil;
        }
    }
}
@end
