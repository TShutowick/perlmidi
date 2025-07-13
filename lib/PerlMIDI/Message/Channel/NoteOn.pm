package PerlMIDI::Message::Channel::NoteOn;

=head1 NAME

PerlMIDI::Message::Channel::NoteOn - MIDI Note On message

=cut

use strict;
use warnings;

use Moo;
extends 'PerlMIDI::Message::Channel::NoteBase';

use PerlMIDI::Types qw(Byte);

=head2 message_type

Always 9, since that's the MIDI status byte for Note On messages.

=cut

has message_type => (
	is      => 'ro',
	isa     => Byte,
	builder => sub { 0x9 },
);

1;
