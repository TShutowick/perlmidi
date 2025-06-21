package PerlMIDI::Parser;

use strict;
use warnings;

use PerlMIDI::Sequence;
use YAML qw/LoadFile/;

sub load_file {
	my (%params) = @_;

	my $path = $params{path};
	my $spec = LoadFile($path);

	my $definitions = $spec->{definitions};

	my $channel = $spec->{channel} // die "no channel specified in $path";
	my $speed = $spec->{speed} || 1;

	my $program = $spec->{program} // 0;

	my %sequences;
	while (my ($seq_name, $seq_spec) = each %{ $spec->{sequences} }) {
		for my $notes (@$seq_spec) {
			push @{ $sequences{$seq_name} }, parse_notes($notes, $definitions);
		}
	}

	my @track_notes;
	for my $seq_name (@{ $spec->{structure} }) {
		push @track_notes, @{ $sequences{$seq_name} };
	}

	return PerlMIDI::Sequence->new(
		channel => $channel,
		speed   => $speed,
		notes   => \@track_notes,
		program => $program,
	);
}

sub parse_notes {
	my $sequence = shift;
	my $definitions = shift;

	my $reps = 1;
	# 1x123 or 1x$note
	if ($sequence =~ s/^(\d+)x//) {
		$reps = $1;
	}
	my $notes;
	if ($sequence =~ s/^\$//) {
		$notes = $definitions->{$sequence} or die "definition for $sequence not found";
		if (ref $notes && ref $notes ne 'ARRAY') {
			die "definiton for $sequence is not valid";
		}
	} else {
		$notes = $sequence;
	}

	if (!defined $notes) {
		die "invalid sequence $sequence";
	}

	if (!ref $notes) {
		$notes = [$notes];
	}

	$notes = [grep { $_ ne '_' } @$notes]; # remove rest notes

	for my $note (@$notes) {
		if ($note !~ /^\d+$/) {
			die "$note is not a note";
		}
		if ($note > 127 || $note < 0) {
			die "$note is out of range";
		}
	}
	return (($notes) x $reps);
}

1;
