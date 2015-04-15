//
//  ViewController.m
//  Tablet Radio
//
//  Created by Administrator on 29/10/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//
//
//
//  Have the effects show up while cue and fix decueing if didn't cue???
//



#import "ViewController.h"
#import "ItemCell.h"
#import "AppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "Track.h"
#import "PLSItem.h"
#import "Deck.h"
#import "TheAmazingAudioEngine.h"
#import "AEPlaythroughChannel.h"
#import "MySegmentedControl.h"
#import "PlaylistViewController.h"
#import "AERecorder.h"


#import "UITesterController.h"

@interface ViewController ()
@property (strong, nonatomic) UIButton *Fader1;
@property (strong, nonatomic) UIButton *Fader2;
@property (strong, nonatomic) UIButton *Fader3;
@property (strong, nonatomic) UIButton *Fader4;
@property (strong, nonatomic) AEAudioController *controller;
@property (strong, nonatomic) AEPlaythroughChannel *micChannel;
@property (nonatomic) AEChannelGroupRef cueGroup;
@property (nonatomic) AEChannelGroupRef mainGroup;
@property (strong, nonatomic) Deck *mic;
@property (strong, nonatomic) Deck *deck1;
@property (strong, nonatomic) Deck *deck2;
@property (strong, nonatomic) Deck *deck3;
@property (strong, nonatomic) AERecorder *recorder;
@property (nonatomic) NSInteger playlistDeck;
@property (strong, nonatomic) Deck *selectedChannel;
@property (weak, nonatomic) IBOutlet UIButton *PlayPauseButton;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *plussButton;
@property (weak, nonatomic) IBOutlet UILabel *quickViewTitle;
@property (weak, nonatomic) IBOutlet UILabel *quickViewTimeLeft;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedController;
@property (strong, nonatomic) NSString *selectedSection;
@property (strong, nonatomic) PLSItem *playingPLSItem;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *deskDisplays;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *timerDisplays;
@property (weak, nonatomic) IBOutlet UIProgressView *itemProgressView;
@property (strong, nonatomic) UILabel *playlistEditTimer;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *ejectButton;
@property (weak, nonatomic) IBOutlet UIButton *loopButton;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *cueButtons;
@property (strong, nonatomic) NSMutableArray *playlists;
@property (strong, nonatomic) NSString *loadedPlaylist;
@property (strong, nonatomic) IBOutletCollection(UIActivityIndicatorView) NSArray *activiyView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *saveButtons;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *deckPlayPause;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *deckLoop;

- (void)fetchedResultsController:(NSFetchedResultsController *)controller configureCell:(ItemCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation ViewController {
    UITesterController *testView;
}

#define nonDeck 4

- (void)alertWithTitle:(NSString *)title andText:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:text
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (void)importFile:(NSURL *)fileURL {
    
    LoadURLView *formView = [[LoadURLView alloc] init];
    formView.delegate = self;
    formView.url = fileURL;
    formView.controller = self.controller;
    formView.modalPresentationStyle = UIModalPresentationFormSheet;
    formView.preferredContentSize = CGSizeMake(480, 487);
    [self presentViewController:formView animated:YES completion:nil];
}

- (void)userDoneWithTitle:(NSString *)title description:(NSString *)description type:(NSString *)type length:(double)length andURL:(NSURL *)url{
    [self dismissViewControllerAnimated:YES completion:nil];
    NSManagedObjectContext *context = self.managedObjectContext;
    
    // Insert a new Show entity.
    Track *track = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:context];
    track.title = title;
    track.desc = description;
    track.length = [NSNumber numberWithDouble:length];
    track.itemURL = [url absoluteString];
    track.prefLevel = nil;
    track.type = type;
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupFaders];
    [self setupPans];
    self.controller = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription] inputEnabled:YES];
    _controller.preferredBufferDuration = 0.005;
    _controller.useMeasurementMode = YES;
    [_controller start:NULL];
    self.mainGroup = [_controller createChannelGroup];
    [self setupMic];
    self.deck1 = [[Deck alloc] initWithController:_controller andTag:0];
    self.deck1.mainGroup = self.mainGroup;
    self.deck1.group = [_controller createChannelGroupWithinChannelGroup:self.mainGroup];
    [self.deck1 setDelegate:self];
    self.deck2 = [[Deck alloc] initWithController:_controller andTag:1];
    self.deck2.mainGroup = self.mainGroup;
    self.deck2.group = [_controller createChannelGroupWithinChannelGroup:self.mainGroup];
    [self.deck2 setDelegate:self];
    self.deck3 = [[Deck alloc] initWithController:_controller andTag:2];
    self.deck3.mainGroup = self.mainGroup;
    self.deck3.group = [_controller createChannelGroupWithinChannelGroup:self.mainGroup];
    [self.deck3 setDelegate:self];
    self.mic = nil;
    self.selectedChannel = self.deck1;
    self.selectedSection = @"Music";

    //Music
    myTableView.allowsMultipleSelectionDuringEditing = NO;
    
    myTableView.backgroundColor = [UIColor clearColor];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.playlists = [NSMutableArray arrayWithArray:[defaults objectForKey:@"playlists"]];
    self.loadedPlaylist = [defaults objectForKey:@"loadedPlaylist"];
    
    [self.searchBar setDelegate:self];
    
    // TESTER CODE (Uncomment to run)
    //testView = [[UITesterController alloc] initWithFrame:self.view.bounds];
    //[testView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
    //[testView setHidden:YES];
    //[self.view addSubview:testView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupFaders {
    self.Fader1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.Fader1 setBackgroundImage:[UIImage imageNamed:@"faderButton"] forState:UIControlStateNormal];
    self.Fader1.frame = CGRectMake(42, 594, 77, 42);
    self.Fader1.tag = 0;
    self.Fader2 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.Fader2 setBackgroundImage:[UIImage imageNamed:@"faderButton"] forState:UIControlStateNormal];
    self.Fader2.frame = CGRectMake(203, 594, 77, 42);
    self.Fader2.tag = 1;
    self.Fader3 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.Fader3 setBackgroundImage:[UIImage imageNamed:@"faderButton"] forState:UIControlStateNormal];
    self.Fader3.frame = CGRectMake(356, 594, 77, 42);
    self.Fader3.tag = 2;
    self.Fader4 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [self.Fader4 setBackgroundImage:[UIImage imageNamed:@"faderButton"] forState:UIControlStateNormal];
    self.Fader4.frame = CGRectMake(516, 594, 77, 42);
    self.Fader4.tag = 3;
    self.Fader1.showsTouchWhenHighlighted = NO;
    [self.view addSubview:self.Fader1];
    [self.view addSubview:self.Fader2];
    [self.view addSubview:self.Fader3];
    [self.view addSubview:self.Fader4];
}

- (void)setupMic {
    self.micChannel = [[AEPlaythroughChannel alloc] initWithAudioController:_controller];
    _controller.inputGain = 0;
    [_micChannel setVolume:0];
    [_controller addInputReceiver:_micChannel];
    [_controller addChannels:@[_micChannel] toChannelGroup:_mainGroup];

}

#pragma mark - Actions

- (IBAction)segmentedControlValueChanged:(id)sender
{
    self.fetchedResultsController = nil;
    self.selectedSection = [self.segmentedController titleForSegmentAtIndex:self.segmentedController.selectedSegmentIndex];
    if (self.segmentedController.selectedSegmentIndex == 1) {
        self.plussButton.hidden = NO;
    } else {
        self.plussButton.hidden = YES;
    }
    [myTableView reloadData];
}

- (IBAction)cueDeck:(UIButton *)sender {
    if (!sender.isSelected) {
        BOOL shouldCue = NO;
        _cueGroup = [_controller createChannelGroup];
        switch (sender.tag) {
            case 0: {
                NSArray *filters = [_controller filtersForChannel:_micChannel];
                for (AEAudioUnitFilter *filter in filters) {
                    [_controller removeFilter:filter fromChannel:_micChannel];
                }
                [_controller removeChannels:@[_micChannel]];
                [_controller addChannels:@[_micChannel] toChannelGroup:_cueGroup];
                for (AEAudioUnitFilter *filter in filters) {
                    [_controller addFilter:filter toChannel:_micChannel];
                }
                shouldCue = YES;
                break;
            }
            case 1: {
                shouldCue = [self.deck1 cueDeckItemToGroup:_cueGroup];
                break;
            }
            case 2: {
                shouldCue = [self.deck2 cueDeckItemToGroup:_cueGroup];
                break;
            }
            case 3: {
                shouldCue = [self.deck3 cueDeckItemToGroup:_cueGroup];
            }
        }
        if (shouldCue) {
            [sender setSelected:YES];
        }
    } else {
        [sender setSelected:NO];
        switch (sender.tag) {
            case 0: {
                NSArray *filters = [_controller filtersForChannel:_micChannel];
                for (AEAudioUnitFilter *filter in filters) {
                    [_controller removeFilter:filter fromChannel:_micChannel];
                }
                [_controller removeChannels:@[_micChannel]];
                [_controller addChannels:@[_micChannel] toChannelGroup:_mainGroup];
                for (AEAudioUnitFilter *filter in filters) {
                    [_controller addFilter:filter toChannel:_micChannel];
                }
                break;
            }
            case 1: {
                [self.deck1 deCueDeckItemFromGroup:_cueGroup];
                break;
            }
            case 2: {
                [self.deck2 deCueDeckItemFromGroup:_cueGroup];
                break;
            }
            case 3: {
                [self.deck3 deCueDeckItemFromGroup:_cueGroup];
                break;
            }
        }
        [_controller removeChannelGroup:_cueGroup];
    }
}

- (IBAction)recordButtonPressed:(UIButton *)sender {
    if ([sender isSelected]) {
        [sender setSelected:NO];
        [_controller removeOutputReceiver:_recorder fromChannelGroup:_mainGroup];
        [_recorder finishRecording];
        self.recorder = nil;
    } else {
        if (!self.recorder) {
            self.recorder = [[AERecorder alloc] initWithAudioController:_controller];
        }
        NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)
                                     objectAtIndex:0];
        NSString *filePath = [documentsFolder stringByAppendingPathComponent:@"Recording.aiff"];
        // Start the recording process
        NSError *error = NULL;
        if ( ![_recorder beginRecordingToFileAtPath:filePath
                                           fileType:kAudioFileAIFFType
                                              error:&error] ) {
            // Report error
            return;
        }
        [_controller addOutputReceiver:_recorder forChannelGroup:_mainGroup];
        [sender setSelected:YES];
    }
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    Deck *deck = nil;
    switch (sender.tag) {
        case 0:
            deck = self.deck1;
            break;
        case 1:
            deck = self.deck2;
            break;
        case 2:
            deck = self.deck3;
            break;
    }
    [deck savePrefLevelToContext:self.managedObjectContext];
    
    //Test stuff
    if (deck == self.deck1) {
        [testView faderPositionSaved];
    }
}

#pragma mark - PAN SETUP

#define minFaderMove 319
#define maxFaderMove 593
#define belowZero 590
#define fadDimDif 18

-(void)setupPans
{
    UIPanGestureRecognizer *fadpan1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fadPan1:)];
    [self.Fader1 addGestureRecognizer:fadpan1];
    UIPanGestureRecognizer *fadpan2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fadPan2:)];
    [self.Fader2 addGestureRecognizer:fadpan2];
    UIPanGestureRecognizer *fadpan3 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fadPan3:)];
    [self.Fader3 addGestureRecognizer:fadpan3];
    UIPanGestureRecognizer *fadpan4 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(fadPan4:)];
    [self.Fader4 addGestureRecognizer:fadpan4];
}

- (CGFloat)fadPan:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateChanged ||
        recognizer.state == UIGestureRecognizerStateEnded) {
        BOOL wasZero;
        UIView *dragonButton = recognizer.view;
        CGPoint translation = [recognizer translationInView:self.view];
        CGRect newButtonFrame = dragonButton.frame;
        if (newButtonFrame.origin.y > belowZero) {
            wasZero = YES;
        }
        newButtonFrame.origin.y += translation.y;
        if (newButtonFrame.origin.y >minFaderMove && newButtonFrame.origin.y < maxFaderMove){
            dragonButton.frame = newButtonFrame;
        }
        if (wasZero && newButtonFrame.origin.y<maxFaderMove && recognizer.state !=UIGestureRecognizerStateEnded) {
            [self faderStart:YES deck:dragonButton.tag];
            NSLog(@"start");
        }
        if (recognizer.state == UIGestureRecognizerStateEnded && newButtonFrame.origin.y>belowZero) {
            [self faderStart:NO deck:dragonButton.tag];
            NSLog(@"Stop");
        }
        [recognizer setTranslation:CGPointZero inView:self.view];
        return newButtonFrame.origin.y;
    } else {
        return 700;
    }
}

- (void)fadPan1:(UIPanGestureRecognizer *)recognizer
{
    [self panFader:self.mic withRecognizer:recognizer];
}

- (void)fadPan2:(UIPanGestureRecognizer *)recognizer
{
    [self panFader:self.deck1 withRecognizer:recognizer];
}

- (void)fadPan3:(UIPanGestureRecognizer *)recognizer
{
    [self panFader:self.deck2 withRecognizer:recognizer];
}

- (void)fadPan4:(UIPanGestureRecognizer *)recognizer
{
    [self panFader:self.deck3 withRecognizer:recognizer];
}

- (void)panFader:(Deck *)channel withRecognizer:(UIPanGestureRecognizer *)recognizer
{
    CGFloat origin = [self fadPan:recognizer];
    //NSLog([NSString stringWithFormat:@"pos = %f", origin]);
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        channel.faderPos = origin;
    }
    if (origin <= (CGFloat)maxFaderMove) {
        if (origin >=(CGFloat)minFaderMove) {
            origin -= (CGFloat)maxFaderMove;
            origin /= ((CGFloat)minFaderMove-maxFaderMove);

            //if (channel != nil) {
                origin = pow(origin, 4.0);
            }
    }
    if (origin < 1) {
        if(channel == nil) {
            [_micChannel setVolume:origin];
            if (origin > 0.90 && self.recorder) {
                [testView onAirWithMicrophone];
            }
        } else {
            [channel.filePlayer setVolume:origin];
            //NSLog(@"other");
        }
        channel.faderLev = origin;
        NSLog(@"%f",origin);

        if (origin > 0.90 && channel.isCueing) {
            [testView trackCuedandIncreased];
        }
    }
}

- (void)faderStart:(BOOL)start deck:(NSInteger)tag {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"faderStart"]) {
        if (start) {
            switch (tag) {
                case 1: {
                    [self.deck1 play];
                    
                    break;
                }
                case 2: {
                    [self.deck2 play];
                    break;
                }
                case 3: {
                    [self.deck3 play];
                    break;
                }
            }
        } else {
            switch (tag) {
                case 1: {
                    [self.deck1 pause];
                    break;
                }
                case 2: {
                    [self.deck2 pause];
                    [testView trackPausedWithFader];
                    break;
                }
                case 3: {
                    [self.deck3 pause];
                    break;
                }
            }
        }
    }
    if (self.selectedChannel.tag+1 == tag) {
        [self updateQuickView];
    }
    if (tag != 0) {
        [[self.saveButtons objectAtIndex:tag-1] setHidden:!start];
    }
}

#pragma mark - Channel selection/start


- (void)selectChannel:(NSInteger)sender {
    if (self.selectedChannel.tag != sender) {
        switch (sender) {
            case 0:
                self.selectedChannel = self.deck1;
                break;
            case 1:
                self.selectedChannel = self.deck2;
                break;
            case 2:
                if ([self.selectedSection isEqualToString:@"Other"]) {
                    NSError * error;
                    // retrieve the store URL
                    NSURL * storeURL = [[self.managedObjectContext persistentStoreCoordinator] URLForPersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject]];
                    // lock the current context
                    [self.managedObjectContext lock];
                    [self.managedObjectContext reset];//to drop pending changes
                    //delete the store from the current managedObjectContext
                    if ([[self.managedObjectContext persistentStoreCoordinator] removePersistentStore:[[[self.managedObjectContext persistentStoreCoordinator] persistentStores] lastObject] error:&error])
                    {
                        // remove the file containing the data
                        [[NSFileManager defaultManager] removeItemAtURL:storeURL error:&error];
                        //recreate the store like in the  appDelegate method
                        [[self.managedObjectContext persistentStoreCoordinator] addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error];//recreates the persistent store
                    }
                    [self.managedObjectContext unlock];
                    self.playlists = nil;
                    self.loadedPlaylist = nil;
                    [[NSUserDefaults standardUserDefaults] setObject:self.playlists forKey:@"playlists"];
                    [[NSUserDefaults standardUserDefaults] setObject:self.loadedPlaylist forKey:@"loadedPlaylist"];
                }
                self.selectedChannel = self.deck3;
                break;
        }
        [myTableView reloadData];
        [self updateQuickView];
        [self updateProgressView];
        [self updateTimer:nonDeck withTime:self.selectedChannel.timeLeft];
    }
}

- (IBAction)startPlayback:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.deck1 play];
    } else if (sender.tag == 1) {
        [self.deck2 play];
    } else {
        [self.deck3 play];
    }
    [self updateQuickView];
}

#pragma mark - Channel quick

- (void)updateQuickView {
    if (self.selectedChannel.filePlayer.channelIsPlaying) {
        [self.PlayPauseButton setBackgroundImage:[UIImage imageNamed:@"pauseButton"] forState:UIControlStateNormal];
        [[self.deckPlayPause objectAtIndex:self.selectedChannel.tag] setSelected:YES];
    } else {
        [self.PlayPauseButton setBackgroundImage:[UIImage imageNamed:@"playButton"] forState:UIControlStateNormal];
        [[self.deckPlayPause objectAtIndex:self.selectedChannel.tag] setSelected:NO];
    }
    Track *track = self.selectedChannel.playingItem;
    if (track) {
        NSString *title = track.title;
        NSString *desc = track.desc;
        self.quickViewTitle.text = [NSString stringWithFormat:@"%@ - %@", desc, title];
    } else {
        self.quickViewTitle.text = @"";
    }
    if (self.selectedChannel.filePlayer.loop) {
        [self.loopButton setSelected:YES];
        [[self.deckLoop objectAtIndex:self.selectedChannel.tag] setSelected:YES];
    } else {
        [self.loopButton setSelected:NO];
        [[self.deckLoop objectAtIndex:self.selectedChannel.tag] setSelected:NO];
    }
}

- (IBAction)playPause:(UIButton *)sender {
    Deck *deck;
    switch (sender.tag) {
        case 0:
            deck = self.deck1;
            break;
            
        case 1:
            deck = self.deck2;
            break;
            
        case 2:
            deck = self.deck3;
            break;
            
        case 3:
            deck = self.selectedChannel;
            break;
    }
    
    if (deck.playingItem != nil) {
        if (deck.filePlayer.channelIsPlaying) {
            [deck pause];
            [[self.deckPlayPause objectAtIndex:deck.tag] setSelected:NO];
        } else {
            [deck play];
            [[self.deckPlayPause objectAtIndex:deck.tag] setSelected:YES];
        }
        [myTableView reloadData];
    }
    [self updateQuickView];
}

- (IBAction)nextItem:(UIButton *)sender {
    [self.selectedChannel playNext];
    [self updateQuickView];
    if (![self.selectedChannel isPlaylist]) {
        [self updateDisplayImage:[self.deskDisplays objectAtIndex:self.selectedChannel.tag] toPlaylist:NO];
    }
}

- (IBAction)lastItem:(UIButton *)sender {
    [self.selectedChannel rewind];
    [self updateQuickView];
}

- (IBAction)ejectItem:(UIButton *)sender {
    Deck *deck;
    switch (sender.tag) {
        case 0:
            deck = self.deck1;
            break;
        case 1:
            deck = self.deck2;
            break;
        case 2:
            deck = self.deck3;
            break;
        case 3:
            deck = self.selectedChannel;
            break;
    }
    if (deck.isPlaylist) {
        self.playingPLSItem = nil;
    }
    if (deck.isCueing) {
        [[self.cueButtons objectAtIndex:deck.tag+1] setSelected:NO];
        [deck deCueDeckItemFromGroup:_cueGroup];
    }
    [deck eject];
    UIButton *display = [self.deskDisplays objectAtIndex:deck.tag];

    [self updateDisplayImage:display toPlaylist:NO];
    [self updateQuickView];
    [myTableView reloadData];
    if (deck.tag == 1) {
        [testView stopCueandEject];
    }
}

- (IBAction)loopButtonPressed:(UIButton *)sender {
    if (sender.isSelected) {
        [sender setSelected:NO];
    } else {
        [sender setSelected:YES];
    }
    Deck *deck;
    switch (sender.tag) {
        case 0:
            deck = self.deck1;
            break;
        case 1:
            deck = self.deck2;
            break;
        case 2:
            deck = self.deck3;
            break;
        case 3:
            deck = self.selectedChannel;
            break;
    }
    [deck loopItem];
    [self updateQuickView];
}

#pragma mark - Deck Displays
- (IBAction)displayPressed:(UIButton *)sender {
    
    NSIndexPath *path = [myTableView indexPathForSelectedRow];
    [myTableView deselectRowAtIndexPath:path animated:YES];
    if (path && [self canLoadToDeck:sender.tag]){
        if (!self.infoLabel.isHidden) {
            [self.infoLabel setHidden:YES];
            [self.PlayPauseButton setHidden:NO];
            [self.nextButton setHidden:NO];
            [self.backButton setHidden:NO];
            [self.quickViewTimeLeft setHidden:NO];
            [self.itemProgressView setHidden:NO];
            [self.ejectButton setHidden:NO];
            [self.loopButton setHidden:NO];
        }
        
        Track *track;;
        if ([self.selectedSection  isEqual: @"Playlist"]) {
            self.playingPLSItem = [self.fetchedResultsController objectAtIndexPath:path];
            track = self.playingPLSItem.track;
            [self loadToDeck:(sender.tag) withTrack:track andSetPlaylist:YES];
            self.playlistDeck = sender.tag;
            [self updateDisplayImage:sender toPlaylist:YES];
        } else {
            track = [self.fetchedResultsController objectAtIndexPath:path];
            [self loadToDeck:(sender.tag) withTrack:track andSetPlaylist:NO];
            [self updateDisplayImage:sender toPlaylist:NO];
        }
        
        if ([track.title isEqualToString:@"Lovers' Eyes"] && sender.tag == 1) {
            [testView loversEyesLoaded];
        }
        
        
        [sender setTitle:@"" forState:UIControlStateNormal];
        UIActivityIndicatorView *view = [self.activiyView objectAtIndex:sender.tag];
        [view startAnimating];
        [view setHidden:NO];
    } else if (![self canLoadToDeck:sender.tag]){
        [self alertWithTitle:@"Load error" andText:@"Cannot load to deck while cueing"];
    }
    [self selectChannel:sender.tag];
}

- (void)updateDisplayImage:(UIButton *)display toPlaylist:(BOOL)playlist {
    if (playlist) {
        [display setBackgroundImage:[UIImage imageNamed:@"displayRed"] forState:UIControlStateNormal];
        UILabel *label = [self.timerDisplays objectAtIndex:display.tag];
        label.textColor = [UIColor whiteColor];
    } else {
        [display setBackgroundImage:[UIImage imageNamed:@"displayGrey"] forState:UIControlStateNormal];
        UILabel *label = [self.timerDisplays objectAtIndex:display.tag];
        label.textColor = [UIColor redColor];
    }
}

- (BOOL)canLoadToDeck:(NSInteger)deck {
    switch (deck) {
        case 0: {
            if (self.deck1.isCueing) return NO;
            break;
        }
        case 1: {
            if (self.deck2.isCueing) return NO;
            break;
        }
        case 2: {
            if (self.deck1.isCueing) return NO;
            break;
        }
    }
    return YES;
}

- (void)setTitleForDisplay:(UIButton *)display forItem:(Track *)track {
    if (track) {
        NSString *title = track.title;
        NSString *desc = track.desc;
        [display setTitle:[NSString stringWithFormat:@"%@\r-\r%@", desc, title] forState:UIControlStateNormal];
    } else {
        [display setTitle:@"Tap to Load" forState:UIControlStateNormal];
    }
        [display.titleLabel setTextAlignment:NSTextAlignmentCenter];
}

- (void)loadToDeck:(NSInteger)deck withTrack:(Track *)track andSetPlaylist:(BOOL)pls {
    if (deck == 0) {
        self.deck1.isPlaylist = pls;
        [self.deck1 loadItem:track];
    } else if (deck == 1) {
        self.deck2.isPlaylist = pls;
        [self.deck2 loadItem:track];
    } else {
        self.deck3.isPlaylist = pls;
        [self.deck3 loadItem:track];
    }
}

#pragma mark - Deck Delegates

- (void)deckFinishedLoading:(NSInteger)deckNumber withTrack:(Track *)track{
    UIActivityIndicatorView *view = [self.activiyView objectAtIndex:deckNumber];
    [view stopAnimating];
    [self setTitleForDisplay:[self.deskDisplays objectAtIndex:deckNumber] forItem:track];
    [myTableView reloadData];
    [self updateQuickView];
}

- (BOOL)shouldPlayNext {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"autoPlay"];
}

- (void)updateFaderForDeck:(Deck *)deck {
    CGFloat origin = deck.faderLev;
    origin = pow(origin, 1.0/4.0);
    origin *= ((CGFloat)minFaderMove-maxFaderMove);
    origin += (CGFloat)maxFaderMove;
    //if (channel != nil) {
    UIButton *fader = nil;
    switch (deck.tag) {
        case 0:
            fader = self.Fader2;
            break;
        case 1:
            fader = self.Fader3;
            break;
        case 2:
            fader = self.Fader4;
            break;
    }
    CGRect frame = fader.frame;
    frame.origin.y = origin;
    fader.frame = frame;
    NSLog(@"update");
}

- (NSManagedObject *)nextTrackInPlaylistAndUpdate:(BOOL)update {
    PLSItem *plsItem = self.playingPLSItem.nextPLS;
    if (update) {
        self.playingPLSItem = plsItem;
        [myTableView reloadData];
        return plsItem.nextPLS.track;
    }
    return plsItem.track;
}

- (void)finishedPlayingTrackInDeck:(Deck *)deck {
    [self setTitleForDisplay:[self.deskDisplays objectAtIndex:deck.tag] forItem:deck.playingItem];
    if (deck == self.selectedChannel) {
        [self updateQuickView];
        [self updateProgressView];
    }
}

- (void)updateTimer:(NSInteger)timer withTime:(CGFloat)time {
    int minutes = floor(time / 60);
    int seconds = trunc(time - minutes * 60);
    
    if (timer != nonDeck) {
        UILabel *label = [self.timerDisplays objectAtIndex:timer];
        label.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        if (timer == self.playlistDeck) {
            self.playlistEditTimer.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        }
    }
    if (self.selectedChannel.tag == timer | timer == nonDeck) {
        self.quickViewTimeLeft.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
        [self updateProgressView];
    }
}

- (void)updateProgressView {
    CGFloat time =  self.selectedChannel.timeLeft;
    CGFloat length = [self.selectedChannel.playingItem.length floatValue];
    CGFloat progress = 0.0;
    if (length) {
        progress = (length-time)/length;
    }
    self.itemProgressView.progress = progress;
}

#pragma mark - TABLE VIEW

#pragma mark - TableView DataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [self.fetchedResultsController.fetchedObjects count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemCell *cell = nil;
    
    static NSString *TableViewCellIdentifier = @"thisCell";
    cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
    
    if (cell == nil) {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"ItemCell"
                                                      owner:self options:nil];
        cell = (ItemCell *)[nibs objectAtIndex:0];
    }
    // Configure the cell...
    [self fetchedResultsController:self.fetchedResultsController configureCell:cell atIndexPath:indexPath];
    
    //cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Cell"]];
    //cell.contentView.backgroundColor = [UIColor redColor];
//    cell.accessoryView = nil;
//    
//    if (item == self.selectedChannel.nowPlayingItem) {
//        if (self.selectedChannel.isPlaying) {
//            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pauseButton"]];
//        } else {
//            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"playButton"]];
//        }
//    }

    return cell;
}

#pragma mark - TableView Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.fetchedResultsController objectAtIndexPath:indexPath] == self.playingPLSItem) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        if ([self.selectedSection isEqualToString:@"Playlist"]) {
            PLSItem *current = [self.fetchedResultsController objectAtIndexPath:indexPath];
            NSIndexPath* prevIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            if (current != [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) {
                PLSItem *last = [self.fetchedResultsController objectAtIndexPath:prevIndexPath];
                last.nextPLS = current.nextPLS;
            }
            current.nextPLS = nil;
        }
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    //[self tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([myTableView indexPathForSelectedRow] == indexPath) {
        [myTableView deselectRowAtIndexPath:indexPath animated:NO];
        return nil;
    }
    
    return indexPath;
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - MediaPicker

- (IBAction)showMediaPicker:(id)sender {
    MPMediaPickerController *picker =
    [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAnyAudio];
    
    picker.delegate						= self;
    picker.allowsPickingMultipleItems	= YES;
    picker.prompt						= NSLocalizedString (@"Add Songs", @"Prompt to user to choose some songs to play");
    
    UIPopoverController *colorPickerPopover = [[UIPopoverController alloc]
                                                initWithContentViewController:picker];
    [colorPickerPopover presentPopoverFromRect:self.plussButton.frame inView:self.plussButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    
    BOOL loadedPlaylist = NO;

    [self dismissViewControllerAnimated:YES completion:NULL];
    NSArray *items = [mediaItemCollection items];
    for (MPMediaItem* item in items) {
        
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        
        
        // Insert a new Show entity.
        Track *track = [NSEntityDescription insertNewObjectForEntityForName:@"Track" inManagedObjectContext:context];
        track.title = item.title;
        if ([item.title isEqualToString:@"Apocalypse Please"]) {
            NSLog(@"title = %@", item.title);
            loadedPlaylist = YES;
        }
        track.desc = item.artist;
        track.length = [item valueForKey:MPMediaItemPropertyPlaybackDuration];
        NSURL *trackURL = [item valueForKey:MPMediaItemPropertyAssetURL];
        track.itemURL = [trackURL absoluteString];
        track.prefLevel = nil;
        track.type = @"Music";
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        [context reset];
    }
    [myTableView reloadData];
    [self updateQuickView];
    if (loadedPlaylist) {
        [testView loadedPlaylist];
    }
}

#pragma mark - Fetched results controller

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.fetchedResultsController = nil;
    [myTableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSString *selected = self.selectedSection;

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = nil;
    if ([selected isEqualToString:@"Playlist"]) {
        entity = [NSEntityDescription entityForName:@"PLSItem" inManagedObjectContext:self.managedObjectContext];
    } else {
        entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    }
    
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    if ([selected length] > 0) {
        NSPredicate *p1;
        if (![selected isEqualToString:@"Playlist"]) {
            p1 = [NSPredicate predicateWithFormat:@"type contains[cd] %@", selected];
        } else if (self.loadedPlaylist) {
            p1 = [NSPredicate predicateWithFormat:@"title contains[cd] %@", self.loadedPlaylist];
        }
        NSPredicate *p2 = nil;
        NSString *searchText = self.searchBar.text;
        if ([searchText length] > 0) {
            p2 = [NSPredicate predicateWithFormat:@"(title contains[cd] %@) OR (desc contains[cd] %@)", searchText, searchText];
        }
        
        if (p2) {
            NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[p1, p2]];
            fetchRequest.predicate = predicate;
        } else {
            fetchRequest.predicate = p1;
        }

    }

    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = nil;
    if ([selected isEqualToString:@"Playlist"]) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    } else {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    }
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [myTableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [myTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [myTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeMove:
            break;
            
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [myTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:(ItemCell *)[myTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [myTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [myTableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [myTableView endUpdates];
}

- (void)fetchedResultsController:(NSFetchedResultsController *)controller configureCell:(ItemCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Track *track = nil;
    if ([self.selectedSection isEqualToString:@"Playlist"]) {
        PLSItem *item = [controller objectAtIndexPath:indexPath];
        track = item.track;
        if (item == self.playingPLSItem) {
            cell.isPlaying = YES;
            cell.lengthLabel.textColor = [UIColor whiteColor];
        }
    } else {
        track = [controller objectAtIndexPath:indexPath];
    }
    
    cell.titleLabel.text = track.title;
    cell.descriptionLabel.text = track.desc;
    float duration = [track.length floatValue];
    int minutes = floor(duration / 60);
    int seconds = trunc(duration - minutes * 60);
    cell.lengthLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

#pragma mark - Navigation

- (IBAction)unwindToMain:(UIStoryboardSegue *)unwindSegue
{
        UIViewController* sourceViewController = unwindSegue.sourceViewController;
    
        if ([sourceViewController isKindOfClass:[PlaylistViewController class]])
        {
            PlaylistViewController *vc = (PlaylistViewController *)sourceViewController;
            self.loadedPlaylist = vc.loadedPlaylist;
            self.playlists = vc.playlists;
            self.fetchedResultsController = nil;
            [myTableView reloadData];
            if ([self.playlists count] == 1) {
                [testView newPlaylistWithFourTracks];
            }
        }
    [self.view addSubview:testView];
}


//For Testing!
-(void)edited {
    if (self.deck1.isPlaylist) {
        [testView playlistWithEffect];
    }
}

#define fileChannel 0
#define inputChannel 1
#define outputChannel 2

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([[segue identifier] isEqualToString:@"editPlaylist"]) {
        NSManagedObjectContext *context = self.managedObjectContext;
        PlaylistViewController *controller = (PlaylistViewController *)segue.destinationViewController;
        [controller setManagedObjectContext:context];
        [controller setPlaylists:self.playlists];
        [controller setLoadedPlaylist:self.loadedPlaylist];
        [controller.view addSubview:testView];
    } else if ([[segue identifier] isEqualToString:@"deck1FX"]) {
        UINavigationController *navvc = [segue destinationViewController];
        
        navvc.popoverPresentationController.delegate = self;

        [navvc.view addSubview:testView];
        EffectsViewController *vc = navvc.viewControllers[0];
        [vc setDeck:self.deck1];
        [vc setIsCueing:self.deck1.isCueing];
        [vc setChannel:fileChannel];
        [vc setDelegate:self];
        [vc setIsCorrect:YES];
    }else if ([[segue identifier] isEqualToString:@"deck2FX"]) {
        UINavigationController *navvc = [segue destinationViewController];
        
        navvc.popoverPresentationController.delegate = self;

        [navvc.view addSubview:testView];
        EffectsViewController *vc = navvc.viewControllers[0];
        [vc setDeck:self.deck2];
        [vc setIsCueing:self.deck2.isCueing];
        [vc setChannel:fileChannel];
        [vc setDelegate:self];
        [vc setIsCorrect:NO];

    } else if ([[segue identifier] isEqualToString:@"deck3FX"]) {
        UINavigationController *navvc = [segue destinationViewController];
        
        navvc.popoverPresentationController.delegate = self;

        [navvc.view addSubview:testView];
        EffectsViewController *vc = navvc.viewControllers[0];
        [vc setDeck:self.deck3];
        [vc setIsCueing:self.deck3.isCueing];
        [vc setChannel:fileChannel];
        [vc setDelegate:self];
        [vc setIsCorrect:NO];

    } else if ([[segue identifier] isEqualToString:@"inputFX"]) {
        UINavigationController *navvc = [segue destinationViewController];
        
        navvc.popoverPresentationController.delegate = self;
        
        [navvc.view addSubview:testView];
        EffectsViewController *vc = navvc.viewControllers[0];
        [vc setMicChannel:self.micChannel];
        [vc setDeck:self.deck1];
        [vc setIsCueing:[[self.cueButtons objectAtIndex:0] isSelected]];
        [vc setChannel:inputChannel];
        [vc setDelegate:self];
        [vc setIsCorrect:NO];

    } else if ([[segue identifier] isEqualToString:@"outputFX"]) {
        UINavigationController *navvc = [segue destinationViewController];

        navvc.popoverPresentationController.delegate = self;

        [navvc.view addSubview:testView];
        EffectsViewController *vc = navvc.viewControllers[0];
        [vc setDeck:self.deck1];
        [vc setIsCueing:NO];
        [vc setChannel:outputChannel];
        [vc setDelegate:self];
        [vc setIsCorrect:NO];

    }
}
@end