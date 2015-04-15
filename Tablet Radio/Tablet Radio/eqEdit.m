//
//  eqEdit.m
//  Tablet Radio
//
//  Created by Administrator on 28/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "eqEdit.h"


@interface eqEdit ()

@end

@implementation eqEdit

- (id)init {
    if ( !(self = [super initWithStyle:UITableViewStyleGrouped]) ) return nil;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

#define kAuxiliaryViewTag 251


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 3) return 1;
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // Configure the cell...
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(cell.bounds.size.width - 170, 0, 150, cell.bounds.size.height)];
    slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cell addSubview:slider];
    [[cell viewWithTag:kAuxiliaryViewTag] removeFromSuperview];
    slider.tag = kAuxiliaryViewTag;

    Float32 value;
    switch (indexPath.section) {
        case 0: {
            switch ( indexPath.row ) {
                case 0: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Frequency, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 22050.0;
                    slider.minimumValue = 20.0;
                    cell.textLabel.text = @"Frequency";
                    slider.value = value;
                    [slider addTarget:self action:@selector(frequency1:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 1: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Bandwidth, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 5.0;
                    slider.minimumValue = 0.05;
                    cell.textLabel.text = @"Band-Width";
                    slider.value = value;
                    [slider addTarget:self action:@selector(bandWidth1:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 2: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Gain, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 24.0;
                    slider.minimumValue = -96.0;
                    cell.textLabel.text = @"Gain";
                    slider.value = value;
                    [slider addTarget:self action:@selector(gain1:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
            }
            break;
        }
        case 1: {
            switch ( indexPath.row ) {
                case 0: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Frequency+1, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 22050.0;
                    slider.minimumValue = 20.0;
                    cell.textLabel.text = @"Frequency";
                    slider.value = value;
                    [slider addTarget:self action:@selector(frequency2:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 1: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Bandwidth+1, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 5.0;
                    slider.minimumValue = 0.05;
                    cell.textLabel.text = @"Band-Width";
                    slider.value = value;
                    [slider addTarget:self action:@selector(bandWidth2:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 2: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Gain+1, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 24.0;
                    slider.minimumValue = -96.0;
                    cell.textLabel.text = @"Gain";
                    slider.value = value;
                    [slider addTarget:self action:@selector(gain2:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
            }
            break;
        }
        case 2: {
            switch ( indexPath.row ) {
                case 0: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Frequency+2, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 22050.0;
                    slider.minimumValue = 20.0;
                    cell.textLabel.text = @"Frequency";
                    slider.value = value;
                    [slider addTarget:self action:@selector(frequency3:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 1: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Bandwidth+2, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 5.0;
                    slider.minimumValue = 0.05;
                    cell.textLabel.text = @"Band-Width";
                    slider.value = value;
                    [slider addTarget:self action:@selector(bandWidth3:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
                case 2: {
                    AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_Gain+2, kAudioUnitScope_Global, 0, &value);
                    slider.maximumValue = 24.0;
                    slider.minimumValue = -96.0;
                    cell.textLabel.text = @"Gain";
                    slider.value = value;
                    [slider addTarget:self action:@selector(gain3:) forControlEvents:UIControlEventValueChanged];
                    break;
                }
            }
            break;
        }
        case 3: {
            AudioUnitGetParameter(self.filter.audioUnit, kAUNBandEQParam_GlobalGain, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 24.0;
            slider.minimumValue = -96.0;
            cell.textLabel.text = @"Master Gain";
            slider.value = value;
            [slider addTarget:self action:@selector(masterGain:) forControlEvents:UIControlEventValueChanged];
            break;
        }
    }
    return cell;
}


- (void)frequency1:(UISlider *)sender {
    Float32 freq = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Frequency, kAudioUnitScope_Global, 0, freq, 0);
}

- (void)frequency2:(UISlider *)sender {
    Float32 freq = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Frequency+1, kAudioUnitScope_Global, 0, freq, 0);
}

- (void)frequency3:(UISlider *)sender {
    Float32 freq = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Frequency+2, kAudioUnitScope_Global, 0, freq, 0);
}

- (void)bandWidth1:(UISlider *)sender {
    Float32 bandWidth = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Bandwidth, kAudioUnitScope_Global, 0, bandWidth, 0);
}

- (void)bandWidth2:(UISlider *)sender {
    Float32 bandWidth = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Bandwidth+1, kAudioUnitScope_Global, 0, bandWidth, 0);
}

- (void)bandWidth3:(UISlider *)sender {
    Float32 bandWidth = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Bandwidth+2, kAudioUnitScope_Global, 0, bandWidth, 0);
}

- (void)gain1:(UISlider *)sender {
    Float32 gain = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Gain, kAudioUnitScope_Global, 0, gain, 0);
}

- (void)gain2:(UISlider *)sender {
    Float32 gain = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Gain+1, kAudioUnitScope_Global, 0, gain, 0);
}

- (void)gain3:(UISlider *)sender {
    Float32 gain = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_Gain+2, kAudioUnitScope_Global, 0, gain, 0);
}

- (void)masterGain:(UISlider *)sender {
    Float32 gain = sender.value;
    AudioUnitSetParameter(self.filter.audioUnit, kAUNBandEQParam_GlobalGain, kAudioUnitScope_Global, 0, gain, 0);
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
