package MusicBrainz::Server::EditSearch::Predicate::VoteCount;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( :vote );
use MusicBrainz::Server::Types qw( VoteOption );
use MusicBrainz::Server::Validation qw( is_integer );

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

around operator_cardinality_map => sub {
    my ($orig, $self) = splice(@_, 0, 2);
    my %orig_map = $self->$orig;
    return map { $_ => 1 + $orig_map{$_} } keys %orig_map;
};

sub combine_with_query {
    my ($self, $query) = @_;

    my $sql = "COALESCE((
        SELECT SUM(CASE WHEN vote = ? THEN 1 ELSE 0 END)
        FROM vote
        WHERE superseded = FALSE AND edit = edit.id
        GROUP BY edit
    ), 0)";

    if ($self->operator eq 'BETWEEN') {
        $sql .= ' BETWEEN SYMMETRIC ? AND ?';
    } else {
        $sql .= ' ' . $self->operator . ' ?';
    }

    $query->add_where([ $sql, $self->sql_arguments ]);
}

sub valid {
    my $self = shift;
    my $cardinality = $self->operator_cardinality($self->operator) or return;
    return unless VoteOption->check($self->argument(0));
    for my $arg_index (1..$cardinality-1) {
        return unless is_integer($self->argument($arg_index));
    }
    return 1;
}

1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016-2017 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
