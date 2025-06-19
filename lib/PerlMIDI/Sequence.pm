package PerlMIDI::Sequence;

use PerlMIDI::Utils qw/note_on_bytes note_off_bytes/;

use strict; 
use warnings;

sub new {
	my ($class, %params) = @_;

	my @notes = map {
		ref $_ ? $_ : [$_]
	} @{ $params{notes} // [] };

	die "no notes provided" unless @notes;

	return bless({
		notes    => \@notes,
		length 	 => scalar @notes,
		position => 0,
		channel  => $params{channel} || 0,
		speed    => $params{speed} || 1,
	}, __PACKAGE__);
}

=head2 _current_notes

Returns notes for the current position in the sequence.

=cut

sub _current_notes {
	my $self = shift;
	return @{ $self->{notes}[ $self->{position} ] };
}

=head2 _previous_notes

Returns notes for the previous position in the sequence.

=cut

sub _previous_notes {
	my $self = shift;

	my $prev_position = $self->{position} - 1;

	if ($prev_position < 0) {
		$prev_position = $self->{length} - 1;
	}

	return @{ $self->{notes}[ $prev_position ] };
}

=head2 next_bytes

Returns "note off" bytes for the previous position and "note on" bytes for the current position,
and advances to the next position.

=cut

sub next_bytes {
	my $self = shift;

	my @ret;

	# turn off notes from the last step
	for my $note ($self->_previous_notes) {
		push @ret, note_off_bytes($self->{channel}, $note, 0) if defined $note;
	}

	for my $note ($self->_current_notes) {
		push @ret, note_on_bytes($self->{channel}, $note, 127) if defined $note;
	}

	$self->{position}++;
	$self->{position} = 0 if $self->{position} >= $self->{length};

	return \@ret;
}

=head2 off_bytes

Returns "note off" bytes for all notes in the sequence.

=cut

sub off_bytes {
	my $self = shift;
	my @ret;
	for my $step ( @{ $self->{notes} }) {
		for my $note (@$step) {
			push @ret, note_off_bytes($self->{channel}, $note, 0) if defined $note;
		}
	}
	return \@ret;
}

1;
