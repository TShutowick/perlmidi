package PerlMIDI::Utils;

=head1 NAME

PerlMIDI::Utils - Utility functions for generating MIDI messages

=head1 SYNOPSIS

  my $note_on = note_on_bytes(0, 60, 127); # Nibble 0, Middle C, velocity 127

  my $note_off = note_off_bytes(0, 60, 0); # Nibble 0, Middle C, velocity 0

  my $program_change = program_change_bytes(0, 10); # Nibble 0, Program Change to patch 10

=cut

use strict;
use warnings;

use PerlMIDI::Types qw/Nibble MidiValue/;

use base 'Exporter';

our @EXPORT_OK = qw/
	note_on_bytes
	note_off_bytes
	program_change_bytes
/;

=head2 note_on_bytes

Returns a MIDI note-on message as an array reference.

=cut

sub note_on_bytes($$$) {
	my ($channel, $note, $vel) = @_;

	Nibble->assert_valid($channel);
	MidiValue->assert_valid($note);
	MidiValue->assert_valid($vel);

	my $note_on = 0x90 | $channel;
	return [$note_on, $note, $vel];
}

=head2 note_off_bytes

Returns a MIDI note-off message as an array reference.

=cut

sub note_off_bytes($$$) {
	my ($channel, $note, $vel) = @_;

	Nibble->assert_valid($channel);
	MidiValue->assert_valid($note);
	MidiValue->assert_valid($vel);

	my $note_off = 0x80 | $channel;
	return [$note_off, $note, $vel];
}

=head2 program_change_bytes

Returns a MIDI program change message as an array reference.

=cut

sub program_change_bytes($$) {
	my ($channel, $program) = @_;

	Nibble->assert_valid($channel);
	MidiValue->assert_valid($program);

	my $program_change = 0xC0 | $channel;
	return [$program_change, $program];
}

1;
