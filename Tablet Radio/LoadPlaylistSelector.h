//
//  LoadPlaylistSelector.h
//  Tablet Radio
//
//  Created by Administrator on 06/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LoadPlaylistSelector <NSObject>
@required
-(void)loadPlaylist:(NSString *)playlist;
-(void)deletePlaylist:(NSString *)playlist;
@end

@interface LoadPlaylistSelector : UITableViewController

@property (nonatomic, strong) NSMutableArray *playlists ;
@property (nonatomic, weak) id delegate;

-(void)changeContentSize;

@end
