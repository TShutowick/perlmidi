package PerlMIDI::Message::Channel;

=head1 NAME

PerlMIDI::Message::Channel - Base class for MIDI channel messages

=cut

use strict;
use warnings;

use Moo;
extends 'PerlMIDI::Message';

use PerlMIDI::Types qw/Nibble Byte/;
use Carp qw/croak/;

=head2 channel

MIDI channel number from 0 to 15

=cut

has channel => (
	is       => 'ro',
	isa      => Nibble,
	required => 1,
);

=head2 message_type

MIDI message type. Acceptable values are:

=over 4

=item 8 - Note Off

=item 9 - Note On

=item 10 - Polyphonic Key Pressure

=item 11 - Control Change

=item 12 - Program Change

=item 13 - Channel Pressure

=item 14 - Pitch Bend Change

=back

=cut

has message_type => (
	is       => 'ro',
	isa => sub {
		my $type = shift;
		Nibble->assert_valid($type);
		return 1 if $type >= 8 && $type <= 14;
		croak "Invalid MIDI message type: $type";
	},
	required => 1,
);

=head2 status_byte

The first byte of the MIDI message, made up of the message type, shifted left by 4 bits,
or'd with the channel.

=cut

has status_byte => (
	is       => 'ro',
	lazy     => 1,
	isa      => Byte,
	builder  => '_build_status_byte',
);

sub _build_status_byte {
	my $self = shift;
	return ($self->message_type << 4) | $self->channel;
}

__PACKAGE__->meta->make_immutable;

1;
