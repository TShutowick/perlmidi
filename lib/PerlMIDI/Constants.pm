package PerlMIDI::Constants;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw/
	TICKS_PER_BEAT
	BYTE_CLOCK
	BYTE_START
	BYTE_CONTINUE
	BYTE_STOP
	BYTE_RESET
	BYTE_CONTROL
	BYTE_NOTE_ON
	BYTE_NOTE_OFF
	BYTE_AFTERTOUCH
	BYTE_CHANNEL_PRESSURE
/;

use constant {
	TICKS_PER_BEAT => 24,
	BYTE_CLOCK     => 0xF8, # MIDI clock byte
	BYTE_START     => 0xFA, # MIDI start byte
	BYTE_CONTINUE  => 0xFB, # MIDI continue byte
	BYTE_STOP      => 0xFC, # MIDI stop byte
	BYTE_RESET     => 0xFF, # MIDI reset byte
	BYTE_CONTROL   => 0xB0, # MIDI control change byte (last nibble is the channel)
	BYTE_NOTE_ON   => 0x90, # MIDI note on byte (last nibble is the channel)
	BYTE_NOTE_OFF  => 0x80, # MIDI note off byte (last nibble is the channel)
	BYTE_AFTERTOUCH 	  => 0xA0, # MIDI aftertouch byte (last nibble is the channel)
	BYTE_CHANNEL_PRESSURE => 0xD0, # MIDI channel pressure byte (last nibble is the channel)
};

1;
