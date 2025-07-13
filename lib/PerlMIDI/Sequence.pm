package PerlMIDI::Sequence;

=head1 NAME

PerlMIDI::Sequence - A sequence of MIDI notes to be played in a loop

=cut

use PerlMIDI::Utils qw/TICKS_PER_BEAT/;
use PerlMIDI::Types qw/NoteList UInt Nibble Byte/;
use Types::Standard qw/Int ArrayRef InstanceOf/;

use aliased 'PerlMIDI::Message::Channel::NoteOn';
use aliased 'PerlMIDI::Message::Channel::NoteOff';

use strict; 
use warnings;

use Moo;

=head2 speed

Multiplier for the note length. 1 means each step is a quarter note, 2 means each step
is an eighth note, etc.

=cut

has speed => (
	is       => 'ro',
	isa      => UInt,
	default  => 1,
);

=head2 note_length

The length of each step in ticks.

=cut

# TODO Rename to step_length
has note_length => (
	is       => 'ro',
	isa      => UInt,
	lazy     => 1,
	builder  => sub { int(TICKS_PER_BEAT / shift->speed) },
);

=head2 _messages

Array of arrays of MIDI messages.
Each inner array is a step in the sequence.

=cut

has _messages => (
	is       => 'ro',
	isa      => ArrayRef[ArrayRef[InstanceOf['PerlMIDI::Message']]],
	required => 1,
);

=head2 length

The number of steps in the sequence.

=cut

# this might be overkill, but perl is slow so why not cache the array length
has length => (
	is       => 'ro',
	isa      => UInt,
	lazy     => 1,
	builder  => sub { scalar @{ shift->_messages } },
);

=head2 position

The current position in the sequence. Starts at 0, increments every time next_bytes is called,
and wraps around to 0 when it reaches the end of the sequence.

=cut

has position => (
	is       => 'rw',
	isa      => UInt,
	default  => 0,
);

=head2 channel

The MIDI channel that notes will be played on.

=cut

has channel => (
	is       => 'ro',
	isa      => Nibble,
	default => 0,
);

=head2 program

Sets the MIDI program (instrument) for the sequence.

=cut

has program => (
	is       => 'ro',
	isa      => Byte,
	default  => 1,
);


=head2 BUILDARGS

In addition to the parameters documented above, this method accepts a C<steps> parameter,
which should be an array of NoteList objects. They will be converted into Message objects.

=cut

sub BUILDARGS {
	my ($class, %params) = @_;

	my $messages = _prepare_messages($params{steps}, $params{channel});

	return {%params, _messages => $messages};
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

	$self->position( $self->{position} + 1 );
	$self->position(0) if $self->position >= $self->length;

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
