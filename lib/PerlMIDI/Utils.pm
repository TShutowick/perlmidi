package PerlMIDI::Utils;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw/note_on_bytes note_off_bytes/;

sub note_on_bytes {
	my ($channel, $note, $vel) = @_;
	my $note_on = 0x90 | $channel;
	return [$note_on, $note, $vel];
}

sub note_off_bytes {
	my ($channel, $note, $vel) = @_;
	my $note_off = 0x80 | $channel;
	return [$note_off, $note, $vel];
}

1;
