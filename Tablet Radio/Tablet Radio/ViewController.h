//
//  ViewController.h
//  Tablet Radio
//
//  Created by Administrator on 29/10/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreData/CoreData.h>
#import "Deck.h"
#import "LoadURLView.h"
#import "EffectsViewController.h"


@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MPMediaPickerControllerDelegate, AVAudioPlayerDelegate, NSFetchedResultsControllerDelegate, DeckDelegate, LoadURLView, EffectsViewController, UIPopoverPresentationControllerDelegate, UISearchBarDelegate>
{
    IBOutlet UITableView *myTableView;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (void)importFile:(NSURL *)fileURL;

@end