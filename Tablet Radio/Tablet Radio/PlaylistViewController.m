//
//  PlaylistViewController.m
//  Tablet Radio
//
//  Created by Administrator on 20/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "PlaylistViewController.h"
#import "ViewController.h"
#import "MySegmentedControl.h"
#import "ItemCell.h"
#import "PLSItem.h"
#import "Track.h"
#import "Deck.h"

@interface PlaylistViewController ()

@property (strong, nonatomic) NSFetchedResultsController *playListResultsController;
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *playlistTableView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *secondSegmentedController;
@property (strong, nonatomic) NSString *selectedSection;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) NSString *sortBy;
@property (nonatomic, strong) SortByController *sortPicker;
@property (nonatomic, strong) UIPopoverController *sortPickerPopover;
@property (nonatomic, strong) LoadPlaylistSelector *playlistPicker;
@property (nonatomic, strong) UIPopoverController *playlistPickerPopover;

- (void)fetchedResultsController:(NSFetchedResultsController *)controller configureCell:(ItemCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation PlaylistViewController

- (void)setManagedObjectContext:(NSManagedObjectContext *)newManagedObjectContext  {
    if (_managedObjectContext != newManagedObjectContext) {
        _managedObjectContext = newManagedObjectContext;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectedSection = @"Music";
    [self.searchBar setDelegate:self];
    if ([self.playlists count] == 0) {
        [self newPlaylist];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - actions

- (IBAction)segmentedControlValueChanged:(id)sender
{
    self.fetchedResultsController = nil;
    self.selectedSection = [self.secondSegmentedController titleForSegmentAtIndex:self.secondSegmentedController.selectedSegmentIndex];
    [self.tableView reloadData];
}

- (IBAction)sortByPressed:(UIButton *)sender {
    if (_sortPicker== nil) {
        //Create the ColorPickerViewController.
        _sortPicker = [[SortByController alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _sortPicker.delegate = self;
    }
    
    if (!_sortPickerPopover.popoverVisible && _sortPickerPopover != nil) {
        _sortPickerPopover = nil;
    }
    
    if (_sortPickerPopover == nil) {
        //The color picker popover is not showing. Show it.
        _sortPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_sortPicker];
        [_sortPickerPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_sortPickerPopover dismissPopoverAnimated:YES];
        _sortPickerPopover = nil;
    }
}

//sort delegate
-(void)selectedSort:(NSString *)sort {
    _sortBy = sort;
    if (_sortPickerPopover) {
        [_sortPickerPopover dismissPopoverAnimated:YES];
        _sortPickerPopover = nil;
    }
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

- (IBAction)addToPlaylist:(UIButton *)sender {
    if (self.loadedPlaylist != nil) {
        NSArray *paths = [self.tableView indexPathsForSelectedRows];
        for (NSIndexPath *path in paths) {
            [self.tableView deselectRowAtIndexPath:path animated:YES];
            if (path){
                Track *track = [self.fetchedResultsController objectAtIndexPath:path];
                NSManagedObjectContext *context = self.managedObjectContext;
                
                // Insert a new Show entity.
                PLSItem *plsItem = [NSEntityDescription insertNewObjectForEntityForName:@"PLSItem" inManagedObjectContext:context];
                plsItem.title = self.loadedPlaylist;
                plsItem.track = track;
                plsItem.nextPLS = nil;
                if ([self.playListResultsController.fetchedObjects count] > 0) {
                    NSIndexPath *path = [NSIndexPath indexPathForRow:([self.playListResultsController.fetchedObjects count]-1) inSection:0];
                    PLSItem *last = [self.playListResultsController objectAtIndexPath:path];
                    last.nextPLS = plsItem;
                    plsItem.position = [NSNumber numberWithInt:[last.position intValue] + 1];
                } else {
                    plsItem.position = [NSNumber numberWithInt:0];
                }
                // Save the context.
                NSError *error = nil;
                if (![context save:&error]) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                }
            }
        }
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Add To Playlist"
                                                        message:@"Please create or load a playlist to add to"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)displayPlaylistsToChoose:(UIButton *)sender {
    if (_playlistPicker== nil) {
        //Create the ColorPickerViewController.
        _playlistPicker = [[LoadPlaylistSelector alloc] initWithStyle:UITableViewStylePlain];
        
        //Set this VC as the delegate.
        _playlistPicker.delegate = self;
    }
    
    if (!_playlistPickerPopover.popoverVisible && _playlistPickerPopover != nil) {
        _playlistPickerPopover = nil;
    }
    
    _playlistPicker.playlists = self.playlists;
    [_playlistPicker changeContentSize];
    
    if (_playlistPickerPopover == nil) {
        //The color picker popover is not showing. Show it.
        _playlistPickerPopover = [[UIPopoverController alloc] initWithContentViewController:_playlistPicker];
        [_playlistPickerPopover presentPopoverFromRect:sender.frame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        //The color picker popover is showing. Hide it.
        [_playlistPickerPopover dismissPopoverAnimated:YES];
        _playlistPickerPopover = nil;
    }
}

-(void)loadPlaylist:(NSString *)playlist {
    self.loadedPlaylist = playlist;
    [self setDefaults];
    if (_playlistPickerPopover) {
        [_playlistPickerPopover dismissPopoverAnimated:YES];
        _playlistPickerPopover = nil;
    }
    self.playListResultsController = nil;
    [self.playlistTableView reloadData];
}

-(void)deletePlaylist:(NSString *)playlist {
    NSManagedObjectContext *context = self.managedObjectContext;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"PLSItem" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title contains[cd] %@", playlist]];
    
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fetchRequest error:&error];
    for (PLSItem *item in results) {
        [context deleteObject:item];
    }
    error = nil;
    if (![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    if ([playlist isEqualToString:self.loadedPlaylist]) {
        self.loadedPlaylist = nil;
        self.playListResultsController = nil;
        [self.playlistTableView reloadData];
    }
}

- (IBAction)addNewPlaylist:(UIButton *)sender {
    [self newPlaylist];
}

- (void)newPlaylist {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"New Playlist"
                                                    message:@"Enter the name for the new playlist."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Done", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        NSString *text = [[alertView textFieldAtIndex:0] text];
        self.loadedPlaylist = text;
        [self.playlists addObject:text];
        [self.playlistTableView reloadData];
        [self setDefaults];
        self.playListResultsController = nil;
        [self.playlistTableView reloadData];
    }
}

-(void)setDefaults {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loadedPlaylist forKey:@"loadedPlaylist"];
    [defaults setObject:self.playlists forKey:@"playlists"];
    [defaults synchronize];
}

#pragma mark - Table View

- (NSFetchedResultsController *)fetchedResultsControllerForTableView:(UITableView *)tableView
{
    return [tableView isEqual:self.playlistTableView] ? self.playListResultsController : self.fetchedResultsController;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSFetchedResultsController *controller = [self fetchedResultsControllerForTableView:tableView];
    id <NSFetchedResultsSectionInfo> sectionInfo = [controller sections][section];
    NSInteger numberofObjects = [sectionInfo numberOfObjects];
    if (tableView == self.playlistTableView && numberofObjects == 0) {
        [self.messageLabel setHidden:NO];
    } else if (tableView == self.playlistTableView && numberofObjects >0) {
        [self.messageLabel setHidden:YES];
    }
    return numberofObjects;
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
    [self fetchedResultsController:[self fetchedResultsControllerForTableView:tableView] configureCell:cell atIndexPath:indexPath];

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
    //cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - TableView Editing

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.playlistTableView) {
            PLSItem *current = [self.playListResultsController objectAtIndexPath:indexPath];
            NSIndexPath* prevIndexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
            if (current != [self.playListResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) {
                PLSItem *last = [self.playListResultsController objectAtIndexPath:prevIndexPath];
                last.nextPLS = current.nextPLS;
            }
            current.nextPLS = nil;
        }
        NSManagedObjectContext *context = self.managedObjectContext;
        [context deleteObject:[[self fetchedResultsControllerForTableView:tableView] objectAtIndexPath:indexPath]];
        
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

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([[tableView indexPathsForSelectedRows] containsObject:indexPath]) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return nil;
    }
    
    return indexPath;
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    [self fixItemPositionsBetween:fromIndexPath to:toIndexPath];

    PLSItem *movingItem = [self.playListResultsController objectAtIndexPath:fromIndexPath];
    NSIndexPath* prevIndexPath = [NSIndexPath indexPathForRow:fromIndexPath.row-1 inSection:fromIndexPath.section];
    if (movingItem != [self.playListResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]]) {
        PLSItem *prev = [self.playListResultsController objectAtIndexPath:prevIndexPath];
        prev.nextPLS = movingItem.nextPLS;
    }
    movingItem.nextPLS = nil;
    
    PLSItem *prev = nil;
    PLSItem *temp = nil;
    if (fromIndexPath < toIndexPath) {
        prev = [self.playListResultsController objectAtIndexPath:toIndexPath];
        
    } else {
        if ([NSIndexPath indexPathForRow:0 inSection:0] != toIndexPath) {
            NSIndexPath* prevIndexPath = [NSIndexPath indexPathForRow:toIndexPath.row-1 inSection:toIndexPath.section];
            prev = [self.playListResultsController objectAtIndexPath:prevIndexPath];
        } else {
            temp = [self.playListResultsController objectAtIndexPath:toIndexPath];
        }
    }
    if (prev) {
        temp = prev.nextPLS;
        prev.nextPLS = movingItem;
    }
    movingItem.nextPLS = temp;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }

}

- (void)fixItemPositionsBetween:(NSIndexPath *)fromIndex to:(NSIndexPath *)toIndex {
    if (fromIndex < toIndex) {
        PLSItem *item = [self.playListResultsController objectAtIndexPath:fromIndex];
        item.position = [NSNumber numberWithInteger:toIndex.row];
        item = item.nextPLS;
        while ([item.position integerValue] != toIndex.row) {
            item.position = [NSNumber numberWithInteger:([item.position integerValue] -1)];
            item = item.nextPLS;
        }
        item.position = [NSNumber numberWithInteger:[item.position integerValue] -1];
    } else {
        PLSItem *item = [self.playListResultsController objectAtIndexPath:toIndex];
        while ([item.position integerValue] != fromIndex.row) {
            item.position = [NSNumber numberWithInteger:([item.position integerValue] +1)];
            item = item.nextPLS;
        }
        item.position = [NSNumber numberWithInteger:toIndex.row];
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (IBAction)editTableView:(UIButton *)sender {
    if (self.editing) {
        [super setEditing:NO animated:YES];
        [self.playlistTableView setEditing:NO  animated:YES];
        [sender setTitle:@"Edit" forState:UIControlStateNormal];
        [self.playlistTableView reloadData];
    } else {
        [super setEditing:YES animated:YES];
        [self.playlistTableView setEditing:YES animated:YES];
        [sender setTitle:@"Done" forState:UIControlStateNormal];
        [self.playlistTableView reloadData];
    }
}

#pragma mark - Search Bar updates

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Track" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    NSPredicate *p1 = [NSPredicate predicateWithFormat:@"type contains[cd] %@", self.selectedSection];
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
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor;
    if (self.sortBy) {
        sortDescriptor = [[NSSortDescriptor alloc] initWithKey:self.sortBy ascending:YES];
        NSLog(@"sortBy %@", self.sortBy);
    }else {
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

- (NSFetchedResultsController *)playListResultsController
{
    if (_playListResultsController != nil) {
        return _playListResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"PLSItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    if ([self.loadedPlaylist length] > 0) {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", self.loadedPlaylist];
    } else {
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"title contains[cd] %@", @"asudikyfgjhasdufygjh"];
    }
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"position" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.playListResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.playListResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _playListResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = [controller isEqual:self.fetchedResultsController] ? self.tableView : self.playlistTableView;
    [tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    UITableView *tableView = [controller isEqual:self.fetchedResultsController] ? self.tableView : self.playlistTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
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
    UITableView *tableView = [controller isEqual:self.fetchedResultsController] ? self.tableView : self.playlistTableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self fetchedResultsController:controller configureCell:(ItemCell*)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    UITableView *tableView = [controller isEqual:self.fetchedResultsController] ? self.tableView : self.playlistTableView;
    [tableView endUpdates];
}

- (void)fetchedResultsController:(NSFetchedResultsController *)controller configureCell:(ItemCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
    Track *track = nil;
    if ([controller isEqual:self.fetchedResultsController]) {
        track = [controller objectAtIndexPath:indexPath];
    } else {
        PLSItem *item = [controller objectAtIndexPath:indexPath];
        track = item.track;
    }
    cell.titleLabel.text = track.title;
    cell.descriptionLabel.text = track.desc;
    float duration = [track.length floatValue];
    int minutes = floor(duration / 60);
    int seconds = trunc(duration - minutes * 60);
    cell.lengthLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}




@end
