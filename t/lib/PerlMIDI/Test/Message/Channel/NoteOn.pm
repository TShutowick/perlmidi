package PerlMIDI::Test::Message::Channel;

use strict;
use warnings;

use base 'Test::Class';

use Test::More;
use aliased 'PerlMIDI::Message::Channel::NoteOn' => 'NoteMessage';

sub test_note_message : Tests {
	my $self = shift;

	my $message = NoteMessage->new(
		channel      => 1,
		note         => 60,  # Middle C
	);

	is_deeply($message->bytes, [0x91, 60, 64], 'Note On message bytes');
}

1;
