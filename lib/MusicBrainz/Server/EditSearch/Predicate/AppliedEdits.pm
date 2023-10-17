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
