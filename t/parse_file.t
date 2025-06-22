use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/../lib";
}

use PerlMIDI::Parser;
use Test::More;

my $file = "$Bin/data/test.yml";
my %track = %{PerlMIDI::Parser::load_file(path => $file)};

is_deeply(\%track, {
	channel => 0,
	speed => 2,
	note_length => 32,
	length => 4,
	position => 0,
	program => 1,
	_off_messages => [
		[
			[0x80, 57, 0],
			[0x80, 61, 0],
			[0x80, 66, 0],
		],
		[
			[0x80, 55, 0],
			[0x80, 61, 0],
			[0x80, 64, 0],
		],
		[
			[0x80, 55, 0],
			[0x80, 61, 0],
			[0x80, 64, 0],
		],
		[
			[0x80, 57, 0],
			[0x80, 61, 0],
			[0x80, 66, 0],
		],
	],
	_on_messages => [
		[
			[0x90, 55, 127],
			[0x90, 61, 127],
			[0x90, 64, 127],
		],
		[
			[0x90, 55, 127],
			[0x90, 61, 127],
			[0x90, 64, 127],
		],
		[
			[0x90, 57, 127],
			[0x90, 61, 127],
			[0x90, 66, 127],
		],
		[
			[0x90, 57, 127],
			[0x90, 61, 127],
			[0x90, 66, 127],
		],
	],
});


done_testing;
