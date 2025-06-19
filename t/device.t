use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/../lib";
}

use Test::More;
use PerlMIDI::Device;
use File::Temp qw/tempfile/;
use File::Slurp;

my ($fh, $filename) = tempfile();

my $device = PerlMIDI::Device->new(path => $filename);

$device->write_bytes([100,0,0]);

undef $device;

my $output = read_file($filename);

is_deeply([unpack('C*', $output)], [100,0,0]);

done_testing;
