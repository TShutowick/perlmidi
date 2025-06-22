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
	[1,2,3],
	[],
	100,
	undef,
];

PerlMIDI::Sequence::_sanitize_steps($steps);

is_deeply($steps, [
	[1,2,3],
	[],
	[100],
	[],
], 'sanitize steps');

done_testing();
