package PerlMIDI::Message::Channel::NoteBase;

=head1 NAME

PerlMIDI::Message::Channel::NoteBase - Base class for Note On and Note Off messages

=cut

use strict;
use warnings;

use Moo;
extends 'PerlMIDI::Message::Channel';

use PerlMIDI::Types qw/Byte/;

=head2 note

MIDI note number from 0 to 127, where 60 is Middle C.

=cut

has note => (
	is       => 'ro',
	isa      => Byte,
	required => 1,
);

=head2 velocity

Controls how loudly the note is played, from 0 (silent) to 127 (maximum volume).
Defaults to 64.

=cut

has velocity => (
	is      => 'ro',
	isa     => Byte,
	default => sub { 64 },
);

sub _build_bytes {
	my $self = shift;

	return [
		$self->status_byte,
		$self->note,
		$self->velocity,
	];
}


__PACKAGE__->meta->make_immutable;

1;
