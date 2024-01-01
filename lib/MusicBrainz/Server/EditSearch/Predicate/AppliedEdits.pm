package MusicBrainz::Server::EditSearch::Predicate::AppliedEdits;
use Moose;
use namespace::autoclean;

use MusicBrainz::Server::Constants qw( :edit_status );

extends 'MusicBrainz::Server::EditSearch::Predicate::ID';

sub combine_with_query {
    my ($self, $query) = @_;

    my $subquery = '(SELECT COUNT(*) FROM edit H WHERE H.editor = edit.editor AND H.status = ?)';

    my $sql;
    my $operator = $self->operator;
    if ($operator eq 'BETWEEN') {
        $sql = $subquery . ' BETWEEN SYMMETRIC ? AND ?';
    }
    else {
        $sql = join(' ', $subquery, $operator, '?');
    }

    $query->add_where([ $sql, [ $STATUS_APPLIED, @{ $self->sql_arguments } ] ]);
}


1;

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2015 MetaBrainz Foundation

This file is part of MusicBrainz, the open internet music database,
and is licensed under the GPL version 2, or (at your option) any
later version: http://www.gnu.org/licenses/gpl-2.0.txt

=cut
