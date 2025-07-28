package PerlMIDI::Device;

use strict;
use warnings;

=head1 PerlMIDI::Device

Wrapper around a file handle for a midi device.
Closes the file handle as soon as it goes out of scope.

=cut

=head2 write_bytes

Writes a list of bytes to the MIDI device.

=cut

sub write_bytes {
	my ($self, $msg) = @_;

   	my $fh = $self->{fh};

	my $packed = pack('C*', @$msg);
	print $fh $packed or warn "Failed to write to MIDI device: $!";
}

=head2 new

Creates a new PerlMIDI::Device object.

=cut

sub new {
	my ($class, %params) = @_;

	# path to a midi device, e.g. '/dev/midi1'.
	my $path = $params{path}
		or die "Path to MIDI device is required";

	open (my $fh, '>', $path) or die "$!";

	binmode $fh;

	$fh->autoflush;

	return bless({
		fh => $fh,
	}, $class);
}

=head2 DESTROY

Closes the file handle when the object goes out of scope.

=cut

sub DESTROY {
	my $self = shift;
   	my $fh = $self->{fh};
	$fh->close if $fh;
}

1;
