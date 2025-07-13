use strict;
use warnings;

use Devel::Confess;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/../lib";
}

use PerlMIDI::Parser;
use Test::More;

use aliased 'PerlMIDI::Message::Channel::NoteOn';
use aliased 'PerlMIDI::Message::Channel::NoteOff';

my $file = "$Bin/data/test.yml";

my $track = PerlMIDI::Parser::load_file(path => $file);

$track->_messages; # trigger lazy loading
$track->length; # trigger lazy loading
$track->note_length; # trigger lazy loading

is_deeply({ %$track }, {
	channel => 0,
	speed => 2,
	note_length => 32,
	length => 4,
	position => 0,
	program => 1,
	_messages => [
		[
			NoteOn->new(channel => 0, note => 55, velocity => 127),
			NoteOn->new(channel => 0, note => 61, velocity => 127),
			NoteOn->new(channel => 0, note => 64, velocity => 127),
			NoteOff->new(channel => 0, note => 57, velocity => 0),
			NoteOff->new(channel => 0, note => 61, velocity => 0),
			NoteOff->new(channel => 0, note => 66, velocity => 0),
		],
		[
			NoteOff->new(channel => 0, note => 55, velocity => 0),
			NoteOff->new(channel => 0, note => 61, velocity => 0),
			NoteOff->new(channel => 0, note => 64, velocity => 0),
			NoteOn->new(channel => 0, note => 55, velocity => 127),
			NoteOn->new(channel => 0, note => 61, velocity => 127),
			NoteOn->new(channel => 0, note => 64, velocity => 127),
		],
		[
			NoteOff->new(channel => 0, note => 55, velocity => 0),
			NoteOff->new(channel => 0, note => 61, velocity => 0),
			NoteOff->new(channel => 0, note => 64, velocity => 0),
			NoteOn->new(channel => 0, note => 57, velocity => 127),
			NoteOn->new(channel => 0, note => 61, velocity => 127),
			NoteOn->new(channel => 0, note => 66, velocity => 127),
		],
		[
			NoteOff->new(channel => 0, note => 57, velocity => 0),
			NoteOff->new(channel => 0, note => 61, velocity => 0),
			NoteOff->new(channel => 0, note => 66, velocity => 0),
			NoteOn->new(channel => 0, note => 57, velocity => 127),
			NoteOn->new(channel => 0, note => 61, velocity => 127),
			NoteOn->new(channel => 0, note => 66, velocity => 127),
		],
	],
});


done_testing;
