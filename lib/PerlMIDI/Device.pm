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

	if ($self->{mode} eq '<') {
		die "Cannot write to a device opened in read mode";
	}

   	my $fh = $self->{fh};

	my $packed = pack('C*', @$msg);
	print $fh $packed or warn "Failed to write to MIDI device: $!";
}

=head2 read_bytes

Reads a specified number of bytes from the MIDI device.

=cut

sub read_bytes {
	my ($self, $count) = @_;

	if ($self->{mode} ne '<') {
		die "Cannot read from a device opened in write mode";
	}

   	my $fh = $self->{fh};

	my $buffer;
	my $bytes_read = sysread($fh, $buffer, $count);

	if (!defined $bytes_read) {
		warn "Failed to read from MIDI device: $!";
		return undef;
	}

	if ($bytes_read == 0) {
		die "Input device closed";
	}

	return [ unpack('C*', $buffer) ];
}

=head2 new

Creates a new PerlMIDI::Device object.

=cut

sub new {
	my ($class, %params) = @_;

	my $mode = $params{mode} || '>';
 
	# read, write, or append mode.
	my %valid_modes = map { $_ => 1 } qw(< > >>);

	if (!exists $valid_modes{$mode}) { die "Invalid mode '$mode'. Valid modes are: " . join(', ', keys %valid_modes);
	}

	# path to a midi device, e.g. '/dev/midi1'.
	my $path = $params{path}
		or die "Path to MIDI device is required";

	open (my $fh, $mode, $path) or die "$!";

	binmode $fh;

	$fh->autoflush;

	return bless({
		fh   => $fh,
		mode => $mode,
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
