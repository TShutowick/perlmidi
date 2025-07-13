use strict;
use warnings;


BEGIN {
use FindBin qw/$Bin/;
unshift @INC, "$Bin/lib";
unshift @INC, "$Bin/../lib";
}

use Test::Class::Load qw(t/lib);

# Load and run all tests under t/lib

Test::Class->runtests;
