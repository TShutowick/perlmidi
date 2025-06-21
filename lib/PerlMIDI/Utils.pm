package PerlMIDI::Utils;

use strict;
use warnings;

use base 'Exporter';
our @EXPORT_OK = qw/
	note_on_bytes
	note_off_bytes
	program_change_bytes
/;

=head2 note_on_bytes

Returns a MIDI note-on message as an array reference.

=cut

sub note_on_bytes {
	my ($channel, $note, $vel) = @_;
	my $note_on = 0x90 | $channel;
	return [$note_on, $note, $vel];
}

=head2 note_off_bytes

Returns a MIDI note-off message as an array reference.

=cut

sub note_off_bytes {
	my ($channel, $note, $vel) = @_;
	my $note_off = 0x80 | $channel;
	return [$note_off, $note, $vel];
}

=head2 program_change_bytes

Returns a MIDI program change message as an array reference.

=cut

sub program_change_bytes {
	my ($channel, $program) = @_;
	my $program_change = 0xC0 | $channel;
	return [$program_change, $program];
}

1;
