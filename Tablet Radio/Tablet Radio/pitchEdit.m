//
//  pitchEdit.m
//  Tablet Radio
//
//  Created by Administrator on 01/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "pitchEdit.h"

@interface pitchEdit ()

@end

@implementation pitchEdit

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
    return 3;
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
            sectionName = @"Rate";
            break;
        case 1:
            sectionName = @"Cent";
            break;
        case 2:
            sectionName = @"Overlap";
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
            AudioUnitGetParameter(self.filter.audioUnit, kNewTimePitchParam_Rate, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 32.0;
            slider.minimumValue = 1/32;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.02f%%",value];
            [slider addTarget:self action:@selector(rateChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 1: {
            AudioUnitGetParameter(self.filter.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 2400.0;
            slider.minimumValue = -2400;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fc",value];
            [slider addTarget:self action:@selector(pitchChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 2: {
            AudioUnitGetParameter(self.filter.audioUnit, kNewTimePitchParam_Overlap, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 32.0;
            slider.minimumValue = 3.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.02f",value];
            [slider addTarget:self action:@selector(overlapChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
    }
    return cell;
}

- (void)rateChanged:(UISlider *)sender {
    Float32 rate = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.02f%%",rate];
    AudioUnitSetParameter(self.filter.audioUnit, kNewTimePitchParam_Rate, kAudioUnitScope_Global, 0, rate, 0);
}

- (void)pitchChanged:(UISlider *)sender {
    Float32 pitch = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.fc",pitch];
    AudioUnitSetParameter(self.filter.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, pitch, 0);
}

- (void)overlapChanged:(UISlider *)sender {
    Float32 overlap = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.02f",overlap];
    AudioUnitSetParameter(self.filter.audioUnit, kNewTimePitchParam_Pitch, kAudioUnitScope_Global, 0, overlap, 0);
}

@end
