//
//  LoadURLView.m
//  Tablet Radio
//
//  Created by Administrator on 02/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import "LoadURLView.h"
@interface LoadURLView()

@property (nonatomic, strong) NSArray *arrItemTypes;
@property (strong, nonatomic) AEAudioFilePlayer *player;
@property (nonatomic) double timeLeft;
@end

@implementation LoadURLView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.arrItemTypes = [[NSArray alloc] initWithObjects:@"Music", @"Beds", @"Jingles", @"Other", nil];
    self.titleInput.delegate = self;
    self.descriptionInput.delegate = self;
    self.typeInput.delegate = self;
    self.typeInput.dataSource = self;
    self.player = [AEAudioFilePlayer audioFilePlayerWithURL:self.url audioController:_controller error:NULL];
    self.timeLeft = _player.duration;
    NSLog(@"%f", self.timeLeft);
}

- (IBAction)done:(UIButton *)sender {
    [self.delegate userDoneWithTitle:self.titleInput.text description:self.descriptionInput.text type:[self.arrItemTypes objectAtIndex:[self.typeInput selectedRowInComponent:0]] length:self.timeLeft andURL:self.url];
}

#pragma mark - UITextField Delegate method implementation

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    
    return YES;
}


#pragma mark - UIPickerView method implementation

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}


-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.arrItemTypes.count;
}


-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [self.arrItemTypes objectAtIndex:row];
}

@end
