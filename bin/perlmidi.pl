use strict;
use warnings;

# Usage: perl perlmidi.pl <directory_with_yml_files> [<midi_device_path>]

BEGIN {
	use FindBin qw/$Bin/;
	unshift @INC, "$Bin/../lib";
}

use PerlMIDI::Parser;
use PerlMIDI::Device;
use PerlMIDI::Sequencer;

# $dir should be a directory containing .yml files with MIDI tracks
# $dev_path should be a path to a MIDI device, or '/dev/stdout' for testing
my ($dir, $dev_path) = @ARGV;

$dev_path ||= '/dev/stdout';

my @files = glob( "$dir/*.yml") or die "no files in $dir";
my @tracks = map { PerlMIDI::Parser::load_file(path => $_) } @files;

my $device = PerlMIDI::Device->new(path => $dev_path);

my $seq = PerlMIDI::Sequencer->new(
	bpm    => 160,
	device => $device,
	tracks => \@tracks,
);

while(1) {
	my $next = $seq->play() or next;
}
