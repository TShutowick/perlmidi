package PerlMIDI::Test::Message::Channel;

use strict;
use warnings;

use base 'Test::Class';

use Test::More;
use aliased 'PerlMIDI::Message::Channel' => 'ChannelMessage';

sub test_channel_message : Tests {
	my $self = shift;

	eval {
		ChannelMessage->new(
			channel      => 1,
			message_type => 1,
		)
	};

	ok($@, 'Died due to invalid message type');

	my $message = ChannelMessage->new(
		channel      => 1,
		message_type => 0x9, # Note On
	);

	is($message->status_byte, 0x91, 'Channel is set correctly');

}

1;
