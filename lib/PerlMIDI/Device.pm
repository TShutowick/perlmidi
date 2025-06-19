package PerlMIDI::Device;

use strict;
use warnings;

=head1 PerlMIDI::Device

Wrapper around a file handle for a midi device.
Closes the file handle as soon as it goes out of scope.

=cut

=head2 write_bytes

=cut

sub write_bytes {
	my ($self, $msg) = @_;
	
   	my $fh = $self->{fh};

	my $packed = pack('C*', @$msg);
	print $fh $packed or warn "Failed to write to MIDI device: $!";
}


sub new {
	my ($class, %params) = @_;

	# path to a midi device, e.g. '/dev/midi1'.
	my $path = $params{path};

	open (my $fh, '>', $path) or die "$!";

	binmode $fh;

	$fh->autoflush;

	return bless({
		fh => $fh,
	}, $class);
}

sub DESTROY {
	my $self = shift;
   	my $fh = $self->{fh};
	$fh->close if $fh;
}

1;
