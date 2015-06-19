//
//  CDVInstrument.m
//  instrument
//
//  Created by Andrew Haith on 31/03/2015.
//  Copyright (c) 2015 ox-it. All rights reserved.
//

#import "CDVInstrument.h"


@implementation CDVInstrument
@synthesize engine = _engine;

- (instancetype)init
{
    self = [super init];
    if (self) {


    }
    return self;
}

- (void)setup{
    //create engine
    self.engine = [[AVAudioEngine alloc] init];
    
    //create instrument
    self.instrument = [[AVAudioUnitSampler alloc] init];
    [self.engine attachNode:self.instrument];
    
    //        //load soundfont
    //        NSBundle *mainBundle = [NSBundle mainBundle];
    //        NSURL *instrumentURL = [mainBundle URLForResource:@"acoustic_grand_piano" withExtension:@"sf2" subdirectory:@"www"];
    //        NSString *instrumentPath = [mainBundle pathForResource:@"acoustic_grand_piano" ofType:@"sf2" inDirectory:@"www"];
    
    [self.engine connect:self.instrument to:self.engine.outputNode format:NULL];
    //    AVAudioOutputNode *out = [[AVAudioOutputNode alloc] init];
    //    [self.engine connect:self.engine.outputNode to:out format:NULL];
    
    [self.engine prepare];
    
    NSError *audioEngineStartError = nil;
    [self.engine startAndReturnError:&audioEngineStartError];
    if (audioEngineStartError) {
        NSLog(@"Error starting audio engine");
        NSLog(audioEngineStartError.description);
    }
    NSLog(@"started audio engine");
    isInitialised = true;
}

//Instrument.prototype.loadSoundFont = function(fontName)
-(void)loadSoundFont:(CDVInvokedUrlCommand*)command {
    if(!isInitialised) {
        [self setup:NULL];
    }
    NSString *fontName = [command.arguments objectAtIndex:0];
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *instrumentURL = [mainBundle URLForResource:fontName withExtension:@"sf2" subdirectory:@"www/soundfont"];
    
    NSError *soundFontLoadError = nil;
    [self.instrument loadInstrumentAtURL:instrumentURL error:&soundFontLoadError];
    if (soundFontLoadError) {
        NSLog(@"Error loading sound font");
        NSLog(soundFontLoadError.description);
    }
    else {
        hasSoundFont = true;
    }
    NSLog(@"Loaded sound font");
}

//Instrument.prototype.noteOn = function(noteNumber, velocity, successCallback, errorCallback)
- (void)noteOn:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        int noteNumber = [[command.arguments objectAtIndex:0] intValue];
        int velocity = [[command.arguments objectAtIndex:1] intValue];
        NSLog(@"Playing Note %i with velocity %i", noteNumber, velocity);
        [self.instrument startNote:noteNumber withVelocity:velocity onChannel:0];
    }
    else {
        NSLog(@"No sound font loaded. Cannot play note");
    }
}

//Instrument.prototype.noteOff = function(noteNumber, successCallback, errorCallback)
- (void)noteOff:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        int noteNumber = [[command.arguments objectAtIndex:0] intValue];
        NSLog(@"Stopping Note %i", noteNumber);
        [self.instrument stopNote:noteNumber onChannel:0];
    }
    else {
        NSLog(@"No sound font loaded. Cannot play note");
    }
    
}

@end
