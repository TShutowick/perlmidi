use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/lib";
}

use Test::More;
use TmpDevice;
use PerlMIDI::Sequence;

my $steps = [
	[
		{pitch => 1, duration => 1},
		{pitch => 2, duration => 1},
		{pitch => 3, duration => 1},
	],
	[],
	[{pitch => 100, duration => 1}],
	undef,
];

PerlMIDI::Sequence::_sanitize_steps($steps);

is_deeply($steps, [
	[
		{pitch => 1, duration => 1},
		{pitch => 2, duration => 1},
		{pitch => 3, duration => 1},
	],
	[],
	[{pitch => 100, duration => 1}],
	[],
], 'sanitize steps');

$steps = [
	[{pitch => 1, duration => 1}],
];

my $messages = PerlMIDI::Sequence::_prepare_messages($steps,0);

is_deeply($messages, {
	off => [
		[
			[0x80, 1, 0],
		],
	],
	on  => [
		[
			[0x90, 1, 127],
		],
	],
}, 'prepare messages');

my $seq = PerlMIDI::Sequence->new(
	steps => [
		[{pitch => 1, duration => 1}],
		[{pitch => 2, duration => 1}],
		[{pitch => 3, duration => 1}],
	],
);

is_deeply($seq->off_bytes, [
	[0x80, 3, 0],
	[0x80, 1, 0],
	[0x80, 2, 0],
], "off bytes");

done_testing();
