//
//  limiterEdit.m
//  Tablet Radio
//
//  Created by Administrator on 01/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "limiterEdit.h"

@interface limiterEdit ()

@end

@implementation limiterEdit

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
            sectionName = @"Attack";
            break;
        case 1:
            sectionName = @"Decay";
            break;
        case 2:
            sectionName = @"Pre-Gain";
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
            AudioUnitGetParameter(self.filter.audioUnit, kLimiterParam_AttackTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 0.03;
            slider.minimumValue = 0.001;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fms",(value*1000)];
            [slider addTarget:self action:@selector(attackChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 1: {
            AudioUnitGetParameter(self.filter.audioUnit, kLimiterParam_DecayTime, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 0.06;
            slider.minimumValue = 0.001;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fms",(value*1000)];
            [slider addTarget:self action:@selector(decayChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
        case 2: {
            AudioUnitGetParameter(self.filter.audioUnit, kLimiterParam_PreGain, kAudioUnitScope_Global, 0, &value);
            slider.maximumValue = 40.0;
            slider.minimumValue = -40.0;
            slider.value = value;
            label.text =  [NSString stringWithFormat:@"%0.fdB",value];
            [slider addTarget:self action:@selector(pregainChanged:) forControlEvents:UIControlEventValueChanged];
            break;
        }
    }
    return cell;
}

- (void)attackChanged:(UISlider *)sender {
    Float32 attack = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fms",(attack*1000)];
    AudioUnitSetParameter(self.filter.audioUnit, kLimiterParam_AttackTime, kAudioUnitScope_Global, 0, attack, 0);
}

- (void)decayChanged:(UISlider *)sender {
    Float32 decay = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fms",(decay*1000)];
    AudioUnitSetParameter(self.filter.audioUnit, kLimiterParam_DecayTime, kAudioUnitScope_Global, 0, decay, 0);
}

- (void)pregainChanged:(UISlider *)sender {
    Float32 pregain = sender.value;
    UILabel *label = (UILabel *)[[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]] accessoryView];
    label.text =  [NSString stringWithFormat:@"%0.fdB",pregain];
    AudioUnitSetParameter(self.filter.audioUnit, kDelayParam_Feedback, kAudioUnitScope_Global, 0, pregain, 0);
}

@end
