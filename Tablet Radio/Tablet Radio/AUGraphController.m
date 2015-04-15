//
//  AUGraphController.m
//  Tablet Radio
//
//  Created by Administrator on 02/11/2014.
//  Copyright (c) 2014 Beanie. All rights reserved.
//

#import "AUGraphController.h"

const Float64 kGraphSampleRate = 44100.0;

@implementation AUGraphController

- (void)initializeAUGraph
{
    printf("initializeAUGraph\n");
    
    AUNode ioNode;
    AUNode mixerNode;
    AUNode playerNode;
    
    printf("create client ASBD\n");
    
    size_t bytesPerSample = sizeof (AudioUnitSampleType);
    
    clientFormat.mFormatID          = kAudioFormatLinearPCM;
    clientFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    clientFormat.mBytesPerPacket    = bytesPerSample;
    clientFormat.mBytesPerFrame     = bytesPerSample;
    clientFormat.mFramesPerPacket   = 1;
    clientFormat.mBitsPerChannel    = 8 * bytesPerSample;
    clientFormat.mChannelsPerFrame  = 2;           // 2 indicates stereo
    clientFormat.mSampleRate        = kGraphSampleRate;
    
    printf("create output ASBD\n");
    
    outputFormat.mFormatID          = kAudioFormatLinearPCM;
    outputFormat.mFormatFlags       = kAudioFormatFlagsAudioUnitCanonical;
    outputFormat.mBytesPerPacket    = bytesPerSample;
    outputFormat.mBytesPerFrame     = bytesPerSample;
    outputFormat.mFramesPerPacket   = 1;
    outputFormat.mBitsPerChannel    = 8 * bytesPerSample;
    outputFormat.mChannelsPerFrame  = 2;           // 2 indicates stereo
    outputFormat.mSampleRate        = kGraphSampleRate;
    
    OSStatus result = noErr;
    
    printf("\nnew AUGrap\n");
    
    result = NewAUGraph(&processingGraph);
    if (result) { printf("NewAUGraph result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    // Create Audio Unit descriptions
    
    //IO Unit
    AudioComponentDescription ioUnitDesc;
    ioUnitDesc.componentType          = kAudioUnitType_Output;
    ioUnitDesc.componentSubType       = kAudioUnitSubType_RemoteIO;
    ioUnitDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    ioUnitDesc.componentFlags         = 0;
    ioUnitDesc.componentFlagsMask     = 0;
    
    //Mixer Unit
    AudioComponentDescription mixerDesc;
    mixerDesc.componentType          = kAudioUnitType_Mixer;
    mixerDesc.componentSubType       = kAudioUnitSubType_MultiChannelMixer;
    mixerDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    mixerDesc.componentFlags         = 0;
    mixerDesc.componentFlagsMask     = 0;
    
    // Player Unit
    AudioComponentDescription playerDesc;
    playerDesc.componentType          = kAudioUnitType_Generator;
    playerDesc.componentSubType       = kAudioUnitSubType_AudioFilePlayer;
    playerDesc.componentManufacturer  = kAudioUnitManufacturer_Apple;
    playerDesc.componentFlags         = 0;
    playerDesc.componentFlagsMask     = 0;
    
    printf("Add Nodes\n");
    
    //Create nodes in the graph for each unit
    result = AUGraphAddNode(processingGraph, &ioUnitDesc, &ioNode);
    if (result) { printf("AUGraphNewNode 1 result %d %4.4s\n", (int)result, (char*)&result); return; }
    
    result = AUGraphAddNode(processingGraph, &mixerDesc, &mixerNode);
    if (result) { printf("AUGraphNewNode 2 result %d %4.4s\n", (int)result, (char*)&result); return; }
    
    result = AUGraphAddNode(processingGraph, &playerDesc, &playerNode);
    if (result) { printf("AUGraphNewNode 3 result %d %4.4s\n", (int)result, (char*)&result); return; }
    
    
    //Connect the nodes in specified order
    //io -  mix
    //player - mix
    //mix - io
    
    result = AUGraphConnectNodeInput(processingGraph, ioNode, 1, mixerNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %d %4.4s\n", (int)result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(processingGraph, mixerNode, 0, ioNode, 0);
    if (result) { printf("AUGraphConnectNodeInput result %d %4.4s\n", (int)result, (char*)&result); return; }
    
    result = AUGraphConnectNodeInput(processingGraph, playerNode, 0, mixerNode, 1);
    if (result) { printf("AUGraphConnectNodeInput result %d %4.4s\n", (int)result, (char*)&result); return; }
    
    
    //Open the graph (units opened but not initialized)
    result = AUGraphOpen(processingGraph);
    if (result) { printf("AUGraphOpen result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    
    // grab the audio unit instances from the nodes
    result = AUGraphNodeInfo(processingGraph, mixerNode, NULL, &mixerUnit);
    if (result) { printf("AUGraphNodeInfo result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(processingGraph, ioNode, NULL, &ioUnit);
    if (result) { printf("AUGraphNodeInfo result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphNodeInfo(processingGraph, playerNode, NULL, &playerUnit);
    if (result) { printf("AUGraphNodeInfo result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    
    // set bus count
    UInt32 numbuses = 2;
    
    printf("set input bus count %u\n", (unsigned int)numbuses);
    
    result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_ElementCount, kAudioUnitScope_Input, 0, &numbuses, sizeof(numbuses));
    if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    
    //enable the hardware input
    UInt32 enableInput        = 1;    // to enable input
    AudioUnitElement inputBus = 1;
    
    result = AudioUnitSetProperty(ioUnit, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, inputBus, &enableInput, sizeof (enableInput));
    if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    result = AudioUnitSetProperty(ioUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &clientFormat, sizeof(clientFormat));
    if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    
    //set the ASBD
    for (UInt32 i = 0; i < numbuses; ++i) {
        result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, i, &clientFormat, sizeof(clientFormat));
        if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    }
    
    
    // set the output stream format of the mixer
    result = AudioUnitSetProperty(mixerUnit, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &outputFormat, sizeof(outputFormat));
    if (result) { printf("AudioUnitSetProperty result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
    result = AUGraphInitialize(processingGraph);
    if (result) { printf("AUGraphInitialize result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
}

#pragma mark - Public Methods

// enable or disables a specific bus
- (void)enableInput:(UInt32)inputNum isOn:(AudioUnitParameterValue)isONValue
{
    printf("BUS %u isON %f\n", (unsigned int)inputNum, isONValue);
    
    OSStatus result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Enable, kAudioUnitScope_Input, inputNum, isONValue, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Enable result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
    
}


// sets the input volume for a specific bus
- (void)setInputVolume:(UInt32)inputNum value:(AudioUnitParameterValue)value
{
    OSStatus result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Input, inputNum, value, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Volume Input result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
}

// sets the overall mixer output volume
- (void)setOutputVolume:(AudioUnitParameterValue)value
{
    OSStatus result = AudioUnitSetParameter(mixerUnit, kMultiChannelMixerParam_Volume, kAudioUnitScope_Output, 0, value, 0);
    if (result) { printf("AudioUnitSetParameter kMultiChannelMixerParam_Volume Output result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
}


// stars graph
- (void)startAUGraph
{
    printf("PLAY\n");
    
    OSStatus result = AUGraphStart(processingGraph);
    if (result) { printf("AUGraphStart result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
}


// stops graph
- (void)stopAUGraph
{
    printf("STOP\n");
    
    OSStatus result = AUGraphStop(processingGraph);
    if (result) { printf("AUGraphStop result %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result); return; }
}

@end

