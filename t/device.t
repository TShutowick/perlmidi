use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/lib";
}

use Test::More;
use TmpDevice;

my $device = TmpDevice->new();

$device->write_bytes([100,0,0]);

my $output = $device->get_bytes();

is_deeply([unpack('C*', $output)], [100,0,0]);

done_testing;
