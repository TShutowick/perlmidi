package PerlMIDI::Sequence;

=head1 NAME

PerlMIDI::Sequence - A sequence of MIDI notes to be played in a loop

=cut

use PerlMIDI::Utils qw/note_on_bytes note_off_bytes TICKS_PER_BEAT/;

use strict; 
use warnings;

sub new {
	my ($class, %params) = @_;

	# TODO the notes param should be renamed to steps, as it is a sequence of steps
	my $steps = $params{notes} // [];
	_sanitize_steps($steps);

	my $speed = $params{speed} // 1;
	die "speed must be a positive number" unless $speed > 0;

	# number of ticks per note for this sequence
	my $note_length = int(TICKS_PER_BEAT / $speed);

	return bless({
		notes    => $steps,
		length 	 => scalar @$steps,
		position => 0,
		channel  => $params{channel} || 0,
		program  => $params{program} || 1,
		speed    => $speed,
		note_length => $note_length,
	}, __PACKAGE__);
}

=head2 _sanitize_steps

Steps passed to the constructor can be single notes, arrays of notes (chords),
undefined (silence)	or empty arrays (also silence).

Notes must be integers between 0 and 127, the MIDI note range.

Anything else is not valid.

This subroutine checks validity and casts all steps to arrays of notes.

=cut

sub _sanitize_steps {
	my ($steps) = @_;

	die "no steps provided" unless $steps && @$steps;

	for my $i (0 .. $#$steps) {
		if (!defined $steps->[$i]) {
			$steps->[$i] = [];
		}
		if (!ref $steps->[$i]) {
			$steps->[$i] = [$steps->[$i]];
		}
		if (ref $steps->[$i] ne 'ARRAY') {
			die "step $i is not an array reference";
		}
		for my $note (@{ $steps->[$i] }) {
			if (!defined $note || $note !~ /^\d+$/ || $note < 0 || $note > 127) {
				die "step $i contains an invalid note: $note";
			}
		}
	}
}

=head2 _current_notes

Returns notes for the current position in the sequence.

=cut

sub _current_notes {
	my $self = shift;
	return @{ $self->{notes}[ $self->{position} ] };
}

=head2 _previous_notes

Returns notes for the previous position in the sequence.

=cut

sub _previous_notes {
	my $self = shift;

	my $prev_position = $self->{position} - 1;

	if ($prev_position < 0) {
		$prev_position = $self->{length} - 1;
	}

	return @{ $self->{notes}[ $prev_position ] };
}

=head2 next_bytes

Returns "note off" bytes for the previous position and "note on" bytes for the current position,
and advances to the next position.

=cut

sub next_bytes {
	my $self = shift;

	my @ret;

	# turn off notes from the last step
	for my $note ($self->_previous_notes) {
		push @ret, note_off_bytes($self->{channel}, $note, 0) if defined $note;
	}

	for my $note ($self->_current_notes) {
		push @ret, note_on_bytes($self->{channel}, $note, 127) if defined $note;
	}

	$self->{position}++;
	$self->{position} = 0 if $self->{position} >= $self->{length};

	return \@ret;
}

=head2 off_bytes

Returns "note off" bytes for all notes in the sequence.

=cut

sub off_bytes {
	my $self = shift;
	my @ret;
	for my $step ( @{ $self->{notes} }) {
		for my $note (@$step) {
			push @ret, note_off_bytes($self->{channel}, $note, 0) if defined $note;
		}
	}
	return \@ret;
}

1;
