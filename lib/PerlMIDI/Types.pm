package PerlMIDI::Types;

=head2 NAME

PerlMIDI::Types - Type definitions for PerlMIDI

=cut

use strict;
use warnings;

use Type::Library -base;

use Types::Standard qw/Int/;
use Type::Utils qw/declare as where message/;

=head2 Byte

Int between 0 and 255.

=cut

declare(
	'Byte',
	as Int,
	where { $_ >= 0 && $_ <= 255 },
	message { "Byte value must be a byte (0-255), got $_" }
);

=head2 Nibble

Int between 0 and 15. Used to represent MIDI channels and message types.

=cut

declare(
	'Nibble',
	as Int,
	where { $_ >= 0 && $_ <= 15 },
	message { "Nible value must be a nible (0-15), got $_" }
);

=head2 MidiValue

Int between 0 and 127.

In a MIDI byte, the first bit is a status bit (0 for data bytes, 1 for status bytes).
That leaves 7 bits for the value, which can range from 0 to 127.

=cut

declare(
	'MidiValue',
	as Int,
	where { $_ >= 0 && $_ <= 127 },
	message { "midi value must be an integer between 0 and 127, got $_" }
);

__PACKAGE__->meta->make_immutable;

1;
