package PerlMIDI::Sequencer;

use strict;
use warnings;

use Time::HiRes qw/time/;
use PerlMIDI::Utils qw/program_change_bytes TICKS_PER_BEAT/;

=head1 NAME

PerlMIDI::Sequencer - Sends MIDI messages to a device at a specified BPM

=head1 SYNOPSIS

  use PerlMIDI::Sequencer;

  my $seq = PerlMIDI::Sequencer->new(
	  bpm    => 120,
	  device => $midi_device,
	  tracks => \@tracks,
  );

  while (1) {
	  $seq->play();
  }

=cut

sub new {
	my ($class, %params) = @_;

	my $bpm = $params{bpm} // 120;

	my $tick_length = 60 / $bpm / TICKS_PER_BEAT;
	
	die "No device provided" unless $params{device};
	die "No tracks provided" unless $params{tracks} && @{ $params{tracks} };

	# switch all tracks to their "program", which is the
	# instrument they should play
	for my $track (@{ $params{tracks} }) {
		my $bytes = program_change_bytes($track->{channel}, $track->{program});
		$params{device}->write_bytes($bytes);
	}

	return bless({
		tracks => $params{tracks},
		tick_length => $tick_length,
		last_tick   => time(),
		tick_number => TICKS_PER_BEAT - 1,
		device      => $params{device},
	}, $class);
}

=head2 update_tick

Checks if enough time has passed to advance the tick counter.
If enough time has passed, it increments the tick counter and
returns 1, otherwise returns 0.

=cut

sub update_tick {
	my $self = shift;

 	my $now = time();

	return 0 if $now - $self->{last_tick} < $self->{tick_length};

	# record the time of this tick so we can calculate the next one
	$self->{last_tick} = $now;

	$self->{tick_number}++;

	# if we have reached the end of a beat, reset the tick number
	$self->{tick_number} %= TICKS_PER_BEAT;

	return 1;
}

sub play {
	my $self = shift;

	return unless $self->update_tick();

	for my $track (@{ $self->{tracks} }) {
		# if tick_number is not a multiple of note_length,
		# that means we are not at the start of a note
		next if $self->{tick_number} % $track->{note_length};

		for my $msg (@{ $track->next_bytes }) {
			$self->{device}->write_bytes($msg);
		}
	}
}

# turn all notes off when this goes out of scope
sub DESTROY {
	my $self = shift;
	for my $track (@{ $self->{tracks} }) {
		for my $note (@{ $track->off_bytes }) {
			$self->{device}->write_bytes($note);
		}
	}
}

1;
