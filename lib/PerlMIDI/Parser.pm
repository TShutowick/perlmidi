package PerlMIDI::Parser;

use strict;
use warnings;

use PerlMIDI::Sequence;
use PerlMIDI::Types qw/MidiValue/;
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
		steps   => \@track_notes,
		program => $program,
	);
}

sub parse_notes {
	my $sequence = shift;
	my $definitions = shift;

	my $reps = 1;
	my $duration = 1;
	# 'x' represents repetitions, '+' represents duration
	# # Examples:
	# 	2x123 -> 2 repetitions of notes 123
	# 	2+123 -> hold notes 123 for 2 steps
	# 	123 -> 1 repetition of notes 123 with 1 step duration
	# 	2x$notes -> 2 repetitions of notes defined in $notes
	if ($sequence =~ s/^(\d+)x//) {
		$reps = $1;
	} elsif ($sequence =~ s/^(\d+)\+//) {
		$duration = $1;
	}
	my $notes;
	# If the sequence starts with a dollar sign, it refers to a definition
	# hey, that's kinda like perl
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

	my @note_objects;
	for my $note (@$notes) {
		MidiValue->assert_valid($note);
		push @note_objects, {
			pitch => $note,
			duration => $duration,
		};
	}
	return ((\@note_objects) x $reps);
}

1;
