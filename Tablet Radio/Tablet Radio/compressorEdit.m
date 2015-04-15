//
//  compressorEdit.m
//  Tablet Radio
//
//  Created by Administrator on 01/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "compressorEdit.h"

@interface compressorEdit ()

@end

@implementation compressorEdit

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
            sectionName = @"Threshold";
            break;
        case 1:
            sectionName = @"Attack";
            break;
        case 2:
            sectionName = @"Release";
            break;
        case 3:
            sectionName = @"Headroom";
            break;
        case 4:
            sectionName = @"Master Gain";
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
            AudioUnitGetParameter(self.filter.audioUnit, kDynamicsProcessorParam_Threshold, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 20.0;
            slider.minimumValue = -40.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fdB",value];
            [slider addTarget:self action:@selector(thresholdChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 1: {
            AudioUnitGetParameter(self.filter.audioUnit, kDynamicsProcessorParam_AttackTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 0.2;
            slider.minimumValue = 0.001;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fms",(value*1000)];
            [slider addTarget:self action:@selector(attackChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 2: {
            AudioUnitGetParameter(self.filter.audioUnit, kDynamicsProcessorParam_ReleaseTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 3.0;
            slider.minimumValue = 0.01;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fms",(value*1000)];
            [slider addTarget:self action:@selector(releaseChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 3: {
            AudioUnitGetParameter(self.filter.audioUnit, kDynamicsProcessorParam_HeadRoom, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 40.0;
            slider.minimumValue = 0.1;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fdB",value];
            [slider addTarget:self action:@selector(headroomChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 4: {
            AudioUnitGetParameter(self.filter.audioUnit, kDynamicsProcessorParam_MasterGain, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 40.0;
            slider.minimumValue = -40.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fdB",value];
            [slider addTarget:self action:@selector(gainChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
    }
    return cell;
}

- (void)thresholdChanged:(UISlider *)sender {
    Float32 threshold = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.fdB",threshold];
    AudioUnitSetParameter(self.filter.audioUnit, kDynamicsProcessorParam_Threshold, kAudioUnitScope_Global, 0, threshold, 0);
}

- (void)attackChanged:(UISlider *)sender {
    Float32 attack = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.fms",(attack*1000)];
    AudioUnitSetParameter(self.filter.audioUnit, kDynamicsProcessorParam_AttackTime, kAudioUnitScope_Global, 0, attack, 0);
}

- (void)releaseChanged:(UISlider *)sender {
    Float32 release = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.fms",(release*1000)];
    AudioUnitSetParameter(self.filter.audioUnit, kDynamicsProcessorParam_ReleaseTime, kAudioUnitScope_Global, 0, release, 0);
}

- (void)headroomChanged:(UISlider *)sender {
    Float32 headroom = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:3]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.fdB",headroom];
    AudioUnitSetParameter(self.filter.audioUnit, kDynamicsProcessorParam_HeadRoom, kAudioUnitScope_Global, 0, headroom, 0);
}

- (void)gainChanged:(UISlider *)sender {
    Float32 gain = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:4]] accessoryView];
    label.text = [NSString stringWithFormat:@"%0.fdB",gain];
    AudioUnitSetParameter(self.filter.audioUnit, kDynamicsProcessorParam_MasterGain, kAudioUnitScope_Global, 0, gain, 0);
}

@end
