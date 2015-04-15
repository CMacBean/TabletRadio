//
//  AUGraphController.h
//  Tablet Radio
//
//  Created by Administrator on 02/11/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>

@interface AUGraphController : NSObject
{
    AUGraph processingGraph;
    AudioUnit mixerUnit;
    AudioUnit ioUnit;
    AudioUnit playerUnit;
    
    AudioStreamBasicDescription clientFormat;
    AudioStreamBasicDescription outputFormat;
}

- (void)initializeAUGraph;
- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isOnValue;
- (void)setInputVolume:(UInt32)inputNum value:(AudioUnitParameterValue)value;
- (void)setOutputVolume:(AudioUnitParameterValue)value;

- (void)startAUGraph;
- (void)stopAUGraph;

@end

