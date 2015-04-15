//
//  EffectsViewController.m
//  Tablet Radio
//
//  Created by Administrator on 25/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "EffectsViewController.h"
#import "AEAudioUnitFilter.h"
#import "delayEdit.h"
#import "eqEdit.h"
#import "compressorEdit.h"
#import "limiterEdit.h"
#import "reverbEdit.h"
#import "pitchEdit.h"

@interface EffectsViewController ()

@property (nonatomic) AudioComponentDescription component;
@property (weak, nonatomic) AEAudioController *controller;

@end

@implementation EffectsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.controller = self.deck.controller;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Action Sheet

- (IBAction)addEffect:(UIBarButtonItem *)sender {
    NSArray *array = nil;
    if (self.channel == 1) {
        array = [NSArray arrayWithObjects:@"EQ", @"Compressor", @"limiter", @"Reverb", @"Delay",nil];
    } else {
        array = [NSArray arrayWithObjects:@"EQ", @"Compressor", @"limiter", @"Reverb", @"Delay", @"Pitch-Shifter", nil];
    }
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"What do you want to do with the file?"
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                               destructiveButtonTitle:nil
                                                    otherButtonTitles:nil];
    
    for (NSString *effect in array) {
        [actionSheet addButtonWithTitle:effect];
    }
    
    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];

    [actionSheet showFromBarButtonItem:sender animated:YES];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"%ld",(long)buttonIndex);
    NSLog(@"Wants to add: %@", [actionSheet buttonTitleAtIndex:buttonIndex]);
    if (buttonIndex < 5 || (self.channel == 0 && buttonIndex != 6)) {
        self.deck.micChannel = self.micChannel;
        [self.deck addFilter:buttonIndex toChannel:self.channel];
    }
    
    NSString *filterName = nil;
    switch (buttonIndex) {
        case 0: filterName = @"EQ"; break;
        case 1: filterName = @"Compressor"; break;
        case 2: filterName = @"Limiter"; break;
        case 3: filterName = @"Reverb"; break;
        case 4: filterName = @"Delay"; break;
        case 5: filterName = @"Pitch"; break;
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.channel == 0) {
        if (self.isCueing) {
            count = [[_controller filtersForChannel:self.deck.filePlayer] count];
        } else {
            count = [[_controller filtersForChannelGroup:self.deck.group] count];
        }
    } else if (self.channel == 1){
        count = [[_controller filtersForChannel:self.micChannel] count];
    } else {
        count = [[_controller filtersForChannelGroup:self.deck.mainGroup] count];
    }
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"effectCell" forIndexPath:indexPath];
    UISwitch *bypass = [[UISwitch alloc] initWithFrame:CGRectMake(cell.bounds.size.width/2, cell.bounds.size.height - 45, 0, 0)];
    [cell addSubview:bypass];
    [[cell viewWithTag:indexPath.row] removeFromSuperview];
    [bypass addTarget:self action:@selector(bypassChanged:) forControlEvents:UIControlEventValueChanged];
    bypass.tag = indexPath.row;
    bypass.on = YES;
    // Configure the cell...
    if (self.channel == 0) {
        cell.textLabel.text = [self.deck.filters objectAtIndex:indexPath.row];
        if (self.isCueing) {
            [bypass setOn:![[[_controller filtersForChannel:self.deck.filePlayer] objectAtIndex:indexPath.row] bypassed]];
        } else {
            [bypass setOn:![[[_controller filtersForChannelGroup:self.deck.group] objectAtIndex:indexPath.row] bypassed]];
        }
        
    } else if (self.channel == 1) {
        cell.textLabel.text = [self.deck.inputFilters objectAtIndex:indexPath.row];
        [bypass setOn:![[[_controller filtersForChannel:self.micChannel] objectAtIndex:indexPath.row] bypassed]];
    } else {
        cell.textLabel.text = [self.deck.outputFilters objectAtIndex:indexPath.row];
        [bypass setOn:![[[_controller filtersForChannelGroup:self.deck.mainGroup] objectAtIndex:indexPath.row] bypassed]];
    }
    return cell;
}

- (void)bypassChanged:(UISwitch *)sender {
    AEAudioUnitFilter *filter;
    if (self.channel == 0) {
        if (self.isCueing) {
            filter = [[_controller filtersForChannel:self.deck.filePlayer] objectAtIndex:sender.tag];
        } else {
            filter = [[_controller filtersForChannelGroup:self.deck.group] objectAtIndex:sender.tag];
        }
    } else if (self.channel == 1){
        filter = [[_controller filtersForChannel:self.micChannel] objectAtIndex:sender.tag];
    } else {
        filter = [[_controller filtersForChannelGroup:self.deck.mainGroup] objectAtIndex:sender.tag];
    }
    [filter setBypassed:!sender.isOn];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.deck removeFilterAtIndex:indexPath.row fromChannel:self.channel whilstCueing:self.isCueing];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *segue = cell.textLabel.text;
    AEAudioUnitFilter *filter = nil;
    if (self.channel == 0) {
        if (self.isCueing) {
            filter = [[_controller filtersForChannel:self.deck.filePlayer] objectAtIndex:indexPath.row];
        } else {
            filter = [[_controller filtersForChannelGroup:self.deck.group] objectAtIndex:indexPath.row];
        }
    } else if (self.channel == 1){
        filter = [[_controller filtersForChannel:self.micChannel] objectAtIndex:indexPath.row];
    } else {
        filter = [[_controller filtersForChannelGroup:self.deck.mainGroup] objectAtIndex:indexPath.row];
    }
    if ([segue isEqualToString:@"Delay"]) {
        delayEdit *vc = [[delayEdit alloc] init];
        vc.filter = filter;
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([segue isEqualToString:@"EQ"]) {
        eqEdit *vc = [[eqEdit alloc] init];
        vc.filter = filter;
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([segue isEqualToString:@"Compressor"]) {
        compressorEdit *vc = [[compressorEdit alloc] init];
        vc.filter = filter;
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([segue isEqualToString:@"Limiter"]) {
        limiterEdit *vc = [[limiterEdit alloc] init];
        vc.filter = filter;
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([segue isEqualToString:@"Reverb"]) {
        reverbEdit *vc = [[reverbEdit alloc] init];
        vc.filter = filter;
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([segue isEqualToString:@"Pitch"]) {
        pitchEdit *vc = [[pitchEdit alloc] init];
        vc.filter = filter;
        vc.modalPresentationStyle = UIModalPresentationCurrentContext;
        [self.navigationController pushViewController:vc animated:YES];
    }
    if (self.isCorrect) {
        [[self delegate] edited];
    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation


// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSInteger index = [[self.tableView indexPathForSelectedRow] row];
    AEAudioUnitFilter *filter = nil;
    if (self.channel == 0) {
        filter = [[_controller filtersForChannelGroup:self.deck.group] objectAtIndex:index];
    } else if (self.channel == 1){
        filter = [[_controller filtersForChannel:self.micChannel] objectAtIndex:index];
    } else {
        filter = [[_controller filtersForChannelGroup:self.deck.mainGroup] objectAtIndex:index];
    }
    // Get the new view controller using [segue destinationViewController].
    if ([[segue identifier] isEqualToString:@"Delay'"]) {
        delayEdit *vc = [segue destinationViewController];
        [vc setFilter:filter];
    }

}


@end
