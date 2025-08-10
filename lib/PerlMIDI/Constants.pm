package PerlMIDI::Constants;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT = qw/
	TICKS_PER_BEAT
	BYTE_CLOCK
/;

use constant {
	TICKS_PER_BEAT => 64,
	BYTE_CLOCK     => 0xF8, # MIDI clock byte
};


1;
