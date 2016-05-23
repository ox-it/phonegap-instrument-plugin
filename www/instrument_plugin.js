cordova = require('cordova');
channel = require('cordova/channel');
exec = require('cordova/exec');

function Instrument() {
    this.soundfont = null;
    this.cordova = null;
};

var proto = Instrument.prototype;

PITCHBEND_ZERO_VALUE = 8192;
UNITS_PER_SEMITONE = 3000;

proto.send = function(args, delay) {
    var status = args[0];
    var data1 = args[1];
    var data2 = args[2];
    exec(null, onError, 'Instrument', 'send', [status, data1, data2, delay]);
};

proto.expression = function(expression) {
    exec(null, onError, "Instrument", "expression", [expression]);
};

proto.programChange = function(program, bankMSB, bankLSB, channel) {
    exec(null, onError, 'Instrument', 'programChange', [program, bankMSB, bankLSB, channel || 0]);
};

proto.noteOn = function(note, velocity, channel) {
    exec(null, onError, 'Instrument', 'noteOn', [note, velocity, channel || 0]);
};

proto.noteOff = function(note, channel) {
    exec(null, onError, 'Instrument', 'noteOff', [note, channel || 0]);
};

proto.loadSoundFont = function(name, onsuccess, onerror) {
    exec(onsuccess, onerror || onError, 'Instrument', 'loadSoundFont', [name]);
};

proto.loadSoundFontBank = function(name, program, bankMSB, bankLSB, onsuccess, onerror) {
    exec(onsuccess, onerror || onError, 'Instrument', 'loadSoundFontBank', [name, program, bankMSB, bankLSB]);
};

proto.pitchBend = function(pitchBend, channel) {
    if (pitchBend !== null) {
      pitchBendUnits = parseInt(UNITS_PER_SEMITONE * pitchBend) + PITCHBEND_ZERO_VALUE;
      exec(null, onError, 'Instrument', 'pitchBend', [pitchBendUnits, channel || 0]);
    }
};

function onError(message) {
    console.log(err);
};

module.exports = new Instrument();
