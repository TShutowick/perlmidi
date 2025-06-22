package TmpDevice;

=head1 NAME
TmpDevice - A temporary file device for PerlMIDI

=head1 SYNOPSIS

  use TmpDevice;

  my $device = TmpDevice->new();
  $device->write($midi_event);
  my $data = $device->get_bytes();

=cut

use strict;
use warnings;

BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/../lib";
}

use base 'PerlMIDI::Device';

use File::Temp qw/tempfile/;
use File::Slurp;

sub new {
	my $class = shift;

	my $fh = File::Temp->new();

	my $self = $class->SUPER::new(path => $fh->filename);

	# PerlMIDI::Device uses its own file handle, but we need to
	# keep this one around so it doesn't get deleted too early.
	$self->{tmp_fh} = $fh;

	return $self;
}

=head2 get_bytes

Returns the contents of the temporary file as a string.

=cut

sub get_bytes {
	my $self = shift;
	my $filename = $self->{tmp_fh};
	return File::Slurp::read_file($filename);
}


1;
