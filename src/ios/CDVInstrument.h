//
//  CDVInstrument.h
//  instrument
//
//  Created by Andrew Haith on 31/03/2015.
//  Copyright (c) 2015 ox-it. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cordova/CDVPlugin.h"
#import <AVFoundation/AVFoundation.h>

@interface CDVInstrument : CDVPlugin


@property(nonatomic) AVAudioEngine *engine;
@property(nonatomic) AVAudioUnitSampler *instrument;

@end
