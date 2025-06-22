use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/lib";
}

use Test::More;
use TmpDevice;
use PerlMIDI::Sequence;
use PerlMIDI::Sequencer;


my $track1 = PerlMIDI::Sequence->new(
	channel => 0,
	speed   => 1,
	steps   => [60, 64, 67],
);

my $track2 = PerlMIDI::Sequence->new(
	channel => 1,
	speed   => 2,
	steps   => [50, 54, 57],
);


my $device = TmpDevice->new();

my $current_time = 0;
my $seq = PerlMIDI::Sequencer->new(
	bpm    => 120,
	device => $device,
	tracks => [$track1, $track2],
	clock  => sub {
		$current_time++;
	},
);

$seq->tick() for (1..33);  # Process the first half beat

my $output = [unpack 'C*', $device->get_bytes()];

my @expected = (
	# first beat
	{
		bytes => [0xC0, 1],
		description => 'Program Change to patch 1 on channel 0 on first track',
	},
	{
		bytes => [0xC1, 1],
		description => 'Program Change to patch 1 on channel 1 on second track',
	},
	{
		bytes => [0x80, 67, 0],
		description => "Note Off for note 67 on channel 0 on first track",
	},
	{
		bytes => [0x90, 60, 127],
		description => "Note On for note 60 on channel 0 on first track",
	},
	{
		bytes => [0x81, 57, 0],
		description => "Note Off for note 57 on channel 1 on second track",
	},
	{
		bytes => [0x91, 50, 127],
		description => "Note On for note 50 on channel 1 on second track",
	},
	# half way between first and second beat - track 2 has notes because it's at double speed
	{
		bytes => [0x81, 50, 0],
		description => "Note Off for note 50 on channel 1 on second track",
	},
	{
		bytes => [0x91, 54, 127],
		description => "Note On for note 54 on channel 1 on second track",
	},
);

for my $expect (@expected) {
	my @actual;
	for my $byte (@{$expect->{bytes}}) {
		push @actual, shift @$output;
	}
	is_deeply(\@actual, $expect->{bytes}, $expect->{description});
}

is(scalar @$output, 0, 'No more bytes left in output after processing');

done_testing;
