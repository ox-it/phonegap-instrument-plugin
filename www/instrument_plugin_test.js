cordova = require('cordova');
channel = require('cordova/channel');
exec = require('cordova/exec');


function Instrument() {

    this.soundfont = null;
    this.cordova = null;

}

Instrument.prototype.begin = function() {
    exec(null, null, "Instrument", "begin", []);
};

Instrument.prototype.noteOn = function(noteNumber, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "Instrument", "noteOn", [noteNumber]);
};

Instrument.prototype.noteOff = function(noteNumber, successCallback, errorCallback) {
    exec(successCallback, errorCallback, "Instrument", "noteOff", [noteNumber]);
};

module.exports = new Instrument();