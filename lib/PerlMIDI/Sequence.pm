package PerlMIDI::Sequence;

=head1 NAME

PerlMIDI::Sequence - A sequence of MIDI notes to be played in a loop

=cut

use PerlMIDI::Utils qw/note_on_bytes note_off_bytes TICKS_PER_BEAT/;

use strict; 
use warnings;

sub new {
	my ($class, %params) = @_;

	my $steps = $params{steps} // [];

	my $speed = $params{speed} // 1;
	die "speed must be a positive number" unless $speed > 0;

	# number of ticks per note for this sequence
	my $note_length = int(TICKS_PER_BEAT / $speed);

	my $messages = _prepare_messages($steps, $params{channel});

	return bless({
		length 	 => scalar @$steps,
		position => 0,
		channel  => $params{channel} || 0,
		program  => $params{program} || 1,
		speed    => $speed,
		note_length => $note_length,
		_on_messages  => $messages->{on},
		_off_messages => $messages->{off},
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

=head2 _prepare_messages

Converts a sequence of steps, which are arrays of notes, into a sequence of arrays of MIDI messages.

=cut

sub _prepare_messages {
	my ($steps, $channel) = @_;

	$channel //= 0;

	_sanitize_steps($steps);

	my $length = scalar @$steps;

	my (@on_messages, @off_messages);

	for my $i (0 .. $length - 1) {
		# Start with note off messages for the previous step,
		# wrapping around if necessary.
		my $last_position = $i - 1;
		if ($last_position < 0) {
			$last_position = $length - 1;
		}
		push @off_messages, [map {
			note_off_bytes($channel, $_, 0)
		} @{ $steps->[$last_position] }];

		# Then add note on messages for the current step.
		push @on_messages, [map {
			note_on_bytes($channel, $_, 127)
		} @{ $steps->[$i] }];
	}

	return {
		off => \@off_messages,
		on  => \@on_messages,
	};
}

=head2 next_bytes

Returns "note off" bytes for the previous position and "note on" bytes for the current position,
and advances to the next position.

=cut

sub next_bytes {
	my $self = shift;

	my @ret = @{ $self->{_off_messages}[ $self->{position} ] };
	push @ret, @{ $self->{_on_messages}[ $self->{position} ] };

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
	for my $step ( @{ $self->{_off_messages} }) {
		push @ret, @{ $step };
	}
	return \@ret;
}

1;
