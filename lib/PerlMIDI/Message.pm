package PerlMIDI::Message;

=head1 NAME

PerlMIDI::Message - Base class for MIDI messages

=cut

use strict;
use warnings;

use Moo;
use Carp qw/croak/;
use Types::Standard qw/ArrayRef/;
use PerlMIDI::Types qw/Byte/;

has bytes => (
	is       => 'ro',
	isa      => ArrayRef[Byte],
	lazy     => 1,
	builder  => '_build_bytes',
);

sub _build_bytes {
	croak "This method should be overridden in subclasses";
}

1;
