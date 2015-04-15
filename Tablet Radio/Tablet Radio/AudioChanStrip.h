//
//  AudioChanStrip.h
//  Tablet Radio
//
//  Created by Administrator on 04/11/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import "ChannelStrip.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AudioChanStrip : ChannelStrip <AVAudioPlayerDelegate>

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;
@property (nonatomic, getter=isPlaying) BOOL playing;
@property (nonatomic) NSInteger currentIndex;
@property (strong, nonatomic) MPMediaItemCollection *trackList;
@property (strong, nonatomic) MPMediaItem *nowPlayingItem;

- (void)queueNextSong;
- (void)queueSongAtIndex:(NSInteger)index;

@end
