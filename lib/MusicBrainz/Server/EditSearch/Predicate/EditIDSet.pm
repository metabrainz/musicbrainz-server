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

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2022 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
