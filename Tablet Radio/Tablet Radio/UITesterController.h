//
//  UITesterController.h
//  Tablet Radio
//
//  Created by Administrator on 13/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITesterController : UIView <UIAlertViewDelegate>

- (void)start;
- (void)loadedPlaylist;
- (void)loversEyesLoaded;
- (void)trackCuedandIncreased;
- (void)trackPausedWithFader;
- (void)stopCueandEject;
- (void)newPlaylistWithFourTracks;
- (void)playlistWithEffect;
- (void)onAirWithMicrophone;
- (void)faderPositionSaved;

@end
