//
//  reverbEdit.m
//  Tablet Radio
//
//  Created by Administrator on 01/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "reverbEdit.h"

@interface reverbEdit ()

@end

@implementation reverbEdit

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
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *sectionName;
    switch (section)
    {
        case 0:
            sectionName = @"Wet/Dry";
            break;
        case 1:
            sectionName = @"Min Delay";
            break;
        case 2:
            sectionName = @"Max Delay";
            break;
        case 3:
            sectionName = @"Randomize";
            break;
        case 4:
            sectionName = @"Gain";
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    // Configure the cell...
    if ( !cell ) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(cell.bounds.size.width - 95, 0, 100, cell.bounds.size.height) ];
    label.textAlignment = NSTextAlignmentRight;
    cell.accessoryView = label;
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(15, 0, 220, cell.bounds.size.height)];
    slider.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [cell addSubview:slider];
    [[cell viewWithTag:kAuxiliaryViewTag] removeFromSuperview];
    slider.tag = kAuxiliaryViewTag;
    Float32 value;
    switch ( indexPath.section ) {
        case 0: {
            AudioUnitGetParameter(self.filter.audioUnit, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 100.0;
            slider.minimumValue = 0.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.02f%%",value];
            [slider addTarget:self action:@selector(dryWetChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 1: {
            AudioUnitGetParameter(self.filter.audioUnit, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 1.0;
            slider.minimumValue = 0.0001;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fms",(value*1000)];
            [slider addTarget:self action:@selector(minDelayChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 2: {
            AudioUnitGetParameter(self.filter.audioUnit, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 1.0;
            slider.minimumValue = 0.0001;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fms",(value*1000)];
            [slider addTarget:self action:@selector(maxDelayChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 3: {
            AudioUnitGetParameter(self.filter.audioUnit, kReverb2Param_RandomizeReflections, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 1000.0;
            slider.minimumValue = 1.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.f",value];
            [slider addTarget:self action:@selector(randomizeChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        } case 4: {
            AudioUnitGetParameter(self.filter.audioUnit, kReverb2Param_Gain, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 20.0;
            slider.minimumValue = -20.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fdB",value];
            [slider addTarget:self action:@selector(gainChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
    }
    return cell;
}

- (void)dryWetChanged:(UISlider *)sender {
    Float32 drywet = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.02f%%",drywet];
    AudioUnitSetParameter(self.filter.audioUnit, kReverb2Param_DryWetMix, kAudioUnitScope_Global, 0, drywet, 0);
}

- (void)minDelayChanged:(UISlider *)sender {
    Float32 delay = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fms",(delay*1000)];
    AudioUnitSetParameter(self.filter.audioUnit, kReverb2Param_MinDelayTime, kAudioUnitScope_Global, 0, delay, 0);
}

- (void)maxDelayChanged:(UISlider *)sender {
    Float32 delay = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fms",(delay*1000)];
    AudioUnitSetParameter(self.filter.audioUnit, kReverb2Param_MaxDelayTime, kAudioUnitScope_Global, 0, delay, 0);
}

- (void)randomizeChanged:(UISlider *)sender {
    Float32 randomize = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.f",randomize];
    AudioUnitSetParameter(self.filter.audioUnit, kReverb2Param_RandomizeReflections, kAudioUnitScope_Global, 0, randomize, 0);
}

- (void)gainChanged:(UISlider *)sender {
    Float32 gain = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fdB",gain];
    AudioUnitSetParameter(self.filter.audioUnit, kReverb2Param_Gain, kAudioUnitScope_Global, 0, gain, 0);
}

@end
