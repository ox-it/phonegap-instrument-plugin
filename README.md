# phonegap-instrument-plugin

This plugin provides a javascript interface to play SoundFont instruments on iOS8+ via Midi commands.

It has been developed for use in the [Resounding](https://github.com/ox-it/resounding) project, a phonegap application which allows users to play instruments from Oxford University's [Bate Collection](http://www.bate.ox.ac.uk/) on their iOS devices.

## Installation
Add the plugin:
```
cordova plugin add https://github.com/ox-it/phonegap-instrument-plugin.git
```

##Usage

####Loading a soundfont
Load soundfonts from the `www/soundfont` folder.
```
Instrument.loadSoundFont(soundfontName)
```
Note that the .sf2 extension is note included

####Playing notes
Start or stop a note according to the standard midi format.
```
Instrument.noteOn(noteNumber, velocity)
Instrument.noteOff(noteNumber)
```
