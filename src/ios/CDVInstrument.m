//
//  CDVInstrument.m
//  instrument
//
//  Created by Andrew Haith on 31/03/2015.
//  Copyright (c) 2015 ox-it. All rights reserved.
//

#import "CDVInstrument.h"
#import <sys/errno.h>

@interface CDVInstrument ()
{
    NSURL *_instrumentURL;
    Byte _program;
    Byte _bankMSB;
    Byte _bankLSB;
    bool _didLoadProgram;
}
@end

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
    self.instrument.masterGain = 3.0;

    [self.engine attachNode:self.instrument];
    [self.engine connect:self.instrument to:self.engine.outputNode format:NULL];
    [self.engine prepare];
    
    NSError *audioEngineStartError = nil;
    [self.engine startAndReturnError:&audioEngineStartError];
    if (audioEngineStartError) {
        #ifdef DEBUG
        NSLog(@"Error starting audio engine:%@", audioEngineStartError.description);
        #endif
    }
    isInitialised = true;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                         selector:@selector(onAudioConfigurationChange)
                                             name:AVAudioEngineConfigurationChangeNotification
                                           object:self.engine];
}

// loadSoundFont(name)
-(void)loadSoundFont:(CDVInvokedUrlCommand*)command {
    if (!isInitialised) {
        [self setup:NULL];
    }
    NSString *name = [command.arguments objectAtIndex:0];
    NSBundle *mainBundle = [NSBundle mainBundle];
    _instrumentURL = [mainBundle URLForResource:name withExtension:@"sf2" subdirectory:@"www/soundfont"];
    NSString* result = [self _loadInstrumentAtURL:_instrumentURL];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

// loadSoundFontBank(name, program, bankMSB, bankLSB)
-(void)loadSoundFontBank:(CDVInvokedUrlCommand*)command {
    if (!isInitialised) {
        [self setup:NULL];
    }
    NSString *name = [command.arguments objectAtIndex:0];
    _program = [[command.arguments objectAtIndex:1] intValue];
    _bankMSB = [[command.arguments objectAtIndex:2] intValue];
    _bankLSB = [[command.arguments objectAtIndex:3] intValue];
    NSBundle *mainBundle = [NSBundle mainBundle];
    _instrumentURL = [mainBundle URLForResource:name withExtension:@"sf2" subdirectory:@"www/soundfont"];
    NSString *result = [self _loadSoundBankInstrumentAtURL:_instrumentURL program:_program bankMSB:_bankMSB bankLSB:_bankLSB];
    CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:result];
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-(NSString*)_loadInstrumentAtURL:(NSURL*)instrumentURL {
    NSError *soundFontLoadError = nil;
    errno = 0;
    [self.instrument loadInstrumentAtURL:instrumentURL error:&soundFontLoadError];
    NSString *payload = nil;
    if (soundFontLoadError) {
        payload = @"Error loading sound font:%@", soundFontLoadError.description;
    } else {
        payload = @"Loaded sound font";
        hasSoundFont = true;
    }
    return payload;
}

-(NSString*)_loadSoundBankInstrumentAtURL:(NSURL*)instrumentURL program:(Byte)program bankMSB:(Byte)bankMSB bankLSB:(Byte)bankLSB {
    
    NSError *soundFontLoadError = nil;
    [self.instrument loadSoundBankInstrumentAtURL:_instrumentURL program:program bankMSB:bankMSB bankLSB:bankLSB error:&soundFontLoadError];

    NSString *payload = nil;
    if (soundFontLoadError) {
        payload = @"Error loading sound font:%@", soundFontLoadError.description;
    } else {
        payload = @"Loaded sound font";
        hasSoundFont = true;
    }
    return payload;
}

// programChange(program, bankMSB, bankLSB, channel)
- (void)programChange:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte program = [[command.arguments objectAtIndex:0] intValue];
        Byte bankMSB = [[command.arguments objectAtIndex:1] intValue];
        Byte bankLSB = [[command.arguments objectAtIndex:2] intValue];
        Byte channel = [[command.arguments objectAtIndex:3] intValue];
        // [self.instrument sendProgramChange:program bankMSB:bankMSB bankLSB:bankLSB onChannel:channel];
        // Using the programChange message doesn't appear to work, but it is possible to specify a program when loading the soundfont
        // if this represents an actual change, reload the sound font with the different bank.
        if(program != _program || bankMSB != _bankMSB || bankLSB != _bankLSB) {
            _program = program;
            _bankMSB = bankMSB;
            _bankLSB = bankLSB;
            [self _loadSoundBankInstrumentAtURL:_instrumentURL program:program bankMSB:bankMSB bankLSB:bankLSB];
        }
    } else {
        #ifdef DEBUG
        NSLog(@"No sound font loaded. Cannot use programChange");
        #endif
    }
}

//called when configuration changes - e.g. when headphones connected or disconnected
-(void)onAudioConfigurationChange {
    isInitialised = false;
    //reload sound font - not fully sure why this is necessary, but we end up with a default MIDI tone without.
    if(_didLoadProgram) {
        //relod the program that was last loaded
        [self _loadSoundBankInstrumentAtURL:_instrumentURL program:_program bankMSB:_bankMSB bankLSB:_bankLSB];
    } else {
        //reload just the sound font
        [self _loadInstrumentAtURL:_instrumentURL];
    }

    NSError *audioEngineStartError = nil;
    [self.engine startAndReturnError:&audioEngineStartError];
    if (audioEngineStartError) {
        #ifdef DEBUG
        NSLog(@"Error starting audio engine:%@", audioEngineStartError.description);
        #endif
    }
    isInitialised = true;
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
        #ifdef DEBUG
        NSLog(@"No sound font loaded. Cannot send");
        #endif
    }
}

// noteOn(noteNumber, velocity)
- (void)noteOn:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte noteNumber = [[command.arguments objectAtIndex:0] intValue];
        Byte velocity = [[command.arguments objectAtIndex:1] intValue];
        Byte channel = [[command.arguments objectAtIndex:2] intValue];
        [self.instrument startNote:noteNumber withVelocity:velocity onChannel:channel];
    } else {
        #ifdef DEBUG
        NSLog(@"No sound font loaded. Cannot use noteOn");
        #endif
    }
}

// noteOff(noteNumber)
- (void)noteOff:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        Byte noteNumber = [[command.arguments objectAtIndex:0] intValue];
        Byte channel = [[command.arguments objectAtIndex:1] intValue];
        [self.instrument stopNote:noteNumber onChannel:channel];
    } else {
        #ifdef DEBUG
        NSLog(@"No sound font loaded. Cannot use noteOff");
        #endif
    }
    
}

// expression(expression)
- (void)expression:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        int expression = [[command.arguments objectAtIndex:0] intValue];
        [self.instrument sendController:11 withValue:expression onChannel:0];
    }
    else {
        #ifdef DEBUG
        NSLog(@"No sound font loaded. Cannot change expression");
        #endif
    }
}

// pitchBend(pitchBend)
- (void)pitchBend:(CDVInvokedUrlCommand*)command {
    if (hasSoundFont) {
        int pitchBend = [[command.arguments objectAtIndex:0] intValue];
        Byte channel = [[command.arguments objectAtIndex:1] intValue];
        [self.instrument sendPitchBend:pitchBend onChannel:channel];
    } else {
        #ifdef DEBUG
        NSLog(@"No sound font loaded. Cannot use pitchBend");
        #endif
    }
}

@end
