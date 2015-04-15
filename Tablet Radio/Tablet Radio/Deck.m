
//
//  Deck.m
//  Tablet Radio
//
//  Created by Administrator on 16/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "Deck.h"
#import "AEAudioUnitFilter.h"

@interface Deck ()

@property (strong, nonatomic) AEAudioFilePlayer *backGroundPlayer;

@end

@implementation Deck

- (Deck *)initWithController:(AEAudioController *)controller andTag:(NSInteger)tag {
    Deck *deck = [[Deck alloc] init];
    deck.controller = controller;
    deck.tag = tag;
    deck.filters = [[NSMutableArray alloc] init];
    deck.inputFilters = [[NSMutableArray alloc] init];
    deck.outputFilters = [[NSMutableArray alloc] init];
    deck.isCueing = NO;

    return deck;
}

- (void)eject {
    if (self.playingItem) {
        self.isPlaylist = NO;
        _filePlayer.channelIsPlaying = NO;
        self.playingItem = nil;
        self.nextItem = nil;
        [self stopTimer];
        self.timeLeft = 0;
        [[self delegate]finishedPlayingTrackInDeck:self];
        [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
    }
}

- (void)pause {
    self.pauseTime =  self.filePlayer.currentTime;
    self.filePlayer.channelIsPlaying = NO;
    [self stopTimer];
}

- (void)playNext {
    if (self.playingItem && (self.backGroundPlayer || !self.nextItem)) {
        if (self.isPlaylist) {
            self.playingItem = self.nextItem;
            self.nextItem = [[self delegate] nextTrackInPlaylistAndUpdate:YES];
            if (self.playingItem) {
                [self loadBackgroundToMain];
                [self loadNextItem];
            } else {
                self.timeLeft = 0;
                _filePlayer.channelIsPlaying = NO;
                self.isPlaylist = NO;
                self.playingItem = nil;
                self.nextItem = nil;
            }
        } else {
            self.playingItem = nil;
            self.timeLeft = 0;
            _filePlayer.channelIsPlaying = NO;
        }
        [[self delegate]finishedPlayingTrackInDeck:self];
        [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
    }
}

- (void)play {
    if (self.playingItem && _filePlayer.channelIsPlaying == NO) {
        _filePlayer.currentTime = self.pauseTime;
        _filePlayer.channelIsPlaying = YES;
        [self startTimer];
        [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
    }
}

- (void)rewind {
    _filePlayer.currentTime = 0;
    self.pauseTime = 0;
    _filePlayer.channelIsPlaying = NO;
    [self stopTimer];
    self.timeLeft = [self.playingItem.length floatValue];
    [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
}

- (void)updateTimeLeft:(NSTimer *)timer {
    self.timeLeft -= 1;
    [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
}

- (void)loopItem {
    if (_filePlayer.loop) {
        _filePlayer.loop = NO;
    } else {
        _filePlayer.loop = YES;
    }
}

- (void)loadItem:(Track *)track {
    if (self.timer) {
        [self stopTimer];
    }
    if (_filePlayer) {
        [_controller removeChannels:@[_filePlayer]];
        self.filePlayer = nil;
    }
    self.pauseTime = 0;
    NSString *url = track.itemURL;
    dispatch_async(dispatch_queue_create("loadFileQueue", NULL), ^{
        NSLog(@"load");
        self.filePlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL URLWithString:url]
                                                    audioController:_controller
                                                              error:NULL];
        NSLog(@"finished");
        _filePlayer.volume = 0;
        if (!self.group) {
            self.group = [_controller createChannelGroupWithinChannelGroup:_mainGroup];
        }
        [_controller addChannels:@[_filePlayer] toChannelGroup:self.group];
        _filePlayer.volume = self.faderLev;
        CGFloat prefLev = [track.prefLevel floatValue];
        if (prefLev) {
            _filePlayer.volume = prefLev;
            self.faderLev = prefLev;
            dispatch_async(dispatch_get_main_queue(), ^{ [[self delegate] updateFaderForDeck:self]; });

        }
        _filePlayer.removeUponFinish = YES;
        __weak Deck *weakSelf = self;
        _filePlayer.completionBlock = ^{
            [weakSelf stopTimer];
            NSLog(@"Finished");
            [weakSelf playNext];
        };
        _filePlayer.startLoopBlock = ^{
            [weakSelf stopTimer];
            NSLog(@"loop");
            [weakSelf startTimer];
        };
        self.playingItem = track;
        
        if ([track.type isEqualToString:@"Beds"]) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoop"]) {
                [self loopItem];
            }
        }
        
        _filePlayer.channelIsPlaying = NO;
        self.timeLeft = [track.length floatValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
            [[self delegate] deckFinishedLoading:self.tag withTrack:track];
        });
    });
    self.nextItem = [[self delegate] nextTrackInPlaylistAndUpdate:NO];
    if (self.isPlaylist) {
        [self loadNextItem];
    }
}

- (void)loadNextItem {
    NSString *url = self.nextItem.itemURL;
    if (self.nextItem) {
        dispatch_async(dispatch_queue_create("loadFileQueue", NULL), ^{
            self.backGroundPlayer = [AEAudioFilePlayer audioFilePlayerWithURL:[NSURL URLWithString:url]
                                                              audioController:_controller
                                                                        error:NULL];
            _backGroundPlayer.volume = 0;
            _backGroundPlayer.volume = self.faderLev;
            NSInteger prefLev = [self.nextItem.prefLevel integerValue];
            if (prefLev) {
                _backGroundPlayer.volume = prefLev;
            }
            _backGroundPlayer.removeUponFinish = YES;
            __weak Deck *weakSelf = self;
            _backGroundPlayer.completionBlock = ^{
                [weakSelf stopTimer];
                [weakSelf playNext];
            };
            _backGroundPlayer.startLoopBlock = ^{
                [weakSelf stopTimer];
                NSLog(@"other loop");
                [weakSelf startTimer];
            };
            
            if ([self.nextItem.type isEqualToString:@"Beds"]) {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"autoLoop"]) {
                    [self loopItem];
                }
            }
            
            _backGroundPlayer.channelIsPlaying = NO;
        });
    }
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
    NSLog(@"stop");
}

- (void)startTimer {
    self.timeLeft = [self.playingItem.length floatValue] - _filePlayer.currentTime;
    NSLog(@"start at time %f",self.timeLeft);
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(updateTimeLeft:)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)loadBackgroundToMain {
    if (self.timer) {
        [self stopTimer];
    }
    if (_filePlayer) {
        [_controller removeChannels:@[_filePlayer]];
        self.filePlayer = nil;
    }
    self.filePlayer = self.backGroundPlayer;
    self.pauseTime = 0;
    [_controller addChannels:@[_filePlayer] toChannelGroup:self.group];
    _filePlayer.volume = self.faderLev;
    CGFloat prefLev = [self.playingItem.prefLevel floatValue];
    if (prefLev) {
        _filePlayer.volume = prefLev;
        self.faderLev = prefLev;
        [[self delegate] updateFaderForDeck:self];
    }
    
    _filePlayer.channelIsPlaying = NO;
    
    self.timeLeft = [self.playingItem.length floatValue];
    [[self delegate] updateTimer:self.tag withTime:self.timeLeft];
    self.backGroundPlayer = nil;
    if ([[self delegate] shouldPlayNext]) {
        [self play];
    }
}

- (void)addFilter:(NSInteger)filterNumber toChannel:(NSInteger)channel {
    AEAudioUnitFilter *filter = nil;
    NSString *filterName = nil;
    switch (filterNumber) {
        case (0): {
            AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                             kAudioUnitType_Effect,
                                                             kAudioUnitSubType_NBandEQ);
            
            filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                             audioController:_controller
                                                                       error:nil];
            NSInteger bands = 3;
            AudioUnitSetProperty(filter.audioUnit, kAUNBandEQProperty_NumberOfBands, kAudioUnitScope_Global, 0, &bands, sizeof(bands));
            AudioUnitSetParameter(filter.audioUnit, kAUNBandEQParam_FilterType, kAudioUnitScope_Global, 0, kAUNBandEQFilterType_ResonantHighShelf, 0);
            AudioUnitSetParameter(filter.audioUnit, kAUNBandEQParam_FilterType+1, kAudioUnitScope_Global, 0, kAUNBandEQFilterType_Parametric, 0);
            AudioUnitSetParameter(filter.audioUnit, kAUNBandEQParam_FilterType+2, kAudioUnitScope_Global, 0, kAUNBandEQFilterType_ResonantLowShelf, 0);
            if (!filter) {
                // Report error
            }
            filterName = @"EQ";
            break;
        }
        case (1): {
            AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                             kAudioUnitType_Effect,
                                                             kAudioUnitSubType_DynamicsProcessor);
            
            filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                             audioController:_controller
                                                                       error:nil];
            
            if (!filter) {
                // Report error
            }
            filterName = @"Compressor";
            break;
        }
        case (2): {
            AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                             kAudioUnitType_Effect,
                                                             kAudioUnitSubType_PeakLimiter);
            
            filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                             audioController:_controller
                                                                       error:nil];
            
            if (!filter) {
                // Report error
            }
            filterName = @"Limiter";
            break;
        }
        case (3): {
            AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                             kAudioUnitType_Effect,
                                                             kAudioUnitSubType_Reverb2);
            
            filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                             audioController:_controller
                                                                       error:nil];
            
            if (!filter) {
                // Report error
            }
            filterName = @"Reverb";
            break;
            
        }
        case (4): {
            AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                             kAudioUnitType_Effect,
                                                             kAudioUnitSubType_Delay);
            
            filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                             audioController:_controller
                                                                       error:nil];

            if (!filter) {
                // Report error
            }
            filterName = @"Delay";
            break;
        }
        case (5): {
            AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                             kAudioUnitType_Effect,
                                                             kAudioUnitSubType_NewTimePitch);
            
            filter = [[AEAudioUnitFilter alloc] initWithComponentDescription:component
                                                             audioController:_controller
                                                                       error:nil];
            
            if (!filter) {
                // Report error
            }
            filterName = @"Pitch";
            break;
        }
    }
    if (channel == 0) {
        [_controller addFilter:filter toChannelGroup:_group];
        [self.filters addObject:filterName];
    } else if (channel == 1){
        [_controller addFilter:filter toChannel:self.micChannel];
        [self.inputFilters addObject:filterName];
    } else {
        [_controller addFilter:filter toChannelGroup:_mainGroup];
        [self.outputFilters addObject:filterName];
    }
}

- (void)removeFilterAtIndex:(NSInteger)index fromChannel:(NSInteger)channel whilstCueing:(BOOL)cueing {
    AEAudioUnitFilter *filter = nil;
    if (channel == 0) {
        if (cueing) {
            filter = [[_controller filtersForChannel:_filePlayer] objectAtIndex:index];
            [_controller removeFilter:filter fromChannel:_filePlayer];
        } else {
            filter = [[_controller filtersForChannelGroup:_group] objectAtIndex:index];
            [_controller removeFilter:filter fromChannelGroup:_group];
        }
        [self.filters removeObjectAtIndex:index];
    } else if (channel == 1){
        filter = [[_controller filtersForChannel:self.micChannel] objectAtIndex:index];
        [_controller removeFilter:filter fromChannel:self.micChannel];
        [self.inputFilters removeObjectAtIndex:index];
    } else {
        filter = [[_controller filtersForChannelGroup:_mainGroup] objectAtIndex:index];
        [_controller removeFilter:filter fromChannelGroup:_mainGroup];
        [self.outputFilters removeObjectAtIndex:index];
    }

}

- (BOOL)cueDeckItemToGroup:(AEChannelGroupRef)cuegroup {
    if (self.playingItem && !_filePlayer.channelIsPlaying) {
        [_controller removeChannels:@[_filePlayer]];
        [_controller addChannels:@[_filePlayer] toChannelGroup:cuegroup];
        NSArray *filters = [_controller filtersForChannelGroup:_group];
        for (AEAudioUnitFilter *filter in filters) {
            [_controller removeFilter:filter fromChannelGroup:_group];
            [_controller addFilter:filter toChannel:_filePlayer];
        } 
        [self play];
        self.isCueing = YES;
        NSLog(@"cue");
        return YES;
    }
    return NO;
}

- (void)deCueDeckItemFromGroup:(AEChannelGroupRef)cuegroup {
    [self pause];
    NSArray *filters = [_controller filtersForChannel:_filePlayer];
    for (AEAudioUnitFilter *filter in filters) {
        [_controller removeFilter:filter fromChannel:_filePlayer];
    }
    [_controller removeChannels:@[_filePlayer]];
    [_controller addChannels:@[_filePlayer] toChannelGroup:_group];
    for (AEAudioUnitFilter *filter in filters) {
        [_controller addFilter:filter toChannelGroup:_group];
    }
    self.isCueing = NO;
}

- (void)savePrefLevelToContext:(NSManagedObjectContext *)context {
    Track *item = self.playingItem;
    item.prefLevel = [NSNumber numberWithDouble:self.faderLev];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}
@end