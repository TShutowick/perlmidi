use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/../lib";
}

use PerlMIDI::Parser;
use Test::More;

my $file = "$Bin/data/test.yml";
is_deeply({ %{PerlMIDI::Parser::load_file(path => $file)} }, {
	notes => [
		[55,61,64],
		[55,61,64],
		[57,61,66],
		[57,61,66],
	],
	channel => 0,
	speed => 1,
	length => 4,
	position => 0,
});


done_testing;
