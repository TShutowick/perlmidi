use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/../lib";
}

use lib "$ENV{HOME}/perl5/lib/perl5";
use PerlMIDI::Parser;
use Test::More;

my @tests = (
	{
		name => "empty string",
		string => "",
		wanterr => 1,
	},
	{
		name => "single note",
		string => "1",
		want => [[{pitch => 1, duration => 1}]],
	},
	{
		name => "multiple notes",
		string => "3x100",
		want => [ ([{pitch => 100, duration => 1}]) x 3],
	},
	{
		name => "named chord",
		string => '3x$chord',
		want => [
			[map +{pitch => $_, duration => 1}, 1..3],
			[map +{pitch => $_, duration => 1}, 1..3],
			[map +{pitch => $_, duration => 1}, 1..3],
		],
		definitions => {
			chord => [1,2,3],
		},
	},
	{
		name => "named note",
		string => '3x$note',
		want => [ ([{pitch=>1, duration=>1}]) x3 ],
		definitions => {
			note => 1,
		},
	},
	{
		name => "note with duration",
		string => '3+100',
		want => [[{pitch=>100, duration=>3}], [], []],
	},
);

for my $test (@tests) {
	my @notes;
	my $want_err = $test->{wanterr} ? 1 : 0;
	eval { @notes = PerlMIDI::Parser::parse_notes($test->{string}, $test->{definitions} // {}) };
	my $err = $@;
	my $got_err = $err ? 1 : 0;
	if ($got_err) {
		if (!$want_err) {
			ok(0,"$test->{name} got err: $err");
		} else {
			ok(1, "$test->{name} erred as expected");
		}
		next;
	}
	if ($want_err && !$got_err) {
		ok(0,"$test->{name} should have erred");
		next;
	}
	is_deeply(\@notes, $test->{want}, $test->{name});
}

done_testing;
