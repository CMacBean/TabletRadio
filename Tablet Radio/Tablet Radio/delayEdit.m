//
//  delayEdit.m
//  Tablet Radio
//
//  Created by Administrator on 28/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "delayEdit.h"

@interface delayEdit ()

@end

@implementation delayEdit

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
            sectionName = @"Delay Time";
            break;
        case 2:
            sectionName = @"Feedback";
            break;
        case 3:
            sectionName = @"Lowpass Cut";
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
            AudioUnitGetParameter(self.filter.audioUnit, kDelayParam_WetDryMix, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 100.0;
            slider.minimumValue = 0.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.02f%%",value];
            [slider addTarget:self action:@selector(dryWetChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 1: {
            AudioUnitGetParameter(self.filter.audioUnit, kDelayParam_DelayTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 2.0;
            slider.minimumValue = 0.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.02fs",value];
            [slider addTarget:self action:@selector(delayTimeChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 2: {
            AudioUnitGetParameter(self.filter.audioUnit, kDelayParam_Feedback, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 100;
            slider.minimumValue = 0.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.02f%%",value];
            [slider addTarget:self action:@selector(feedbackChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 3: {
            AudioUnitGetParameter(self.filter.audioUnit, kDelayParam_LopassCutoff, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 22050.0;
            slider.minimumValue = 10.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fHz",value];
            [slider addTarget:self action:@selector(lowpassCutChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
    }
    return cell;
}

- (void)dryWetChanged:(UISlider *)sender {
    Float32 drywet = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.02f%%",drywet];
    AudioUnitSetParameter(self.filter.audioUnit, kDelayParam_WetDryMix, kAudioUnitScope_Global, 0, drywet, 0);
}

- (void)delayTimeChanged:(UISlider *)sender {
    Float32 delay = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.02fs",delay];
    AudioUnitSetParameter(self.filter.audioUnit, kDelayParam_DelayTime, kAudioUnitScope_Global, 0, delay, 0);
}

- (void)feedbackChanged:(UISlider *)sender {
    Float32 feedback = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.02f%%",feedback];
    AudioUnitSetParameter(self.filter.audioUnit, kDelayParam_Feedback, kAudioUnitScope_Global, 0, feedback, 0);
}

- (void)lowpassCutChanged:(UISlider *)sender {
    Float32 lowpass = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fHz",lowpass];
    AudioUnitSetParameter(self.filter.audioUnit, kDelayParam_LopassCutoff, kAudioUnitScope_Global, 0, lowpass, 0);
}

@end
