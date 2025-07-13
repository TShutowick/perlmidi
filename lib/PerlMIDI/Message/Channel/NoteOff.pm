package PerlMIDI::Message::Channel::NoteOff;

=head1 NAME

PerlMIDI::Message::Channel::NoteOff - MIDI Note Off message

=cut

use strict;
use warnings;

use Moo;
extends 'PerlMIDI::Message::Channel::NoteBase';

use PerlMIDI::Types qw/Byte/;

=head2 message_type

Always 8, since that's the MIDI status byte for Note Off messages.

=cut

has message_type => (
	is      => 'ro',
	isa     => Byte,
	builder => sub { 0x8 },
);

__PACKAGE__->meta->make_immutable;

1;
