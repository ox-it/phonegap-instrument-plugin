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
    if (self) {}
    return self;
}

- (void)setup:(CDVInvokedUrlCommand*)command{
    // create engine
    self.engine = [[AVAudioEngine alloc] init];
    
    // create instrument
    self.instrument = [[AVAudioUnitSampler alloc] init];
    [self.engine attachNode:self.instrument];
    [self.engine connect:self.instrument to:self.engine.outputNode format:NULL];
    [self.engine prepare];
    
    NSError *audioEngineStartError = nil;
    [self.engine startAndReturnError:&audioEngineStartError];
    if (audioEngineStartError) {
        NSLog(@"Error starting audio engine:%@", audioEngineStartError.description);
    }
    NSLog(@"started audio engine");
    isInitialised = true;
}

// loadSoundFont(name)
-(void)loadSoundFont:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        if (!isInitialised) {
            [self setup:NULL];
        }
        NSString *name = [command.arguments objectAtIndex:0];
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *instrumentURL = [mainBundle URLForResource:name withExtension:@"sf2" subdirectory:@"www/soundfont"];
        NSError *soundFontLoadError = nil;
        [self.instrument loadInstrumentAtURL:instrumentURL error:&soundFontLoadError];
        ///
        NSString *payload = nil;
        if (soundFontLoadError) {
            payload = @"Error loading sound font:%@", soundFontLoadError.description;
        } else {
            payload = @"Loaded sound font";
            hasSoundFont = true;
        }
        NSLog(payload);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// loadSoundFontBank(name, program, bankMSB, bankLSB)
-(void)loadSoundFontBank:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        if (!isInitialised) {
            [self setup:NULL];
        }
        NSString *name = [command.arguments objectAtIndex:0];
        Byte program = [[command.arguments objectAtIndex:1] intValue];
        Byte bankMSB = [[command.arguments objectAtIndex:2] intValue];
        Byte bankLSB = [[command.arguments objectAtIndex:3] intValue];
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSURL *instrumentURL = [mainBundle URLForResource:name withExtension:@"sf2" subdirectory:@"www/soundfont"];
        NSError *soundFontLoadError = nil;
        [self.instrument loadSoundBankInstrumentAtURL:instrumentURL program:program bankMSB:bankMSB bankLSB:bankLSB error:&soundFontLoadError];
        ///
        NSString *payload = nil;
        if (soundFontLoadError) {
            payload = @"Error loading sound font:%@", soundFontLoadError.description;
        } else {
            payload = @"Loaded sound font";
            hasSoundFont = true;
        }
        NSLog(payload);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:payload];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

// programChange(program, bankMSB, bankLSB, channel)
- (void)programChange:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte program = [[command.arguments objectAtIndex:0] intValue];
        Byte bankMSB = [[command.arguments objectAtIndex:1] intValue];
        Byte bankLSB = [[command.arguments objectAtIndex:2] intValue];
        Byte channel = [[command.arguments objectAtIndex:3] intValue];
        [self.instrument sendProgramChange:program bankMSB:bankMSB bankLSB:bankLSB onChannel:channel];
    } else {
        NSLog(@"No sound font loaded. Cannot use programChange");
    }
}

// send(status, data1, data2, delay)
- (void)send:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte status = [[command.arguments objectAtIndex:0] intValue];
        Byte data1 = [[command.arguments objectAtIndex:1] intValue];
        Byte data2 = [[command.arguments objectAtIndex:2] intValue];
        double delay = [[command.arguments objectAtIndex:3] doubleValue];
        if (delay) {
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delay * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self.instrument sendMIDIEvent:status data1:data1 data2:data2];
            });
        } else {
            [self.instrument sendMIDIEvent:status data1:data1 data2:data2];
        }
    }
    else {
        NSLog(@"No sound font loaded. Cannot send");
    }
}

// noteOn(noteNumber, velocity)
- (void)noteOn:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte noteNumber = [[command.arguments objectAtIndex:0] intValue];
        Byte velocity = [[command.arguments objectAtIndex:1] intValue];
        Byte channel = [[command.arguments objectAtIndex:2] intValue];
        NSLog(@"Playing Note %i with velocity %i", noteNumber, velocity);
        [self.instrument startNote:noteNumber withVelocity:velocity onChannel:channel];
    } else {
        NSLog(@"No sound font loaded. Cannot use noteOn");
    }
}

// noteOff(noteNumber)
- (void)noteOff:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte noteNumber = [[command.arguments objectAtIndex:0] intValue];
        Byte channel = [[command.arguments objectAtIndex:1] intValue];
        NSLog(@"Stopping Note %i", noteNumber);
        [self.instrument stopNote:noteNumber onChannel:channel];
    } else {
        NSLog(@"No sound font loaded. Cannot use noteOff");
    }
    
}

// expression(expression)
- (void)expression:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        int expression = [[command.arguments objectAtIndex:0] intValue];
        NSLog(@"Applying expression %i", expression);
        [self.instrument sendController:11 withValue:expression onChannel:0];
    }
    else {
        NSLog(@"No sound font loaded. Cannot change expression");
    }
}

@end
