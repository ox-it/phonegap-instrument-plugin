cordova = require('cordova');
channel = require('cordova/channel');
exec = require('cordova/exec');


function Instrument() {
    this.soundfont = null;
    this.cordova = null;
}

Instrument.prototype.loadSoundFont = function(fontName) {
    exec(null, onError, "Instrument", "loadSoundFont", [fontName]);
};

Instrument.prototype.noteOn = function(noteNumber, velocity) {
    exec(null, onError, "Instrument", "noteOn", [noteNumber, velocity]);
};

Instrument.prototype.noteOff = function(noteNumber, velocity) {
    exec(null, onError, "Instrument", "noteOff", [noteNumber, velocity]);
};

Instrument.prototype.expression = function(expression) {
    exec(null, onError, "Instrument", "expression", [expression]);
};

var onError = function(err) {
	console.log("Error");
	console.log(err);
};

module.exports = new Instrument();