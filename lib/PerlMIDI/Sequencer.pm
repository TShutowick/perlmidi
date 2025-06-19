package PerlMIDI::Sequencer;

use strict;
use warnings;

use Time::HiRes qw/time/;

use constant TICKS_PER_BEAT => 64;

sub new {
	my ($class, %params) = @_;

	my $bpm = $params{bpm} // 120;

	my $tick_length = 60 / $bpm / TICKS_PER_BEAT;
	
	die "No device provided" unless $params{device};
	die "No tracks provided" unless $params{tracks} && @{ $params{tracks} };

	return bless({
		tracks => $params{tracks},
		tick_length => $tick_length,
		last_tick   => time(),
		tick_number => TICKS_PER_BEAT - 1,
		device      => $params{device},
	}, $class);
}

sub play {
	my $self = shift;

	my $now = time();
	return if $now - $self->{last_tick} < $self->{tick_length};
	$self->{last_tick} = $now;

	$self->{tick_number}++;
	$self->{tick_number} %= TICKS_PER_BEAT;


	for my $track (@{ $self->{tracks} }) {
		my $speed = $track->{speed} // 1;
		my $note_length = int(TICKS_PER_BEAT / $speed);
		next if $self->{tick_number} % $note_length;

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
