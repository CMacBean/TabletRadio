//
//  PlaylistViewController.h
//  Tablet Radio
//
//  Created by Administrator on 20/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "Deck.h"
#import "SortByController.h"
#import "LoadPlaylistSelector.h"


#import "UITesterController.h"

@interface PlaylistViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UISearchBarDelegate, UIAlertViewDelegate, SortByController, LoadPlaylistSelector>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *playlists;
@property (strong, nonatomic) NSString *loadedPlaylist;

@end
