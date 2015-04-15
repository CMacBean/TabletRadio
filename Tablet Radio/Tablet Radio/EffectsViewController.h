//
//  EffectsViewController.h
//  Tablet Radio
//
//  Created by Administrator on 25/02/2015.
//  Copyright (c) 2015 Beanie. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Deck.h"
#import "TheAmazingAudioEngine.h"
#import "AEPlaythroughChannel.h"


#import "UITesterController.h"

@protocol EffectsViewController <NSObject>

-(void)edited;

@end

@interface EffectsViewController : UITableViewController <UIActionSheetDelegate, UIPopoverControllerDelegate>

@property (weak, nonatomic) Deck *deck;
@property (nonatomic) NSInteger channel;
@property (weak, nonatomic) AEPlaythroughChannel *micChannel;
@property (nonatomic) BOOL isCueing;

@property (strong, nonatomic) id delegate;
@property (nonatomic) BOOL isCorrect;

@end
