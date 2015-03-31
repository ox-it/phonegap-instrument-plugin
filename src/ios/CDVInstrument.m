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

- (void)begin:(CDVInvokedUrlCommand*)command {
    //create engine
    self.engine = [[AVAudioEngine alloc] init];
    
    //create instrument
    self.instrument = [[AVAudioUnitSampler alloc] init];
    [self.engine attachNode:self.instrument];
    
    //load soundfont
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *instrumentURL = [mainBundle URLForResource:@"acoustic_grand_piano" withExtension:@"sf2" subdirectory:@"www"];
    NSString *instrumentPath = [mainBundle pathForResource:@"acoustic_grand_piano" ofType:@"sf2" inDirectory:@"www"];

    NSError *soundFontLoadError = nil;
    [self.instrument loadInstrumentAtURL:instrumentURL error:&soundFontLoadError];
    if (soundFontLoadError) {
        NSLog(@"Error loading sound font");
        NSLog(soundFontLoadError.description);
    }
    NSLog(@"Loaded sound font");
    
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
}

- (void)noteOn:(CDVInvokedUrlCommand*)command {
    int noteNumber = [[command.arguments objectAtIndex:0] intValue];
    [self.instrument startNote:noteNumber withVelocity:127 onChannel:0];
}

- (void)noteOff:(CDVInvokedUrlCommand*)command {
    int noteNumber = [[command.arguments objectAtIndex:0] intValue];
    [self.instrument startNote:noteNumber withVelocity:127 onChannel:0];
    
}

@end
