package PerlMIDI::Sequence;

=head1 NAME

PerlMIDI::Sequence - A sequence of MIDI notes to be played in a loop

=cut

use PerlMIDI::Utils qw/TICKS_PER_BEAT/;
use PerlMIDI::Types qw/NoteList/;

use aliased 'PerlMIDI::Message::Channel::NoteOn';
use aliased 'PerlMIDI::Message::Channel::NoteOff';

use strict; 
use warnings;

sub new {
	my ($class, %params) = @_;

	my $steps = $params{steps} // [];

	# speed of 1 means one note per beat, speed of 2 means two notes per beat, etc.
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
		_messages => $messages,
	}, __PACKAGE__);
}

=head2 _sanitize_steps

Steps passed to the constructor can be single notes, arrays of notes (chords),
undefined (silence)	or empty arrays (also silence).

Anything else is not valid.

Notes must have a pitch and a length (see L<PerlMIDI::Types::Note>).

This subroutine checks validity and casts all steps to arrays of notes.

=cut

sub _sanitize_steps {
	my ($steps) = @_;

	die "no steps provided" unless $steps && @$steps;

	for my $i (0 .. $#$steps) {
		if (!defined $steps->[$i]) {
			$steps->[$i] = [];
		}
		if (ref $steps->[$i] ne 'ARRAY') {
			$steps->[$i] = [$steps->[$i]];
		}
		NoteList->assert_valid($steps->[$i]);
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

	my @messages;

	for my $i (0 .. $length - 1) {
		my $this_step = $messages[$i] //= [];

		for my $note (@{ $steps->[$i] }) {
			my $end_idx = $i + $note->{duration};
			# If the note extends beyond the end of the sequence,
			# wrap around to the beginning.
			if ($end_idx >= $length) {
				$end_idx -= $length;
			}
			my $off_step = $messages[$end_idx] //= [];
			push @$off_step, NoteOff->new(
				note     => $note->{pitch},
				velocity => 0,
				channel  => $channel,
			);
			push @$this_step, NoteOn->new(
				note     => $note->{pitch},
				velocity => 127,
				channel  => $channel,
			);
		}
	}

	return \@messages;
}

=head2 next_bytes

Returns "note off" bytes for the previous position and "note on" bytes for the current position,
and advances to the next position.

=cut

sub next_bytes {
	my $self = shift;

	my @ret = @{ $self->{_messages}[ $self->{position} ] };

	$self->{position}++;
	$self->{position} = 0 if $self->{position} >= $self->{length};

	return [map { $_->bytes } @ret];
}

=head2 off_bytes

Returns "note off" bytes for all notes in the sequence.

=cut

sub off_bytes {
	my $self = shift;
	my @ret;
	for my $step ( @{ $self->{_messages} }) {
		push @ret, map {
			$_->bytes
		} grep {
			$_->message_type == 8 
		} @{ $step };
	}
	return \@ret;
}

1;
