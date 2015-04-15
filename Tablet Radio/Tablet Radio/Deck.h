//
//  Deck.h
//  Tablet Radio
//
//  Created by Administrator on 14/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TheAmazingAudioEngine.h"
#import <UIKit/UIKit.h>
#import "Track.h"
#import "AEPlaythroughChannel.h"

@class Deck;

@protocol DeckDelegate <NSObject>
@required

- (void)updateTimer:(NSInteger)timer withTime:(CGFloat)time;
- (BOOL)shouldPlayNext;
- (void)updateFaderForDeck:(Deck *)deck;
- (Track *)nextTrackInPlaylistAndUpdate:(BOOL)update;
- (void)finishedPlayingTrackInDeck:(Deck *)deck;
- (void)deckFinishedLoading:(NSInteger)deck withTrack:(Track *)track;

@end

@interface Deck : NSObject 

@property (nonatomic) AEChannelGroupRef group;
@property (nonatomic) AEChannelGroupRef mainGroup;
@property (retain) id delegate;
@property (nonatomic) NSInteger tag;
@property (strong, nonatomic) AEAudioController *controller;
@property (strong, nonatomic) AEAudioFilePlayer *filePlayer;
@property (nonatomic) NSTimeInterval pauseTime;
@property (nonatomic) CGFloat faderPos;
@property (nonatomic) CGFloat faderLev;
@property (strong, nonatomic) Track *playingItem;
@property (strong, nonatomic) Track *nextItem;
@property (nonatomic) BOOL isPlaylist;
@property (strong, nonatomic) NSTimer *timer;
@property (nonatomic) CGFloat timeLeft;
@property (nonatomic) NSMutableArray *filters;
@property (nonatomic) NSMutableArray *outputFilters;
@property (nonatomic) NSMutableArray *inputFilters;
@property (weak, nonatomic) AEPlaythroughChannel *micChannel;
@property (nonatomic) BOOL isCueing;

- (Deck *)initWithController:(AEAudioController *)controller andTag:(NSInteger)tag;
- (void)pause;
- (void)playNext;
- (void)play;
- (void)rewind;
- (void)loadItem:(Track *)item;
- (void)eject;
- (void)loopItem;
- (void)addFilter:(NSInteger)filter toChannel:(NSInteger)channel;
- (void)removeFilterAtIndex:(NSInteger)index fromChannel:(NSInteger)channel whilstCueing:(BOOL)cueing;
- (BOOL)cueDeckItemToGroup:(AEChannelGroupRef)group;
- (void)deCueDeckItemFromGroup:(AEChannelGroupRef)group;
- (void)savePrefLevelToContext:(NSManagedObjectContext *)context;

@end

