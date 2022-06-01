package MusicBrainz::Server::EditSearch::Predicate::EditIDSet;
use Moose;
use namespace::autoclean;
use List::AllUtils qw( any );
use MusicBrainz::Server::Validation qw( is_integer );

extends 'MusicBrainz::Server::EditSearch::Predicate::Set';

sub valid {
    my ($self) = @_;

    return 0 unless $self->arguments > 0;

    # We support one edit type having multiple IDs (for historical edits)
    for my $argument ($self->arguments) {
        my @ids = split(/,/, $argument);
        return 0 if any { !is_integer($_) } @ids;
    }

    return 1;
}

1;
