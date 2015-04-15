//
//  LoadURLView.h
//  Tablet Radio
//
//  Created by Administrator on 02/03/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheAmazingAudioEngine.h"

@protocol LoadURLView

- (void)userDoneWithTitle:(NSString *)title description:(NSString *)description type:(NSString *)type length:(double)length andURL:(NSURL *)url;

@end

@interface LoadURLView : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
@property (strong, nonatomic) id delegate;
@property (weak, nonatomic) IBOutlet UITextField *titleInput;
@property (weak, nonatomic) IBOutlet UITextField *descriptionInput;
@property (weak, nonatomic) IBOutlet UIPickerView *typeInput;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) NSURL *url;
@property (strong, nonatomic) AEAudioController *controller;

- (IBAction)done:(UIButton *)sender;


@end
