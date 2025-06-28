package PerlMIDI::Utils;

=head1 NAME

PerlMIDI::Utils - Utility functions for generating MIDI messages

=head1 SYNOPSIS

  my $note_on = note_on_bytes(0, 60, 127); # Channel 0, Middle C, velocity 127

  my $note_off = note_off_bytes(0, 60, 0); # Channel 0, Middle C, velocity 0

  my $program_change = program_change_bytes(0, 10); # Channel 0, Program Change to patch 10

=cut

use strict;
use warnings;
use Carp qw/croak/;

use base 'Exporter';

our @EXPORT_OK = qw/
	note_on_bytes
	note_off_bytes
	program_change_bytes
	TICKS_PER_BEAT
/;

# Number of ticks per beat, used to calculate the tick length. Every 64 ticks is one beat.
use constant TICKS_PER_BEAT => 64;

=head2 note_on_bytes

Returns a MIDI note-on message as an array reference.

=cut

sub note_on_bytes($$$) {
	my ($channel, $note, $vel) = @_;

	croak "Channel must be defined" unless defined $channel;
	croak "Channel must be between 0 and 15" unless $channel >= 0 && $channel <= 15;

	my $note_on = 0x90 | $channel;
	return [$note_on, $note, $vel];
}

=head2 note_off_bytes

Returns a MIDI note-off message as an array reference.

=cut

sub note_off_bytes($$$) {
	my ($channel, $note, $vel) = @_;

	croak "Channel must be defined" unless defined $channel;
	croak "Channel must be between 0 and 15" unless $channel >= 0 && $channel <= 15;

	my $note_off = 0x80 | $channel;
	return [$note_off, $note, $vel];
}

=head2 program_change_bytes

Returns a MIDI program change message as an array reference.

=cut

sub program_change_bytes($$) {
	my ($channel, $program) = @_;

	croak "Channel must be defined" unless defined $channel;
	croak "Channel must be between 0 and 15" unless $channel >= 0 && $channel <= 15;

	my $program_change = 0xC0 | $channel;
	return [$program_change, $program];
}

1;
